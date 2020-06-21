//
//  RTCSessionDescription.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 06/03/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

private let kRTCSessionDescriptionTypeKey = "type"
private let kRTCSessionDescriptionSdpKey = "sdp"

extension RTCSessionDescription {
    
    convenience init?(fromJSONDictionary dictionary: [AnyHashable : Any]) {
        let typeString = dictionary[kRTCSessionDescriptionTypeKey] as? String
        let type = RTCSessionDescription.self.type(for: typeString!)
        let sdp = dictionary[kRTCSessionDescriptionSdpKey] as? String
        self.init(type: type, sdp: sdp!)
    }
    
    func jsonData() -> Data? {
        let type = RTCSessionDescription.string(for: self.type)
        
        let json = [
            kRTCSessionDescriptionTypeKey: type,
            kRTCSessionDescriptionSdpKey: sdp
        ]
        
        return try? JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    func json() -> [AnyHashable : Any]  {
        let type = RTCSessionDescription.string(for: self.type)
        
        let json = [
            kRTCSessionDescriptionTypeKey: type,
            kRTCSessionDescriptionSdpKey: sdp
        ]
        
        return json
    }
}
