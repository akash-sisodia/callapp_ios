//
//  WebRTCManager.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 06/03/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import Foundation
import WebRTC
import SocketIO

public typealias HTTPParameters = [String: Any]

protocol WebRTCManagerDelegate {
    
    func didAddRemoteStream(videoTrack: RTCVideoTrack)
    func manager(_ manager: WebRTCManager, didChange state: SocketIOStatus)
    func manager(_ manager: WebRTCManager, didChange signalingState: RTCSignalingState)
    func manager(_ manager: WebRTCManager, didChange ICEConnectionState: RTCIceConnectionState)
    func manager(_ manager: WebRTCManager, didCreate externalCapturer: VideoCapturer)
    func managerDidJoinRoom()
}


public class WebRTCManager: NSObject {
    
    static let shared: WebRTCManager = WebRTCManager()
    
    var connection: RTCPeerConnection!
    
    var peerConnectionFactory: RTCPeerConnectionFactory!
    
    var capturer: RTCVideoCapturer?
    
    var videoSource: RTCVideoSource?

    var videoTrack: RTCVideoTrack?
    
    var audioSource: RTCAudioSource?

    var audioTrack: RTCAudioTrack?

    var delegate: WebRTCManagerDelegate?
    
    var remoteTrackHandler: ((RTCVideoTrack) -> ())?
    
    var remoteViedoTrack: RTCVideoTrack?
   
    var remoteAudioTrack: RTCAudioTrack?

    func setDelegate(delegate: WebRTCManagerDelegate){
        self.delegate = delegate
    }
    
    /// #1 Initialize peer connection
    func createPeerConnection() {
        
        /// #2 Initialize factory
        func createPeerConnectionFactory() {
            ///
            let decoderFactory = RTCDefaultVideoDecoderFactory()
            let encoderFactory = RTCDefaultVideoEncoderFactory()
            peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: encoderFactory, decoderFactory: decoderFactory)
            
            ///
//            let videoSource = peerConnectionFactory.videoSource()
//            capturer = RTCVideoCapturer(delegate: videoSource)
//            videoTrack = peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
//            self.videoSource = videoSource
            
        }
        
        createPeerConnectionFactory()
        
        /// #3 create connection
        let configuration = RTCConfiguration()
        configuration.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        configuration.sdpSemantics = .unifiedPlan
        
        let connectionConstraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                                        optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
        
        let peerConnection = peerConnectionFactory.peerConnection(with: configuration,
                                                                  constraints: connectionConstraints,
                                                                  delegate: self)
        
       // peerConnection.add(videoTrack!, streamIds: ["vsender0"])
        
        
        let videoSendSource = peerConnectionFactory.videoSource()
        let externalCapturer = VideoCapturer(delegate: videoSendSource)
        let videoTrackSend = peerConnectionFactory.videoTrack(with: videoSendSource, trackId: "video_0u1")
        peerConnection.add(videoTrackSend, streamIds: ["stream_video_0u1"])

        connection = peerConnection
        
        self.delegate?.manager(self, didCreate: externalCapturer)

    }
    
    /// #4
    func createOffer(_ handler: @escaping([AnyHashable: Any]) -> Void) {
        ///
        self.createPeerConnection()
        
        guard let connection = connection else { return }
        
        let constraints = offerConstraints(receiveVideo: true,
                                           receiveAudio: false)
        
        connection.offer(for: constraints) { (sdp, error) in
            ///
            guard error == nil, let sdp = sdp else {
                print("error while creating local sdp: ", error!)
                return
            }
            
            ///
            connection.setLocalDescription(sdp) { (error) in
                ///
                guard error == nil else {
                    print("error while setting local sdp: ", error!)
                    return
                }
                
                if connection.signalingState == .haveLocalOffer {
                    handler(sdp.json())
                }
            }
        }
    }
    
    /// #5
    func createAnswer(offer: [AnyHashable: Any], _ handler: @escaping([AnyHashable: Any]) -> Void) {
        ///
        self.createPeerConnection()
        
        guard let connection = connection else { return }

        connection.setRemoteDescription(RTCSessionDescription(fromJSONDictionary: offer)) { (error) in
            ///
            guard error == nil else {
                print("error while setting remote sdp: ", error!)
                return
            }
            
            let constraints = self.offerConstraints(receiveVideo: true,
                                                    receiveAudio: false)
            
            connection.answer(for: constraints) { (sdp, error) in
                ///
                guard error == nil, let sdp = sdp else {
                    print("error while creating local sdp: ", error!)
                    return
                }
                
                ///
                connection.setLocalDescription(sdp) { (error) in
                    ///
                    guard error == nil else {
                        print("error while setting local sdp: ", error!)
                        return
                    }
                    
                    if connection.signalingState == .stable {
                        handler(sdp.json())
                    }
                }
            }
        }
    }
    
    /// #6
    func receiveAnswer(_ answer: [AnyHashable: Any]) {
        ///
        guard let connection = connection else { return }
        
        connection.setRemoteDescription(RTCSessionDescription(fromJSONDictionary: answer)) { (error) in
            ///
            guard error == nil else {
                print("error while setting remote sdp: ", error!)
                return
            }
            
            if connection.signalingState == .stable {
                print("signaling completed")
            }
        }
    }
    
    /// #7 Send ICE
    func processICECandidate(_ iceCandidate: RTCIceCandidate) {
        ///
        SocketCallManager.shared.sendICE(iceCandidate.json(), label: iceCandidate.sdpMLineIndex)
    }
    
    /// #8 Receive ICE
    func receiveICECandidate(_ iceCandidate: [AnyHashable: Any]) {
        ///
        guard let connection = connection else { return }
        
        connection.add(RTCIceCandidate(fromJSONDictionary: iceCandidate))
    }
    
    /// #9 Send Frame
    func sendFrame(_ frame: CMSampleBuffer) {
        ///
        if let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(frame) {
            let timestamp = NSDate().timeIntervalSince1970 * 1000
            let rtcCvPixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
            let frame = RTCVideoFrame(buffer: rtcCvPixelBuffer, rotation: ._0, timeStampNs: Int64(timestamp))
            
            if let videoSource = self.videoSource, let capturer = self.capturer {
                videoSource.capturer(capturer, didCapture: frame)
            }
        }
    }
}




//MARK:- RTCPeerConnectionDelegate
extension WebRTCManager: RTCPeerConnectionDelegate {
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        ///
        switch stateChanged {
        case .haveLocalOffer:
            print("haveLocalOffer")
        case .haveRemoteOffer:
            print("haveRemoteOffer")
        case .closed:
            print("closed")
        case .stable:
            print("stable")
        default:
            print("undefined")
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("remote stream added")
        
        if stream.audioTracks.count > 0 {
          
        }
        
        if stream.videoTracks.count > 0 {
            
            self.remoteViedoTrack = stream.videoTracks.first
            self.remoteTrackHandler?(self.remoteViedoTrack!)
            delegate?.didAddRemoteStream(videoTrack: self.remoteViedoTrack!)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        
    }
    
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        switch newState {
        case .checking:
            print("")
        case .new:
            print("")
        case .connected:
            print("")
        case .completed:
            print("")
        default:
            print("undefined")
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        ///
        print("didGenerate candidate")
        
        self.processICECandidate(candidate)
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        
    }
    
}

//MARK:- Constraints
extension WebRTCManager {
    
    func offerConstraints(receiveVideo: Bool, receiveAudio:Bool) -> RTCMediaConstraints {
        
        var constraints: [String: String]? = [:]
        constraints?["OfferToReceiveAudio"] = receiveAudio ? "true" : "false"
        constraints?["OfferToReceiveVideo"] = receiveVideo ? "true" : "false"
        return RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: nil)
    }
}

