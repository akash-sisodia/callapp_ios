/*
 *  Copyright 2014 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "RTCICECandidate+JSON.h"

static NSString const *kRTCICECandidateTypeKey = @"type";
static NSString const *kRTCICECandidateTypeValue = @"candidate";
static NSString const *kRTCICECandidateMidKey = @"id";
static NSString const *kRTCICECandidateMLineIndexKey = @"label";
static NSString const *kRTCICECandidateSdpKey = @"candidate";

@implementation RTCIceCandidate (JSON)

+ (RTCIceCandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary
{
    NSString *mid = dictionary[kRTCICECandidateMidKey];
    NSString *sdp = dictionary[kRTCICECandidateSdpKey];
    NSNumber *num = dictionary[kRTCICECandidateMLineIndexKey];
    
    int mLineIndex = [num intValue];
    return [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:mLineIndex sdpMid:mid];
}

- (NSData *)JSONData
{
    NSDictionary *json = @{
                           kRTCICECandidateTypeKey : kRTCICECandidateTypeValue,
                           kRTCICECandidateMLineIndexKey : @(self.sdpMLineIndex),
                           kRTCICECandidateMidKey : self.sdpMid,
                           kRTCICECandidateSdpKey : self.sdp
                           };
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:json
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (error) {
        NSLog(@"Error serializing JSON: %@", error);
        return nil;
    }
    
    return data;
}

- (NSDictionary *)JSON
{
    NSDictionary *json = @{
                           kRTCICECandidateTypeKey : kRTCICECandidateTypeValue,
                           kRTCICECandidateMLineIndexKey : @(self.sdpMLineIndex),
                           kRTCICECandidateMidKey : self.sdpMid,
                           kRTCICECandidateSdpKey : self.sdp
                           };
    
    return json;
}

@end