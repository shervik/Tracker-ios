//
//  Tracker.swift
//  Tracker
//
//  Created by Виктория Щербакова on 30.03.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
    let isPin: Bool
}
