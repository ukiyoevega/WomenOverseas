//
//  Date+Extension.swift
//  WMO
//
//  Created by weijia on 2022/5/29.
//

import Foundation
import UIKit

extension Date {
    static let dateFormatter: DateFormatter = DateFormatter()
    
    var dateStringWithAgo: String {
        let calendar = Calendar.current
        let now = Date()
        
        let diff = calendar.dateComponents([.month, .day, .hour, .minute], from: self, to: now)
        let monthsDiff = diff.month ?? 0
        let daysDiff = diff.day ?? 0
        let hoursDiff = diff.hour ?? 0
        let minutesDiff = diff.minute ?? 0

        if monthsDiff >= 1 || daysDiff >= 10 { // if longer than 10 days
            if calendar.isDate(self, equalTo: now, toGranularity: .year) {
                return self.generateDateString(of: "MM/dd") + "更新"
            } else {
                return self.exactDateString + "更新"
            }
        } else { // if within 10 days
            // 1. if daysDiff >= 1, aka >= 24 hours
            if daysDiff >= 1 {
                return "\(daysDiff)天前更新"
                
            // 2. if within 24 hours, and hoursDiff >= 1
            } else if hoursDiff >= 1 {
                return "\(hoursDiff)小时前更新"
                
            // 3. if within 1 hour, but minutes diff >= 1
            } else if minutesDiff >= 1 {
                return "\(minutesDiff)分钟前更新"
            } else {
                return "刚刚更新"
            }
        }
    }

    public var exactDateString: String {
        return self.generateDateString(of: "yyyy/MM/dd")
    }

    func generateDateString(of dateFormat: String) -> String {
        let formatter = Date.dateFormatter
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}