//
//  SocketChatManager.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 22/04/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import Foundation

class SocketChatManager {
    
    var callBackChat: ((NSDictionary?) -> Void)?
    var callBackTyping: (() -> (Void))?
    var callBackOnline: (() -> (Void))?
    
    static let shared: SocketChatManager = {
        let instance = SocketChatManager()
        return instance
    }()
    
    func startChat(id: String) {
        SocketHelper.shared.connect()
        registerReceivingEvents()
    }
    
    func sendMessage(data: HTTPParameters) {
        
        guard SocketHelper.shared.state == .connected else {
            print("socket is not connected, failed to Chat.")
            return
        }
        
        SocketHelper.shared.socket?.emit("chat", data)
    }
    
    func registerReceivingEvents() {
        
        SocketHelper.shared.socket?.on("message") { (dataArray, socketAck) in
            print(dataArray)
            let chatDict = dataArray[0] as? NSDictionary
            self.callBackChat?(chatDict)
        }
        
        SocketHelper.shared.socket?.on("typing") { (dataTyping, Ack) in
            print("dataTyping:->\(dataTyping)")
        }
    }
    
    public func startTyping(args: [String: Any]) {
        if SocketHelper.shared.state != .connected {
            print("socket is not connected, failed to typing.")
            return
        }
        
        SocketHelper.shared.socket?.emit("typing", args)
    }
    
    func endChat() {
        
    }
}
