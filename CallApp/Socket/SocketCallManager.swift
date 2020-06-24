//
//  SocketCallManager.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 22/04/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import Foundation
import SocketIO


protocol SocketClientDelegate: class {
    func socketClient(_ client: SocketHelper, didChange state: SocketIOStatus)
    func socketClient(_ client: SocketHelper, didJoin room: String)
    func socketClientDidFail()
    func socketClientDidReceiveNewPeer()
    func socketClient(_ client: SocketHelper, didReceiveOffer offer: [AnyHashable: Any])
    func socketClient(_ client: SocketHelper, didReceiveAnswer answer: [AnyHashable: Any])
    func socketClient(_ client: SocketHelper, didReceiveICE candidate: [AnyHashable: Any])
}

class SocketCallManager {
    
    var callBackChat: ((NSDictionary?) -> Void)?
    var callBackTyping: (() -> (Void))?
    var callBackOnline: (() -> (Void))?
    var connectionStateHandler: ((SocketIOStatus)->Void)?
    var delegate: SocketClientDelegate?
    var opponentId: String?
    var roomId: String?

    static let shared: SocketCallManager = {
        let instance = SocketCallManager()
        return instance
    }()
    
    func startCall(roomId: String, _ connectionHandler: @escaping ()->()) {
        
        self.roomId = roomId
        
        SocketHelper.shared.callbackRegisterOnEvents = {
            
            self.registerReceivingEvents()
        }
        
        SocketHelper.shared.connect()

        SocketHelper.shared.connectionStateHandler = { state in
            
            switch state {
            case .connected:
                connectionHandler()
            default:
                break
            }
        }
    }
    
    func emit(key: String, data: HTTPParameters) {
        
        guard SocketHelper.shared.state == .connected else {
            print("socket is not connected, failed to Chat.")
            return
        }
        
        SocketHelper.shared.socket?.emit(key, data)
    }
    
    func registerReceivingEvents() {
        
        SocketHelper.shared.socket!.on("new_peer") { [unowned self] (data, _) in
            ///
            if let packet = data.first as? HTTPParameters,
                let socketId = packet["socketId"] as? String {
                self.opponentId = socketId
                
                /// #1 On new peer create offer
                WebRTCManager.shared.createOffer { [unowned self] (sdp) in
                    SocketHelper.shared.socket!.emit("send_offer", ["sdp": sdp,"room": self.roomId!, "socketId": self.opponentId!])
                }
            }
        }
        
        SocketHelper.shared.socket!.on("receive_offer") { [unowned self] (data, _) in
            ///
            if let packet = data.first as? HTTPParameters,
                let socketId = packet["socketId"] as? String {
                self.opponentId = socketId
                
                ///
                if let sdp = packet["sdp"] as? HTTPParameters {
                    /// #2 Accept offer and generate answer
                    WebRTCManager.shared.createAnswer(offer: sdp) { [unowned self] (answerSdp) in
                        SocketHelper.shared.socket!.emit("send_answer", ["sdp": answerSdp, "room": self.roomId!, "socketId": self.opponentId!])
                    }
                }
            }
        }
        
        SocketHelper.shared.socket!.on("receive_answer") { [unowned self] (data, _) in
            ///
            if let packet = data.first as? HTTPParameters,
                let socketId = packet["socketId"] as? String,
                self.opponentId == socketId {
                
                ///
                if let sdp = packet["sdp"] as? HTTPParameters {
                    /// #3 Accept answer
                    WebRTCManager.shared.receiveAnswer(sdp)
                }
            }
        }
        
        SocketHelper.shared.socket!.on("ice_candidate") { [unowned self] (data, _) in
            ///
            ///
            if let packet = data.first as? HTTPParameters,
                let socketId = packet["socketId"] as? String,
                self.opponentId == socketId {
                
                ///
                if let ice = packet["candidate"] as? HTTPParameters {
                    /// #3 Accept answer
                    WebRTCManager.shared.receiveICECandidate(ice)
                }
            }
        }
        
        SocketHelper.shared.socket?.connect()
    }
}

extension SocketCallManager {
    
    func sendOffer(_ offer: [AnyHashable: Any]) {
        
        SocketHelper.shared.socket!.emit("send_offer", ["sdp": offer, "room": self.roomId!, "socketId": self.opponentId!])
    }
    
    func sendAnswer(_ answer: [AnyHashable: Any]) {
        
        SocketHelper.shared.socket!.emit("send_answer", ["sdp": answer, "room": self.roomId!, "socketId": self.opponentId!])
    }
    
    func sendICE(_ ice: [AnyHashable: Any], label: Int32) {

        SocketHelper.shared.socket!.emit("ice_candidate", ["room":self.roomId!, "socketId": self.opponentId!, "label": label, "candidate": ice])
    }
}

