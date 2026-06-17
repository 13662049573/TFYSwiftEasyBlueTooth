import XCTest
@testable import TFYSwiftEasyBlueToothKit

final class TFYSwiftEasyBlueToothKitTests: XCTestCase {
    
    func testHexStringConversionKeepsExistingBehavior() {
        let data = "48656C6C6F".blueheadecimal()
        
        XCTAssertEqual(data?.bluehexString(), "48656C6C6F")
        XCTAssertEqual(String(data: data ?? Data(), encoding: .utf8), "Hello")
    }
    
    func testStrictHexDataRejectsInvalidInput() {
        XCTAssertEqual("48:65-6C 6C6F".bluehexDataStrict()?.bluehexString(), "48656C6C6F")
        XCTAssertNil("123".bluehexDataStrict())
        XCTAssertNil("ZZ".bluehexDataStrict())
    }
    
    func testDataByteHelpers() {
        let bytes: [UInt8] = [0x01, 0x02, 0xFE]
        let data = Data.fromByteArray(bytes)
        
        XCTAssertEqual(data.toByteArray(), bytes)
        XCTAssertEqual(data.reversedBytes().toByteArray(), [0xFE, 0x02, 0x01])
        XCTAssertEqual(data.subdata(from: 1, length: 2)?.toByteArray(), [0x02, 0xFE])
        XCTAssertNil(data.subdata(from: 2, length: 5))
    }
    
    func testBluetoothUtilityFormattingAndSignalStrength() {
        XCTAssertEqual(TFYBluetoothUtils.formatBluetoothAddress("aabbccddeeff"), "AA:BB:CC:DD:EE:FF")
        XCTAssertEqual(TFYBluetoothUtils.formatBluetoothAddress("AA-BB-CC-DD-EE-FF"), "AA:BB:CC:DD:EE:FF")
        XCTAssertEqual(TFYBluetoothUtils.calculateSignalStrength(rssi: NSNumber(value: -45)), 4)
        XCTAssertEqual(TFYBluetoothUtils.calculateSignalStrength(rssi: NSNumber(value: -85)), 0)
        XCTAssertEqual(TFYBluetoothUtils.bytesToHexString([0x0A, 0xFF]), "0AFF")
        XCTAssertEqual(TFYBluetoothUtils.hexStringToBytes("0A:FF"), [0x0A, 0xFF])
    }
    
    func testManagerOptionsValidation() {
        let options = TFYSwiftEasyManagerOptions(queue: nil)
        XCTAssertTrue(options.validateOptions())
        
        options.scanTimeOut = 0
        XCTAssertFalse(options.validateOptions())
        
        options.scanTimeOut = 10
        options.connectTimeOut = 0
        XCTAssertFalse(options.validateOptions())
    }
}
