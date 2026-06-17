//
//  TFYSwiftEasyBlueToothTests.swift
//  TFYSwiftEasyBlueToothTests
//
//  Created by 田风有 on 2022/6/9.
//

import XCTest
@testable import TFYSwiftEasyBlueTooth

class TFYSwiftEasyBlueToothTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let sections = TFYSwiftFeatureDemoCatalog.sections

        XCTAssertEqual(sections.count, 5)
        XCTAssertEqual(sections.map(\.title), ["基础配置", "扫描连接", "设备探索", "数据通信", "工具能力"])
        XCTAssertTrue(sections.flatMap(\.items).contains { $0.title == "扫描并连接设备" })
        XCTAssertTrue(sections.flatMap(\.items).contains { $0.title == "描述读写" })
        XCTAssertTrue(sections.flatMap(\.items).contains { $0.title == "Hex/Data 工具" })
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
