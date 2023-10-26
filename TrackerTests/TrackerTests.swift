//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Виктория Щербакова on 26.10.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewControllerLight() {
        let vc = TabBarController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testViewControllerDark() {
        let vc = TabBarController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
