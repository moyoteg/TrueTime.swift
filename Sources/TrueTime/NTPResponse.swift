//
//  NTPResponse.swift
//  TrueTime
//
//  Created by Michael Sanders on 10/14/16.
//  Copyright © 2016 Instacart. All rights reserved.
//

import Foundation

struct NTPResponse {

    private static let maxRootDispersion: Int64 = 100
    private static let maxDelayDelta: Int64 = 100
    private static let ntpModeServer: UInt8 = 4
    private static let leapIndicatorUnknown: UInt8 = 3
    
    let packet: NTP.Packet
    
    let responseTime: Int64
    
    let receiveTime: timeval
    
    let delay: Int64
    
    let offsetValues: [Int64]
    
    let offset: Int64
    
    let networkDate: Date
    
    init?(packet: NTP.Packet, responseTime: Int64, receiveTime: timeval = .now()) {
        self.packet = packet
        self.responseTime = responseTime
        self.receiveTime = receiveTime
      
        guard let stratum = packet.stratum,
            let root_dispersion = packet.root_dispersion,
            let root_delay = packet.root_delay,
            let leap_indicator = packet.leap_indicator,
            let originate_time = packet.originate_time
            else {
                print("NTPResponse: could not get all values needed")
                return nil
        }
        
        guard let offsetValues = NTPResponse.offsetValues(packet: packet, responseTime: responseTime) else {
            print("NTPResponse: could not get offset values")
            return nil
        }
        
        self.offsetValues = offsetValues
        
        self.delay = NTPResponse.delay(offsetValues: self.offsetValues)
        
        self.offset = NTPResponse.offset(offsetValues: self.offsetValues)
        
        self.networkDate = NTPResponse.networkDate(responseTime: self.responseTime, offset: self.offset)
        guard stratum > 0 && stratum < 16 &&
            root_delay.durationInMilliseconds < NTPResponse.maxRootDispersion &&
               root_dispersion.durationInMilliseconds < NTPResponse.maxRootDispersion &&
               packet.client_mode == NTPResponse.ntpModeServer &&
               leap_indicator != NTPResponse.leapIndicatorUnknown &&
               abs(receiveTime.milliseconds - originate_time.milliseconds - delay) < NTPResponse.maxDelayDelta
            else {
                print("NTPResponse: invalid response")
                return nil
        }
    }

    static func offsetValues(packet: NTP.Packet, responseTime: Int64) -> [Int64]? {
        guard let originate_time = packet.originate_time,
            let receive_time = packet.receive_time,
            let transmit_time = packet.transmit_time
            else {
                print("NTPResponse: ccould not get all values needed")
                return nil
        }
        return [originate_time.milliseconds,
                receive_time.milliseconds,
                transmit_time.milliseconds,
                responseTime]
    }
    
    // See https://en.wikipedia.org/wiki/Network_Time_Protocol#Clock_synchronization_algorithm
    static func offset(offsetValues: [Int64]) -> Int64 {
        return ((offsetValues[1] - offsetValues[0]) + (offsetValues[2] - offsetValues[3])) / 2
    }

    static func delay(offsetValues: [Int64]) -> Int64 {
        return (offsetValues[3] - offsetValues[0]) - (offsetValues[2] - offsetValues[1])
    }

    static func networkDate(responseTime: Int64, offset: Int64) -> Date {
        let interval = TimeInterval(milliseconds: responseTime + offset)
        return Date(timeIntervalSince1970: interval)
    }
}
