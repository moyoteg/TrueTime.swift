//
//  NTPExtensionsSpec.swift
//  TrueTime
//
//  Created by Michael Sanders on 7/18/16.
//  Copyright © 2016 Instacart. All rights reserved.
//

@testable import TrueTime
import Nimble
import Quick
import SwiftCheck

final class NTPExtensionsSpec: QuickSpec {
    override func spec() {
        it("NTP.Time64") {
            property("Matches timeval precision") <- forAll(timeval.arbitraryPositive) { time in
                let ntp = NTP.Time64(timeSince1970: time)
                return ntp.milliseconds == time.milliseconds
            }
        }
    }
}
