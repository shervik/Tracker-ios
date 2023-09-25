//
//  Date+Extensions.swift
//  Tracker
//
//  Created by Виктория Щербакова on 20.09.2023.
//

import Foundation

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}
