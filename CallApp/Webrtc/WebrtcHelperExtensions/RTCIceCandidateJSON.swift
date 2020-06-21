//
//  RTCIceCandidateJSON.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 06/03/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//


private let kRTCICECandidateTypeKey = "type"
private let kRTCICECandidateTypeValue = "candidate"
private let kRTCICECandidateMidKey = "id"
private let kRTCICECandidateMLineIndexKey = "label"
private let kRTCICECandidateSdpKey = "candidate"


extension RTCIceCandidate {
    convenience init?(fromJSONDictionary dictionary: [AnyHashable : Any]?) {
        let mid = dictionary?[kRTCICECandidateMidKey] as? String
        let sdp = (dictionary?[kRTCICECandidateSdpKey] as? String)!
        let num = dictionary?[kRTCICECandidateMLineIndexKey] as? NSNumber

        let mLineIndex = num?.intValue ?? 0
        self.init(sdp: sdp, sdpMLineIndex: Int32(mLineIndex), sdpMid: mid)
    }
    
    func jsonData() -> Data? {
        let json = [
            kRTCICECandidateTypeKey: kRTCICECandidateTypeValue,
            kRTCICECandidateMLineIndexKey: NSNumber(value: sdpMLineIndex),
            kRTCICECandidateMidKey: sdpMid ?? "",
            kRTCICECandidateSdpKey: sdp
            ] as [String : Any]

        let error: Error? = nil
        var data: Data? = nil
        do {
            data = try JSONSerialization.data(
                withJSONObject: json,
                options: .prettyPrinted)
        } catch {
        }
        if error != nil {
            if let error = error {
                print("Error serializing JSON: \(error)")
            }
            return nil
        }

        return data
    }
    
    func json() -> [AnyHashable : Any]? {
        let json = [
            kRTCICECandidateTypeKey: kRTCICECandidateTypeValue,
            kRTCICECandidateMLineIndexKey: NSNumber(value: sdpMLineIndex),
            kRTCICECandidateMidKey: sdpMid ?? "",
            kRTCICECandidateSdpKey: sdp
            ] as [String : Any]

        return json
    }
}
