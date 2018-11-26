//
//  DateFormatterHelper.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

enum DateFormatterType: String {
    case `default` = "yyyy-MM-dd HH:mm:ss ZZZZZ",
    weekDay = "EEEE",
    hourMinute = "HH:mm",
    ddMMyyyy = "dd/MM/yyyy",
    weekDayMonthDayHHmm = "EEE MMM d, HH:mm"
}

final class DateFormatterHelper {
    fileprivate static let formatter = DateFormatter()
    
    static func convertToDate(from string: String, with type: DateFormatterType = .default) -> Date? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        formatter.dateFormat = type.rawValue
        
        return formatter.date(from: string)
    }
    
    static func convertToString(from date: Date, with type: DateFormatterType = .default) -> String {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        formatter.dateFormat = type.rawValue
        
        return formatter.string(from: date)
    }
    
    // MARK: - Custom
    static func messageString(from date: Date) -> String {
        let currentDate = Date()
        let startOfCurrentWeek = currentDate.mondayOfWeek
        let startOfCurrentDay = currentDate.startOfDay
        let startOfCurrentDayDiff = date.timeIntervalSince(startOfCurrentDay)
        
        if startOfCurrentDayDiff > 0 {
            return "Today".localized + " " + convertToString(from: date, with: .hourMinute)
        }
        
        let startOfCurrentWeekDiff = date.timeIntervalSince(startOfCurrentWeek)
        
        if startOfCurrentWeekDiff > 0 {
            return convertToString(from: date, with: .weekDay) + " " + convertToString(from: date, with: .hourMinute)
        }
        
        return convertToString(from: date, with: .weekDayMonthDayHHmm)
    }
}
