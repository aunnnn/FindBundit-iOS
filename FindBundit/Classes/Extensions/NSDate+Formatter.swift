//
//  NSDate+Formatter.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/9/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Foundation

extension NSDate {
    struct Formatter {
        static let iso8601: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            return formatter
        }()
        
        static let readable: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMM dd yyyy (hh:mm a)"
            formatter.locale = NSLocale(localeIdentifier: "en")
            formatter.timeZone = NSTimeZone.localTimeZone()
            return formatter
        }()
    }
    var iso8601: String { return Formatter.iso8601.stringFromDate(self) }
    
    var readable: String { return Formatter.readable.stringFromDate(self) }
}

extension String {
    var dateFromISO8601: NSDate? {
        return NSDate.Formatter.iso8601.dateFromString(self)
    }
}