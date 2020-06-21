//
//  SocketHelper.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 22/04/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import SocketIO
import Foundation
import Starscream

class SocketHelper {
    
    private var socketManager: SocketManager?
    var socket: SocketIOClient?
    var connectionStateHandler: ((SocketIOStatus)->Void)?
    var callbackRegisterOnEvents: (()->Void)?
    var state: SocketIOStatus = .disconnected
    
    let socketUrl = "http://192.168.43.12:3000/"
    
    static let shared: SocketHelper = {
        let instance = SocketHelper()
        return instance
    }()
    
    func connect() {
        initializeClient()
    }
    
    func emit(_ data: [String: Any]) {
        guard let client = socket, client.status == .connected else {
            print("tried to emit when socket is not connected")
            return
        }
        
        client.emit("message", data)
    }
    
    func connectionStateLabel() -> String {
        switch state {
        case .connected:
            return "Connected"
            
        case .connecting:
            return "Connecting"
            
        case .disconnected:
            return "Disconnected"
            
        case .notConnected:
            return "Disconnected"
        }
    }
    
    func connectionStateColor() -> UIColor {
        switch state {
        case .connected:
            return .green
            
        case .connecting:
            return .yellow
            
        case .disconnected:
            return .red
            
        case .notConnected:
            return .red
        }
    }
    
    private func initializeClient() {
        
        guard socketManager == nil else { return }
        
        if let url = URL(string: socketUrl)  {
            
            socketManager = SocketManager(socketURL: url, config: [.log(false), .compress, .reconnects(true), .forceNew(true), .reconnectWait(5), .reconnectAttempts(-1)])
            socket = socketManager!.defaultSocket
            callbackRegisterOnEvents!()
            socket?.on(clientEvent: .connect) { [unowned self] (_, _) in
                print("socket connect")
                
                self.socket?.emit("register", ["sender_id": "2", "receiver_id": "1"])
            }
            
            socket?.on(clientEvent: .statusChange) { [unowned self] (data, _) in
                print("socket status changed: \(data)")
                self.state = data[0] as! SocketIOStatus
                
                if let callback = self.connectionStateHandler {
                    callback(self.state)
                }
            }
            
            socket?.on(clientEvent: .disconnect) { (_, _) in
                print("socket disconnect")
            }
        }
    }
    
    func disconnect() -> Void {
        guard socketManager != nil else {
            return
        }
        socketManager!.disconnect()
        socketManager = nil
        socket = nil
    }
}
