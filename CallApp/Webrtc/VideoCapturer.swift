//
//  VideoCapturer.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 06/03/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import UIKit

protocol VideoCapturerDelegate {
    
    func didCaptureSampleBuffer(_ sampleBuffer: CMSampleBuffer)
}

class VideoCapturer: RTCVideoCapturer  {
    
    var delegateRef: RTCVideoCapturerDelegate?
    
    override init(delegate: RTCVideoCapturerDelegate) {
        super.init(delegate: delegate)
        self.delegateRef = delegate
    }
}

extension VideoCapturer: VideoCapturerDelegate {
    
    func didCaptureSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        
        if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) || !CMSampleBufferDataIsReady(sampleBuffer)) {
            return
        }
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let delegateRef = self.delegateRef {
            ///
            let rtcPixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
            let timestampns: Int64 = Int64(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))) * Int64(NSEC_PER_SEC)
            
            let rtcFrame = RTCVideoFrame(buffer: rtcPixelBuffer,
                                         rotation: ._0,
                                         timeStampNs: timestampns)
            
            print("buffering frame....")
            
            delegateRef.capturer(self, didCapture: rtcFrame)
        }
    }
}
