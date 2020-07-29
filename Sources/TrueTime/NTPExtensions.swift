//
//  NTPExtensions.swift
//  TrueTime
//
//  Created by Michael Sanders on 7/10/16.
//  Copyright © 2016 Instacart. All rights reserved.
//

import Foundation

public extension timeval {
    static func uptime() -> timeval {
        let now = timeval.now()
        var boottime = timeval()
        var mib: [CInt] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout.stride(ofValue: boottime)
        withFatalErrno { sysctl(&mib, 2, &boottime, &size, nil, 0) }
        return timeval(tv_sec: now.tv_sec - boottime.tv_sec, tv_usec: now.tv_usec - boottime.tv_usec)
    }

    var milliseconds: Int64 {
        return Int64(tv_sec) * Int64(MSEC_PER_SEC) + Int64(tv_usec) / Int64(USEC_PER_MSEC)
    }
}

extension timeval {
    static func now() -> timeval {
        var tv = timeval()
        withFatalErrno { gettimeofday(&tv, nil) }
        return tv
    }
}

// Represents an amount of time since the NTP epoch, January 1, 1900.
// https://en.wikipedia.org/wiki/Network_Time_Protocol#Timestamps
protocol NTPTimeType {
    associatedtype ValueType: UnsignedInteger
    init(whole: ValueType, fraction: ValueType)
    var whole: ValueType { get }
    var fraction: ValueType { get }
}

protocol NTPTimevalConvertible: NTPTimeType {}

extension NTPTimeType {
    // Interprets the receiver as an elapsed time in milliseconds.
    var durationInMilliseconds: Int64 {
        return Int64(whole) * Int64(MSEC_PER_SEC) +
               fractionInMicroseconds / Int64(USEC_PER_MSEC)
    }

    var fractionInMicroseconds: Int64 {
        return Int64(fraction) / Int64(1<<32 / USEC_PER_SEC)
    }
}

extension NTPTimevalConvertible {
    init(timeSince1970 time: timeval) {
        precondition(time.tv_sec >= 0 && time.tv_usec >= 0, "Time must be positive \(time)")
        self.init(whole: ValueType(UInt64(time.tv_sec) + UInt64(secondsFrom1900To1970)),
                  fraction: ValueType(UInt64(time.tv_usec) * UInt64(1<<32 / USEC_PER_SEC)))
    }

    var milliseconds: Int64 {
        return (Int64(whole) - secondsFrom1900To1970) * Int64(MSEC_PER_SEC) +
                fractionInMicroseconds / Int64(USEC_PER_MSEC)
    }
}

extension NTP.Time32: NTPTimeType {}
extension NTP.Time64: NTPTimevalConvertible {}

extension TimeInterval {
    init(milliseconds: Int64) {
        self = Double(milliseconds) / Double(MSEC_PER_SEC)
    }

    init(_ timestamp: timeval) {
        self = Double(timestamp.tv_sec) + Double(timestamp.tv_usec) / Double(USEC_PER_SEC)
    }
}

protocol ByteRepresentable {
//    init()
}

extension ByteRepresentable {
    var data: Data {
        var buffer = self
        return Data(bytes: &buffer, count: MemoryLayout.size(ofValue: buffer))
    }
}

extension NTP.Packet: ByteRepresentable {}
extension sockaddr_in: ByteRepresentable {}
extension sockaddr_in6: ByteRepresentable {}
extension sockaddr_in6: CustomStringConvertible {
    public var description: String {
        var buffer = [Int8](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        var addr = sin6_addr
        inet_ntop(AF_INET6, &addr, &buffer, socklen_t(INET6_ADDRSTRLEN))

        let host = String(cString: buffer)
        let port = Int(sin6_port)
        return "\(host):\(port)"
    }
}

extension sockaddr_in: CustomStringConvertible {
    public var description: String {
        let host = String(cString: inet_ntoa(sin_addr))
        let port = Int(sin_port)
        return "\(host):\(port)"
    }
}

extension HostResolver: CustomStringConvertible {
    var description: String {
        return "\(type(of: self))(host: \(host), port: \(port) timeout: \(timeout))"
    }
}

extension NTPConnection: CustomStringConvertible {
    var description: String {
        return "\(type(of: self))(socketAddress: \(address), " +
                                 "timeout: \(timeout), " +
                                 "maxRetries: \(maxRetries))"
    }
}

extension FrozenNetworkTime: CustomStringConvertible {
    var description: String {
        return "\(type(of: self))(time: \(time), " +
                                 "uptime: \(uptime.milliseconds) ms, " +
                                 "serverResponse: \(serverResponse), " +
                                 "startTime: \(startTime.milliseconds) ms, " +
                                 "sampleSize: \((sampleSize ?? 0)), " +
                                 "host: \(host ?? "nil"))"
    }
}

extension NTPResponse: CustomStringConvertible {
    var description: String {
        return "\(type(of: self))(packet: \(packet.description), " +
                                 "responseTime: \(responseTime) ms, " +
                                 "receiveTime: \(receiveTime.milliseconds) ms)"
    }
}

extension NTP.Packet: CustomStringConvertible {
    public var description: String {
        let referenceTime = reference_time?.milliseconds
        let originateTime = originate_time?.milliseconds
        let receiveTime = receive_time?.milliseconds
        let transmitTime = transmit_time?.milliseconds
        return """
        \(type(of: self))
        client_mode: \(client_mode.description)
        "version_number: \(version_number.description)
        leap_indicator: \(String(describing: leap_indicator?.description))
        stratum: \(String(describing: stratum?.description))
        poll: \(String(describing: poll?.description))
        precision: \(String(describing: precision?.description))
        root_delay: \(String(describing: root_delay))
        root_dispersion: \(String(describing: root_dispersion))
        reference_id: \(String(describing: reference_id))
        reference_time: \(String(describing: referenceTime)) ms
        originate_time: \(String(describing: originateTime)) ms
        receive_time: \(String(describing: receiveTime)) ms
        transmit_time: \(String(describing: transmitTime)) ms
        """
    }
}

extension NTP.Packet {
    var timeDescription: String {
        return """
        \(type(of: self))
        reference_time: + \(String(describing: reference_time?.milliseconds)) ms 
        originate_time: \(String(describing: originate_time?.milliseconds)) ms
        receive_time: \(String(describing: receive_time?.milliseconds)) ms
        transmit_time: \(String(describing: transmit_time?.milliseconds)) ms
        """
    }
}

extension String {
    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: "", table: "TrueTime")
    }
}

extension TrueTimeError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cannotFindHost: return "The connection failed because the host could not be found.".localized
        case .dnsLookupFailed: return "The connection failed because the DNS lookup failed.".localized
        case .timedOut: return "The connection timed out.".localized
        case .offline: return "The connection failed because the device is not connected to the internet.".localized
        case .badServerResponse: return "The connection received an invalid server response.".localized
        case .noValidPacket: return "No valid NTP packet was found.".localized
        }
    }
}

extension NSError {
    convenience init(errno code: Int32) {
        var userInfo: [String: AnyObject]?
        if let description = String(validatingUTF8: strerror(code)) {
            userInfo = [NSLocalizedDescriptionKey: description as AnyObject]
        }
        self.init(domain: NSPOSIXErrorDomain, code: Int(code), userInfo: userInfo)
    }

    convenience init(trueTimeError: TrueTimeError) {
        self.init(domain: TrueTimeErrorDomain, code: trueTimeError.rawValue, userInfo: [
            NSLocalizedDescriptionKey: trueTimeError.description
        ])
    }
}

func withErrno<X: SignedInteger>(_ block: () -> X) throws -> X {
    let result = block()
    if result < 0 {
        throw NSError(errno: errno)
    }
    return result
}

// Equivalent to `withErrno` but asserts at runtime.
// Useful when `errno` can only be used to indicate programmer error.
@discardableResult
func withFatalErrno<X: SignedInteger>(_ block: () -> X) -> X {
    // swiftlint:disable force_try
    return try! withErrno(block)
    // swiftlint:enable force_try
}

// Number of seconds between Jan 1, 1900 and Jan 1, 1970
// 70 years plus 17 leap days
private let secondsFrom1900To1970: Int64 = ((365 * 70) + 17) * 24 * 60 * 60

// swiftlint:disable identifier_name
let MSEC_PER_SEC: UInt64 = 1000
let USEC_PER_MSEC: UInt64 = 1000
// swiftlint:enable identifier_name
