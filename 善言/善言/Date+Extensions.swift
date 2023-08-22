//
//  Date+Extensions.swift
//  AxisContribution
//
//  Created by jasu on 2022/02/22.
//  Copyright (c) 2022 jasu All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import SwiftUI

extension Date {
    static func datesWeekly(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 7, to: date) else { break }
            date = newDate.startOfWeek
        }
        return dates
    }

        func toInt() -> Int {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: self)
            let year = components.year ?? 0
            let month = components.month ?? 0
            let day = components.day ?? 0
            return year * 10000 + month * 100 + day
        }
        
        static func fromInt(_ value: Int) -> Date {
            let year = value / 10000
            let month = (value % 10000) / 100
            let day = value % 100
            
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return Calendar.current.date(from: components) ?? Date()
        }
    

    var dateYearAgo: Date {
        var components = DateComponents()
        components.year = -1
        guard let date = Calendar.current.date(byAdding: components, to: startOfDay) else { return Date() }
        return date
    }
    
    var dateMonthAgo: Date {
        var components = DateComponents()
        components.month = -1
        guard let date = Calendar.current.date(byAdding: components, to: startOfDay) else { return Date() }
        return date
    }
    
    var datesInWeek: [Date] {
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = Calendar.current.date(byAdding: .weekday, value: i, to: startOfWeek) {
                dates.append(date)
            }
        }
        return dates
    }
    
    var isToday: Bool {
        let currentDate = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let today = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        return currentDate == today
    }
    
    var yesterday: Date {
        var components = DateComponents()
        components.day = -1
        guard let date = Calendar.current.date(byAdding: components, to: startOfDay) else { return Date() }
        return date
    }
    var startOfMonth: Date {
           let calendar = Calendar.current
           let components = calendar.dateComponents([.year, .month], from: self)
           return calendar.date(from: components) ?? self
       }
    var endOfNextMonth: Date {
         let calendar = Calendar.current
         let twoMonthsLaterStartDate = calendar.date(byAdding: .month, value: 2, to: self.startOfMonth) ?? self
         let oneDayBeforeTwoMonthsLater = calendar.date(byAdding: .day, value: -1, to: twoMonthsLaterStartDate) ?? self
         
         return oneDayBeforeTwoMonthsLater
     }
    var endOfMonth: Date {
            let calendar = Calendar.current
            let nextMonthStartDate = calendar.date(byAdding: .month, value: 1, to: self.startOfMonth) ?? self
            let oneDayBeforeNextMonth = calendar.date(byAdding: .day, value: -1, to: nextMonthStartDate) ?? self
            
            return oneDayBeforeNextMonth
        }
    var startOfYear: Date {
           let calendar = Calendar.current
           var components = calendar.dateComponents([.year], from: self)
           components.month = 1
           components.day = 1
           return calendar.date(from: components) ?? self
       }

       var endOfYear: Date {
           let calendar = Calendar.current
           var components = calendar.dateComponents([.year], from: self)
           components.month = 12
           components.day = 31
           return calendar.date(from: components) ?? self
       }
    var tomorrow: Date {
        var components = DateComponents()
        components.day = 1
        guard let date = Calendar.current.date(byAdding: components, to: startOfDay) else { return Date() }
        return date
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfWeek: Date {
        let current = Calendar.current
        let monday = current.date(from: current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return monday!
    }
    
    var day: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self)
        return components.day ?? 1
    }
    
    var monthTitle: String {
        let calendar = Calendar.current
        let monthTitles = calendar.shortMonthSymbols
        let components = calendar.dateComponents([.month], from: self)
        let month = components.month
        return monthTitles[month! - 1]
    }
}
extension Date {
    static func randomBetween(start: Date, end: Date) -> Date {
        var date1 = start
        var date2 = end
        if date2 < date1 {
            let temp = date1
            date1 = date2
            date2 = temp
        }
        let span = TimeInterval.random(in: date1.timeIntervalSinceNow...date2.timeIntervalSinceNow)
        return Date(timeIntervalSinceNow: span)
    }

    var dateHalfAyear: Date {
        var components = DateComponents()
        components.month = -6
        guard let date = Calendar.current.date(byAdding: components, to: startOfDay) else { return Date() }
        return date
    }
}
