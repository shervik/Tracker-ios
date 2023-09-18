//
//  UIScheduleMarshalling.swift
//  Tracker
//
//  Created by Виктория Щербакова on 26.04.2023.
//

import Foundation

final class UIScheduleMarshalling {
    func convertToInt(_ days: Set<WeekDay>) -> String {
        var result = ""
        for weekday in days {
            result += String(weekday.rawValue)
        }
        return result
    }
    
    func convertToWeekday(_ numbersWeekday: String) -> Set<WeekDay> {
        var result = Set<WeekDay>()
        let array = numbersWeekday.compactMap { Int(String($0)) }

        for i in array {
            guard let day = WeekDay(rawValue: i) else { return result }
                result.insert(day)
        }
        return result
    }
}
