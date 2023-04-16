//
//  WeekDay.swift
//  Tracker
//
//  Created by Виктория Щербакова on 05.04.2023.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    static var allCases: [WeekDay] { [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday] }
    
    var fullName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресение"
        }
    }
    
    var cutName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
