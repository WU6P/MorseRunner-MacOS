// AudioBackend2.m — Streaming CoreAudio backend for Morse Runner macOS port.
// Called from Pascal (FPC / Lazarus). All CoreAudio calls live here so they
// are compiled by Clang and are fully compatible with macOS ARM64 (Apple M1).
//
// Architecture:
//   Pascal main thread  → AudioBackend2_Write() → lock-free ring buffer
//   CoreAudio thread    → AQCallback()           → reads from ring buffer
//
// When the ring buffer falls below the low-water mark the C code sets
// gNeedsData = 1. A TTimer in SndOut.pas polls this flag from the main
// thread, fires OnBufAvailable, and the application calls PutData() /
// AudioBackend2_Write() to refill the ring buffer.
//
// Thread safety: single-producer (Pascal main thread) single-consumer
// (CoreAudio callback thread) lock-free ring buffer. All shared state
// accessed atomically or protected by the SPSC invariant.

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#include <stdint.h>
#include <string.h>

// ---------------------------------------------------------------------------
// Ring buffer — size must be a power of 2 for the modulo-by-AND trick.
// At 11025 Hz mono float32, 65536 frames ≈ 5.9 seconds of audio.
// ---------------------------------------------------------------------------
#define RING_FRAMES 65536
#define RING_MASK   (RING_FRAMES - 1)

static float           gRing[RING_FRAMES];
static volatile int    gReadPos  = 0;   // written only by CoreAudio thread
static volatile int    gWritePos = 0;   // written only by Pascal main thread
static volatile int    gNeedsData = 0;  // set by CoreAudio, cleared by Pascal

static AudioQueueRef   gQueue      = NULL;
static int             gBufFrames  = 512;   // frames per AudioQueue buffer
static int             gLowWater   = 2048;  // refill threshold
static volatile int    gRunning    = 0;
static float           gVolume     = 1.0f;

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

// ---------------------------------------------------------------------------
// Clear ARM64 FPCR exception trap enable bits.
// FPC sets these bits; CoreAudio threads inherit them and crash on IEEE-754
// special values (inf / NaN) that arise in normal DSP math.
// Bits: IOE(8) DZE(9) OFE(10) UFE(11) IXE(12) IDE(15)
// ---------------------------------------------------------------------------
static void clearFPCRTraps(void)
{
    uint64_t fpcr;
    __asm__ volatile("mrs %0, fpcr" : "=r"(fpcr));
    fpcr &= ~(uint64_t)0x9F00ULL;
    __asm__ volatile("msr fpcr, %0" : : "r"(fpcr));
}

// ---------------------------------------------------------------------------
// AudioQueue callback — called when a buffer finishes playing.
// Runs on the CoreAudio realtime thread. No Pascal calls allowed here.
// ---------------------------------------------------------------------------
static void AQCallback(void            *userData,
                       AudioQueueRef    inAQ,
                       AudioQueueBufferRef inBuf)
{
    if (!gRunning) return;

    int nFrames = (int)(inBuf->mAudioDataBytesCapacity / sizeof(float));
    float *out  = (float *)inBuf->mAudioData;
    int avail   = RingAvailable();
    int toCopy  = avail < nFrames ? avail : nFrames;

    // Copy available frames from ring buffer
    int rp = gReadPos;
    for (int i = 0; i < toCopy; i++) {
        out[i] = gRing[rp & RING_MASK] * gVolume;
        rp++;
    }
    gReadPos = rp & RING_MASK;

    // Pad remainder with silence (underrun protection)
    for (int i = toCopy; i < nFrames; i++)
        out[i] = 0.0f;

    inBuf->mAudioDataByteSize = (UInt32)(nFrames * sizeof(float));
    AudioQueueEnqueueBuffer(inAQ, inBuf, 0, NULL);

    // Signal the Pascal main thread to refill if below low-water mark
    if (RingAvailable() < gLowWater)
        gNeedsData = 1;
}

// ---------------------------------------------------------------------------
// AudioBackend2_Start
//   sampleRate  - Hz (typically 11025 for Morse Runner)
//   bufFrames   - frames per AudioQueue buffer (typically 512)
//   numBufs     - number of AudioQueue buffers to allocate (typically 4-8)
// Returns 0 on success, non-zero OSStatus on failure.
// ---------------------------------------------------------------------------
int AudioBackend2_Start(int sampleRate, int bufFrames, int numBufs)
{
    clearFPCRTraps();

    @autoreleasepool {
        gBufFrames = bufFrames;
        gLowWater  = bufFrames * numBufs;   // keep this many frames pre-buffered
        gReadPos   = 0;
        gWritePos  = 0;
        gNeedsData = 1;   // immediately request initial fill
        gRunning   = 1;
        gQueue     = NULL;

        memset(gRing, 0, sizeof(gRing));

        AudioStreamBasicDescription fmt;
        memset(&fmt, 0, sizeof(fmt));
        fmt.mSampleRate       = (Float64)sampleRate;
        fmt.mFormatID         = kAudioFormatLinearPCM;
        fmt.mFormatFlags      = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
        fmt.mBytesPerPacket   = sizeof(float);
        fmt.mFramesPerPacket  = 1;
        fmt.mBytesPerFrame    = sizeof(float);
        fmt.mChannelsPerFrame = 1;
        fmt.mBitsPerChannel   = 32;

        OSStatus st = AudioQueueNewOutput(&fmt, AQCallback,
                                         NULL, NULL, NULL, 0, &gQueue);
        if (st != noErr || gQueue == NULL) {
            gRunning = 0;
            return (int)st;
        }

        AudioQueueSetParameter(gQueue, kAudioQueueParam_Volume, 1.0f);

        // Allocate and enqueue initial silent buffers to prime the queue
        for (int i = 0; i < numBufs; i++) {
            AudioQueueBufferRef buf = NULL;
            st = AudioQueueAllocateBuffer(gQueue,
                                          (UInt32)(bufFrames * sizeof(float)), &buf);
            if (st != noErr || buf == NULL) {
                AudioQueueDispose(gQueue, true);
                gQueue   = NULL;
                gRunning = 0;
                return (int)st;
            }
            memset(buf->mAudioData, 0, buf->mAudioDataBytesCapacity);
            buf->mAudioDataByteSize = buf->mAudioDataBytesCapacity;
            AudioQueueEnqueueBuffer(gQueue, buf, 0, NULL);
        }

        st = AudioQueueStart(gQueue, NULL);
        if (st != noErr) {
            AudioQueueDispose(gQueue, true);
            gQueue   = NULL;
            gRunning = 0;
            return (int)st;
        }

        return 0;
    }
}

// ---------------------------------------------------------------------------
// AudioBackend2_Stop — stop and dispose the AudioQueue.
// ---------------------------------------------------------------------------
void AudioBackend2_Stop(void)
{
    gRunning = 0;
    if (gQueue) {
        AudioQueueStop(gQueue, true);
        AudioQueueDispose(gQueue, true);
        gQueue = NULL;
    }
}

// ---------------------------------------------------------------------------
// AudioBackend2_Write — called from Pascal main thread to enqueue samples.
//   samples  - float array, values in range [-32767.0 .. +32767.0]
//              (Morse Runner uses unnormalised audio; we normalise to [-1,1])
//   nFrames  - number of samples
// Returns number of frames actually written (may be less if ring is full).
// ---------------------------------------------------------------------------
int AudioBackend2_Write(const float *samples, int nFrames)
{
    int space   = RingSpace();
    int written = (nFrames < space) ? nFrames : space;
    int wp      = gWritePos;

    for (int i = 0; i < written; i++) {
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
// AudioBackend2_NeedsData — returns 1 if the ring buffer needs refilling.
// Called from Pascal's TTimer handler on the main thread.
// ---------------------------------------------------------------------------
int AudioBackend2_NeedsData(void)
{
    return gNeedsData;
}

// ---------------------------------------------------------------------------
// AudioBackend2_ClearNeedsData — clear the refill request flag.
// ---------------------------------------------------------------------------
void AudioBackend2_ClearNeedsData(void)
{
    gNeedsData = 0;
}

// ---------------------------------------------------------------------------
// AudioBackend2_Available — frames currently in the ring buffer.
// ---------------------------------------------------------------------------
int AudioBackend2_Available(void)
{
    return RingAvailable();
}

// ---------------------------------------------------------------------------
// AudioBackend2_SetVolume — set playback volume [0.0 .. 1.0].
// ---------------------------------------------------------------------------
void AudioBackend2_SetVolume(float vol)
{
    if (vol < 0.0f) vol = 0.0f;
    if (vol > 1.0f) vol = 1.0f;
    gVolume = vol;
    if (gQueue)
        AudioQueueSetParameter(gQueue, kAudioQueueParam_Volume, vol);
}
