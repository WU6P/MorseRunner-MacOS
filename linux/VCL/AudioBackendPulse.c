// AudioBackendPulse.c — Streaming PulseAudio backend for Morse Runner Linux port.
// Called from Pascal (FPC / Lazarus). Drop-in replacement for AudioBackend2.m
// (CoreAudio macOS backend) with identical C function signatures.
//
// Architecture (same as macOS):
//   Pascal main thread  → AudioBackendPulse_Write() → lock-free ring buffer
//   Playback thread     → pulse_thread_func()       → reads from ring buffer
//
// When the ring buffer falls below the low-water mark, gNeedsData is set to 1.
// A TTimer in SndOut.pas polls this flag from the main thread, fires
// OnBufAvailable, and the application calls PutData() /
// AudioBackendPulse_Write() to refill the ring buffer.
//
// Key difference from the naive "write silence on underrun" approach:
//   When the ring buffer is empty the playback thread WAITS (2 ms sleep) instead
//   of injecting silence into the PulseAudio stream.  Injecting silence fills
//   PulseAudio's internal buffer ahead of real audio, causing audible gaps.
//   GetAudio() in Contest.pas always produces real samples (including intended
//   zero-valued silence), so the ring is only truly empty at startup or on a
//   very long delay — both cases where a brief wait is correct.
//
// Thread safety: single-producer (Pascal main thread) single-consumer
// (playback thread) lock-free ring buffer. All shared state accessed
// atomically or protected by the SPSC invariant.
//
// Build:
//   gcc -c AudioBackendPulse.c -o AudioBackendPulse.o \
//       -fPIC $(pkg-config --cflags libpulse-simple) -O2

#include <pulse/simple.h>
#include <pulse/error.h>
#include <pthread.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

// ---------------------------------------------------------------------------
// Ring buffer — size must be a power of 2 for the modulo-by-AND trick.
// At 11025 Hz mono float32, 65536 frames ≈ 5.9 seconds of audio.
// ---------------------------------------------------------------------------
#define RING_FRAMES 65536
#define RING_MASK   (RING_FRAMES - 1)

static float           gRing[RING_FRAMES];
static volatile int    gReadPos   = 0;   // written only by playback thread
static volatile int    gWritePos  = 0;   // written only by Pascal main thread
static volatile int    gNeedsData = 0;   // set by playback thread, cleared by Pascal

static pa_simple      *gPulse     = NULL;
static pthread_t       gThread;
static int             gBufFrames = 512;   // frames per write chunk
static int             gLowWater  = 2048;  // refill threshold
static volatile int    gRunning   = 0;
static float           gVolume    = 1.0f;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Frames currently available in the ring buffer for reading.
static int RingAvailable(void)
{
    int w = gWritePos;
    int r = gReadPos;
    int avail = w - r;
    if (avail < 0) avail += RING_FRAMES;
    return avail;
}

// Free slots in the ring buffer (Pascal may write this many frames).
static int RingSpace(void)
{
    return RING_FRAMES - 1 - RingAvailable();
}

static void sleep_ms(int ms)
{
    struct timespec ts;
    ts.tv_sec  = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000L;
    nanosleep(&ts, NULL);
}

// ---------------------------------------------------------------------------
// Playback thread — reads from ring buffer and writes to PulseAudio.
// Runs until gRunning is cleared.
//
// Design: wait for a full chunk before writing. Never write silence when the
// ring is empty — that injects dead frames ahead of real audio in PA's buffer.
// ---------------------------------------------------------------------------
static void *pulse_thread_func(void *arg)
{
    (void)arg;
    float buf[512];
    int error;
    int nFrames = (gBufFrames > 512) ? 512 : gBufFrames;

    while (gRunning) {

        /* Wait until the ring contains at least one full chunk.
           Sleep 2 ms between checks — well under one buffer period (~46 ms). */
        while (gRunning && RingAvailable() < nFrames) {
            gNeedsData = 1;
            sleep_ms(2);
        }
        if (!gRunning) break;

        /* Copy nFrames from ring buffer, apply volume. */
        int rp = gReadPos;
        int i;
        for (i = 0; i < nFrames; i++) {
            buf[i] = gRing[rp & RING_MASK] * gVolume;
            rp++;
        }
        gReadPos = rp & RING_MASK;

        /* Write to PulseAudio — blocking call paces the thread to the
           hardware clock (~46 ms per 512-frame chunk at 11025 Hz). */
        if (pa_simple_write(gPulse, buf, (size_t)(nFrames * sizeof(float)), &error) < 0) {
            fprintf(stderr, "AudioBackendPulse: pa_simple_write failed: %s\n",
                    pa_strerror(error));
            break;
        }

        /* Signal the Pascal main thread to refill if below low-water mark. */
        if (RingAvailable() < gLowWater)
            gNeedsData = 1;
    }

    return NULL;
}

// ---------------------------------------------------------------------------
// AudioBackendPulse_Start
//   sampleRate  - Hz (typically 11025 for Morse Runner)
//   bufFrames   - frames per write chunk (typically 512)
//   numBufs     - number of logical buffers (sets low-water mark)
// Returns 0 on success, non-zero on failure.
// ---------------------------------------------------------------------------
int AudioBackendPulse_Start(int sampleRate, int bufFrames, int numBufs)
{
    if (gRunning) return -1;

    gBufFrames = bufFrames;
    if (gBufFrames > 512) gBufFrames = 512;
    gLowWater  = bufFrames * numBufs;
    gReadPos   = 0;
    gWritePos  = 0;
    gNeedsData = 1;   // immediately request initial fill

    memset(gRing, 0, sizeof(gRing));

    // PulseAudio sample format: mono float32
    pa_sample_spec ss;
    ss.format   = PA_SAMPLE_FLOAT32LE;
    ss.rate     = (uint32_t)sampleRate;
    ss.channels = 1;

    // Let PulseAudio choose its own buffer sizes (maxlength = -1 means default).
    // We do our own buffering in the ring; PA just needs enough to hide OS jitter.
    pa_buffer_attr ba;
    memset(&ba, 0, sizeof(ba));
    ba.maxlength = (uint32_t)-1;
    ba.tlength   = (uint32_t)(bufFrames * numBufs * sizeof(float));
    ba.prebuf    = (uint32_t)(bufFrames * sizeof(float));
    ba.minreq    = (uint32_t)(bufFrames * sizeof(float));
    ba.fragsize  = (uint32_t)-1;  // not used for playback

    int error;
    gPulse = pa_simple_new(
        NULL,               // default server
        "MorseRunner",      // application name
        PA_STREAM_PLAYBACK,
        NULL,               // default device
        "Contest Audio",    // stream description
        &ss,
        NULL,               // default channel map
        &ba,
        &error
    );

    if (!gPulse) {
        fprintf(stderr, "AudioBackendPulse: pa_simple_new failed: %s\n",
                pa_strerror(error));
        return error;
    }

    gRunning = 1;

    if (pthread_create(&gThread, NULL, pulse_thread_func, NULL) != 0) {
        fprintf(stderr, "AudioBackendPulse: pthread_create failed\n");
        pa_simple_free(gPulse);
        gPulse   = NULL;
        gRunning = 0;
        return -2;
    }

    return 0;
}

// ---------------------------------------------------------------------------
// AudioBackendPulse_Stop — stop playback and release PulseAudio connection.
// ---------------------------------------------------------------------------
void AudioBackendPulse_Stop(void)
{
    if (!gRunning) return;

    gRunning = 0;
    pthread_join(gThread, NULL);

    if (gPulse) {
        int error;
        pa_simple_drain(gPulse, &error);
        pa_simple_free(gPulse);
        gPulse = NULL;
    }
}

// ---------------------------------------------------------------------------
// AudioBackendPulse_Write — called from Pascal main thread to enqueue samples.
//   samples  - float array, values in range [-32767.0 .. +32767.0]
//              (Morse Runner uses unnormalised audio; we normalise to [-1,1])
//   nFrames  - number of samples
// Returns number of frames actually written (may be less if ring is full).
// ---------------------------------------------------------------------------
int AudioBackendPulse_Write(const float *samples, int nFrames)
{
    int space   = RingSpace();
    int written = (nFrames < space) ? nFrames : space;
    int wp      = gWritePos;

    int i;
    for (i = 0; i < written; i++) {
        // Normalise from [-32767,32767] to [-1,1]
        float v = samples[i] * (1.0f / 32767.0f);
        if (v >  1.0f) v =  1.0f;
        if (v < -1.0f) v = -1.0f;
        gRing[wp & RING_MASK] = v;
        wp++;
    }
    gWritePos = wp & RING_MASK;
    return written;
}

// ---------------------------------------------------------------------------
// AudioBackendPulse_NeedsData — returns 1 if the ring buffer needs refilling.
// Called from Pascal's TTimer handler on the main thread.
// ---------------------------------------------------------------------------
int AudioBackendPulse_NeedsData(void)
{
    return gNeedsData;
}

// ---------------------------------------------------------------------------
// AudioBackendPulse_ClearNeedsData — clear the refill request flag.
// ---------------------------------------------------------------------------
void AudioBackendPulse_ClearNeedsData(void)
{
    gNeedsData = 0;
}

// ---------------------------------------------------------------------------
// AudioBackendPulse_Available — frames currently in the ring buffer.
// ---------------------------------------------------------------------------
int AudioBackendPulse_Available(void)
{
    return RingAvailable();
}

// ---------------------------------------------------------------------------
// AudioBackendPulse_SetVolume — set playback volume [0.0 .. 1.0].
// ---------------------------------------------------------------------------
void AudioBackendPulse_SetVolume(float vol)
{
    if (vol < 0.0f) vol = 0.0f;
    if (vol > 1.0f) vol = 1.0f;
    gVolume = vol;
}
