//
//  NTP.swift
//  TrueTime
//
//  Created by Moi Gutierrez on 7/29/20.
//

import Foundation

/*
 This is the C struct that was converted to Swift
 
 #ifndef NTP_TYPES_H
 #define NTP_TYPES_H

 #include <stdint.h>

 typedef struct {
     uint16_t whole;
     uint16_t fraction;
 } __attribute__((packed, aligned(1))) ntp_time32_t;

 typedef struct {
     uint32_t whole;
     uint32_t fraction;
 } __attribute__((packed, aligned(1))) ntp_time64_t;

 typedef ntp_time64_t ntp_time_t;

 typedef struct {
     uint8_t client_mode: 3;
     uint8_t version_number: 3;
     uint8_t leap_indicator: 2;

     uint8_t stratum;
     uint8_t poll;
     uint8_t precision;

     ntp_time32_t root_delay;
     ntp_time32_t root_dispersion;
     uint8_t reference_id[4];

     ntp_time_t reference_time;
     ntp_time_t originate_time;
     ntp_time_t receive_time;
     ntp_time_t transmit_time;
 } __attribute__((packed, aligned(1))) ntp_packet_t;

 #endif /* NTP_TYPES_H */
 */

enum NTP {
    
    struct Time32 {
        let whole: UInt16, fraction: UInt16
    }
    
    struct Time64 {
        let whole: UInt32, fraction: UInt32
    }
    
    struct Packet {
        
        let client_mode: UInt8
        let version_number: UInt8
        var leap_indicator: UInt8?
        var stratum: UInt8?
        var poll: UInt8?
        var precision: UInt8?
        var root_delay: Time32?
        var root_dispersion: Time32?
        var reference_id: UInt8?
        var reference_time: Time64?
        var originate_time: Time64?
        var receive_time: Time64?
        var transmit_time: Time64?
        
        public init(
            client_mode: UInt8 = 3,
            version_number: UInt8 = 3,
            leap_indicator: UInt8? = 2,
            stratum: UInt8?,
            poll: UInt8?,
            precision: UInt8?,
            root_delay: Time32?,
            root_dispersion: Time32?,
            reference_id: UInt8?,
            reference_time: Time64?,
            originate_time: Time64?,
            receive_time: Time64?,
            transmit_time: Time64?
        ) {
            self.client_mode = client_mode
            self.version_number = version_number
            self.leap_indicator = leap_indicator
            self.stratum = stratum
            self.poll = poll
            self.precision = precision
            self.root_delay = root_delay
            self.root_dispersion = root_dispersion
            self.reference_id = reference_id
            self.reference_time = reference_time
            self.originate_time = originate_time
            self.receive_time = receive_time
            self.transmit_time = transmit_time
        }
        
        public init(time: NTP.Time64) {
            client_mode = 3
            version_number = 3
            transmit_time = time
        }
    }
}
