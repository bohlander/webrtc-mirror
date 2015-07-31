/*
 * libjingle
 * Copyright 2015 Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RTCVideoSource.h"

@class RTCMediaConstraints;
@class RTCPeerConnectionFactory;
@class RTCSimpleVideoFrame;

// RTCSimpleFrameVideoSource is a video source that uses
// webrtc::AVFoundationVideoCapturer. We do not currently provide a wrapper for
// that capturer because cricket::VideoCapturer is not ref counted and we cannot
// guarantee its lifetime. Instead, we expose its properties through the ref
// counted video source interface.
@interface RTCSimpleFrameVideoSource : RTCVideoSource

- (instancetype)initWithFactory:(RTCPeerConnectionFactory*)factory constraints:(RTCMediaConstraints*)constraints;
- (void)sendFrame:(RTCSimpleVideoFrame*)frame;

@end

@interface RTCSimpleVideoFrame : NSObject

@property(nonatomic, assign) uint32_t width;
@property(nonatomic, assign) uint32_t height;
@property(nonatomic, assign) uint32_t pixelWidth;
@property(nonatomic, assign) uint32_t pixelHeight;
@property(nonatomic, assign) uint32_t fourcc;
@property(nonatomic, assign) int rotation;
@property(nonatomic, strong) NSData* data;

@end
