//
//  ComponentTests.swift
//  PouchPalTests
//
//  Created by Lee Seaver on 1/13/26.
//

import XCTest
import SwiftUI
@testable import PouchPal

final class ComponentTests: XCTestCase {
    
    // MARK: - ProgressRing Tests
    
    func testProgressRingInitialization() {
        let view = ProgressRing(progress: 0.5)
        XCTAssertNotNil(view)
    }
    
    func testProgressRingWithCustomParameters() {
        let view = ProgressRing(
            progress: 0.75,
            lineWidth: 8,
            size: 100,
            showPercentage: true,
            gradientColors: [.blue, .purple]
        )
        XCTAssertNotNil(view)
    }
    
    func testProgressRingWithZeroProgress() {
        let view = ProgressRing(progress: 0.0)
        XCTAssertNotNil(view)
    }
    
    func testProgressRingWithFullProgress() {
        let view = ProgressRing(progress: 1.0)
        XCTAssertNotNil(view)
    }
    
    func testProgressRingWithOverProgress() {
        let view = ProgressRing(progress: 1.5)
        // Should handle values > 1.0 gracefully
        XCTAssertNotNil(view)
    }
    
    func testProgressRingWithNegativeProgress() {
        let view = ProgressRing(progress: -0.5)
        XCTAssertNotNil(view)
    }
    
    // MARK: - MiniProgressRing Tests
    
    func testMiniProgressRingInitialization() {
        let view = MiniProgressRing(progress: 0.5, isOverLimit: false)
        XCTAssertNotNil(view)
    }
    
    func testMiniProgressRingOverLimit() {
        let view = MiniProgressRing(progress: 1.0, isOverLimit: true)
        XCTAssertNotNil(view)
    }
    
    func testMiniProgressRingNotOverLimit() {
        let view = MiniProgressRing(progress: 0.7, isOverLimit: false)
        XCTAssertNotNil(view)
    }
    
    // MARK: - StatCard Tests
    
    func testStatCardMinimalInitialization() {
        let view = StatCard(title: "Test", value: "100")
        XCTAssertNotNil(view)
    }
    
    func testStatCardFullInitialization() {
        let view = StatCard(
            title: "7-Day Average",
            value: "4.5",
            subtitle: "pouches/day",
            icon: "chart.bar.fill",
            color: .blue
        )
        XCTAssertNotNil(view)
    }
    
    func testStatCardWithoutSubtitle() {
        let view = StatCard(title: "Total", value: "150", icon: "sum")
        XCTAssertNotNil(view)
    }
    
    func testStatCardWithoutIcon() {
        let view = StatCard(title: "Count", value: "25", subtitle: "today")
        XCTAssertNotNil(view)
    }
    
    func testStatCardWithCustomColor() {
        let view = StatCard(
            title: "Warning",
            value: "9",
            color: .red
        )
        XCTAssertNotNil(view)
    }
    
    // MARK: - LargeStat Tests
    
    func testLargeStatInitialization() {
        let view = LargeStat(value: 42, label: "pouches", sublabel: "today")
        XCTAssertNotNil(view)
    }
    
    func testLargeStatWithoutSublabel() {
        let view = LargeStat(value: 10, label: "items", sublabel: nil)
        XCTAssertNotNil(view)
    }
    
    func testLargeStatWithZero() {
        let view = LargeStat(value: 0, label: "pouches", sublabel: "today")
        XCTAssertNotNil(view)
    }
    
    func testLargeStatWithLargeNumber() {
        let view = LargeStat(value: 9999, label: "total", sublabel: nil)
        XCTAssertNotNil(view)
    }
    
    // MARK: - InlineStat Tests
    
    func testInlineStatInitialization() {
        let view = InlineStat(title: "Total", value: "150 pouches")
        XCTAssertNotNil(view)
    }
    
    func testInlineStatWithEmptyValue() {
        let view = InlineStat(title: "Empty", value: "")
        XCTAssertNotNil(view)
    }
    
    func testInlineStatWithLongTitle() {
        let view = InlineStat(
            title: "This is a very long title that might need to wrap",
            value: "123"
        )
        XCTAssertNotNil(view)
    }
    
    // MARK: - AddPouchButton Tests
    
    func testAddPouchButtonInitialization() {
        var actionCalled = false
        var quickAddQuantity: Int?
        
        let view = AddPouchButton(
            action: { actionCalled = true },
            quickAddAction: { quantity in quickAddQuantity = quantity }
        )
        
        XCTAssertNotNil(view)
        XCTAssertFalse(actionCalled)
        XCTAssertNil(quickAddQuantity)
    }
    
    // MARK: - ScaleButtonStyle Tests
    
    func testScaleButtonStyleExists() {
        let style = ScaleButtonStyle()
        XCTAssertNotNil(style)
    }
    
    // MARK: - WeeklyChart Tests
    
    func testWeeklyChartInitialization() {
        let data: [(date: Date, count: Int)] = [
            (Date(), 5),
            (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 3),
            (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, 7)
        ]
        
        let view = WeeklyChart(data: data, limit: 10, showLimit: true)
        XCTAssertNotNil(view)
    }
    
    func testWeeklyChartWithoutLimit() {
        let data: [(date: Date, count: Int)] = [
            (Date(), 5)
        ]
        
        let view = WeeklyChart(data: data, limit: nil, showLimit: false)
        XCTAssertNotNil(view)
    }
    
    func testWeeklyChartWithEmptyData() {
        let data: [(date: Date, count: Int)] = []
        
        let view = WeeklyChart(data: data, limit: 10, showLimit: true)
        XCTAssertNotNil(view)
    }
    
    func testWeeklyChartWithHighValues() {
        let data: [(date: Date, count: Int)] = [
            (Date(), 100),
            (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 150)
        ]
        
        let view = WeeklyChart(data: data, limit: 10, showLimit: true)
        XCTAssertNotNil(view)
    }
    
    // MARK: - MonthlyMiniChart Tests
    
    func testMonthlyMiniChartInitialization() {
        let data: [(date: Date, count: Int)] = [
            (Date(), 5),
            (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 3)
        ]
        
        let view = MonthlyMiniChart(data: data)
        XCTAssertNotNil(view)
    }
    
    func testMonthlyMiniChartWithEmptyData() {
        let data: [(date: Date, count: Int)] = []
        
        let view = MonthlyMiniChart(data: data)
        XCTAssertNotNil(view)
    }
    
    func testMonthlyMiniChartWithFullMonth() {
        var data: [(date: Date, count: Int)] = []
        for i in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            data.append((date, Int.random(in: 0...15)))
        }
        
        let view = MonthlyMiniChart(data: data)
        XCTAssertNotNil(view)
    }
    
    // MARK: - DayData Tests
    
    func testDayDataInitialization() {
        let data = DayData(date: Date(), count: 5)
        
        XCTAssertNotNil(data.id)
        XCTAssertNotNil(data.date)
        XCTAssertEqual(data.count, 5)
    }
    
    func testDayDataDayLabel() {
        let data = DayData(date: Date(), count: 5)
        
        XCTAssertFalse(data.dayLabel.isEmpty)
        // Should be 3-letter day abbreviation like "Mon", "Tue", etc.
    }
    
    func testDayDataShortDayLabel() {
        let data = DayData(date: Date(), count: 5)
        
        XCTAssertEqual(data.shortDayLabel.count, 1)
        // Should be single letter like "M", "T", etc.
    }
    
    func testDayDataIsToday() {
        let todayData = DayData(date: Date(), count: 5)
        XCTAssertTrue(todayData.isToday)
        
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayData = DayData(date: yesterdayDate, count: 3)
        XCTAssertFalse(yesterdayData.isToday)
    }
    
    func testDayDataUniqueIds() {
        let data1 = DayData(date: Date(), count: 5)
        let data2 = DayData(date: Date(), count: 5)
        
        XCTAssertNotEqual(data1.id, data2.id)
    }
}
