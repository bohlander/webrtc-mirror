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

#import "RTCMediaConstraints+Internal.h"
#import "RTCMediaSource+Internal.h"
#import "RTCPeerConnectionFactory+Internal.h"
#import "RTCVideoSource+Internal.h"
#import "RTCSimpleFrameVideoSource.h"

#include "simpleframevideocapturer.h"

@implementation RTCSimpleFrameVideoSource

- (instancetype)initWithFactory:(RTCPeerConnectionFactory*)factory
                    constraints:(RTCMediaConstraints*)constraints {
  NSParameterAssert(factory);
  rtc::scoped_ptr<webrtc::SimpleFrameVideoCapturer> capturer;
  capturer.reset(new webrtc::SimpleFrameVideoCapturer());
  rtc::scoped_refptr<webrtc::VideoSourceInterface> source =
      factory.nativeFactory->CreateVideoSource(capturer.release(),
                                               constraints.constraints);
  return [super initWithMediaSource:source];
}

- (webrtc::SimpleFrameVideoCapturer*)capturer
{
  cricket::VideoCapturer* capturer = self.videoSource->GetVideoCapturer();
  // This should be safe because no one should have changed the underlying video
  // source.
  webrtc::SimpleFrameVideoCapturer* simpleCapturer = static_cast<webrtc::SimpleFrameVideoCapturer*>(capturer);
  return simpleCapturer;
}

- (void)sendFrame:(RTCSimpleVideoFrame*)frame
{
  [self capturer]->CaptureSimpleFrame(frame);
}

@end
