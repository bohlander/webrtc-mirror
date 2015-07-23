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

#include "talk/app/webrtc/objc/simpleframevideocapturer.h"

#include "webrtc/base/bind.h"

#import "RTCSimpleFrameVideoSource.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// TODO(tkchin): support other formats.
static cricket::VideoFormat const kDefaultFormat =
    cricket::VideoFormat(640,
                         360,
                         cricket::VideoFormat::FpsToInterval(30),
                         cricket::FOURCC_NV12);

namespace webrtc {

SimpleFrameVideoCapturer::SimpleFrameVideoCapturer() : _startThread(nullptr), _startTime(0) {
  _notifier = [[RTCSimpleVideoFrameCapturerNotifier alloc] init];

  // Set our supported formats. This matches kDefaultPreset.
  std::vector<cricket::VideoFormat> supportedFormats;
  supportedFormats.push_back(cricket::VideoFormat(kDefaultFormat));
  SetSupportedFormats(supportedFormats);
}

SimpleFrameVideoCapturer::~SimpleFrameVideoCapturer()
{
  _notifier = nil;
}

cricket::CaptureState SimpleFrameVideoCapturer::Start(
    const cricket::VideoFormat& format) {
  if (_isRunning) {
    LOG(LS_ERROR) << "The capturer is already running.";
    return cricket::CaptureState::CS_FAILED;
  }

  if (format != kDefaultFormat) {
    LOG(LS_ERROR) << "Unsupported format provided.";
    return cricket::CaptureState::CS_FAILED;
  }

  // Keep track of which thread capture started on. This is the thread that
  // frames need to be sent to.
  DCHECK(!_startThread);
  _startThread = rtc::Thread::Current();

  SetCaptureFormat(&format);

  _startTime = rtc::TimeNanos();
  SetCaptureState(cricket::CaptureState::CS_RUNNING);

  _isRunning = true;

  [_notifier notifyStarted];

  return cricket::CaptureState::CS_STARTING;
}

void SimpleFrameVideoCapturer::Stop() {
  SetCaptureFormat(NULL);
  _startThread = nullptr;
  _isRunning = false;

  [_notifier notifyStopped];
}

bool SimpleFrameVideoCapturer::IsRunning() {
  return _isRunning;
}


void SimpleFrameVideoCapturer::CaptureSimpleFrame(RTCSimpleVideoFrame* simpleFrame)
{
  if (!_isRunning) {
    LOG(LS_ERROR) << "Ignoring frame, not running";
    return;
  }

  // Stuff data into a cricket::CapturedFrame.
  int64 currentTime = rtc::TimeNanos();
  cricket::CapturedFrame frame;
  frame.width = simpleFrame.width;
  frame.height = simpleFrame.height;
  frame.pixel_width = simpleFrame.pixelWidth;
  frame.pixel_height = simpleFrame.pixelHeight;
  frame.fourcc = cricket::FOURCC_NV12;
  frame.time_stamp = currentTime;
  frame.elapsed_time = currentTime - _startTime;

  // todo: rayray this cast is super sketchy
  frame.data = (void*)simpleFrame.data.bytes;
  frame.data_size = simpleFrame.data.length;

  if (_startThread->IsCurrent()) {
    SignalFrameCaptured(this, &frame);
  } else {
    _startThread->Invoke<void>(rtc::Bind(&SimpleFrameVideoCapturer::SignalFrameCapturedOnStartThread, this, &frame));
   }
}

void SimpleFrameVideoCapturer::SignalFrameCapturedOnStartThread(const cricket::CapturedFrame* frame) {
  DCHECK(_startThread->IsCurrent());
  // This will call a superclass method that will perform the frame conversion
  // to I420.
  SignalFrameCaptured(this, frame);
}

}  // namespace webrtc
