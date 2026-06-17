//
//  TFYSwiftMineController.swift
//  TFYSwiftEasyBlueTooth
//
//  Created by 田风有 on 2022/6/15.
//  Copyright © 2022 TFYSwift. All rights reserved.
//

import UIKit
import CoreBluetooth
import TFYProgressSwiftHUD

enum TFYSwiftFeatureDemoAction {
    case managerOptions
    case bluetoothState
    case scanAll
    case scanByName
    case scanByRule
    case scanAndConnectByName
    case connectByIdentifier
    case disconnectAll
    case readRSSI
    case discoverServices
    case discoverCharacteristics
    case discoverDescriptors
    case characteristicReadWrite
    case notifyOn
    case notifyOff
    case descriptorReadWrite
    case hexDataTools
    case signalTools
    case retryAsyncTools
}

struct TFYSwiftFeatureDemoItem {
    let title:String
    let detail:String
    let action:TFYSwiftFeatureDemoAction
}

struct TFYSwiftFeatureDemoSection {
    let title:String
    let items:[TFYSwiftFeatureDemoItem]
}

enum TFYSwiftFeatureDemoCatalog {
    static let sections:[TFYSwiftFeatureDemoSection] = [
        TFYSwiftFeatureDemoSection(title: "基础配置", items: [
            TFYSwiftFeatureDemoItem(title: "管理器配置", detail: "扫描超时、连接超时、自动重连、扫描选项", action: .managerOptions),
            TFYSwiftFeatureDemoItem(title: "蓝牙状态检查", detail: "读取当前蓝牙可用性和状态说明", action: .bluetoothState)
        ]),
        TFYSwiftFeatureDemoSection(title: "扫描连接", items: [
            TFYSwiftFeatureDemoItem(title: "扫描全部设备", detail: "按当前扫描配置收集附近设备", action: .scanAll),
            TFYSwiftFeatureDemoItem(title: "按名称扫描", detail: "输入设备名称关键字，找到第一个匹配设备", action: .scanByName),
            TFYSwiftFeatureDemoItem(title: "按规则扫描", detail: "演示名称以 BLE- 开头的自定义扫描规则", action: .scanByRule),
            TFYSwiftFeatureDemoItem(title: "扫描并连接设备", detail: "按名称扫描到设备后立即连接", action: .scanAndConnectByName),
            TFYSwiftFeatureDemoItem(title: "Identifier 连接", detail: "使用已保存的外设 UUID 直接连接", action: .connectByIdentifier),
            TFYSwiftFeatureDemoItem(title: "断开全部设备", detail: "主动断开当前管理器下所有连接", action: .disconnectAll)
        ]),
        TFYSwiftFeatureDemoSection(title: "设备探索", items: [
            TFYSwiftFeatureDemoItem(title: "读取 RSSI", detail: "读取当前连接设备信号强度", action: .readRSSI),
            TFYSwiftFeatureDemoItem(title: "发现服务", detail: "列出当前设备全部服务 UUID", action: .discoverServices),
            TFYSwiftFeatureDemoItem(title: "发现特征", detail: "列出服务下的特征和属性", action: .discoverCharacteristics),
            TFYSwiftFeatureDemoItem(title: "发现描述", detail: "列出特征下的描述 UUID 和值", action: .discoverDescriptors)
        ]),
        TFYSwiftFeatureDemoSection(title: "数据通信", items: [
            TFYSwiftFeatureDemoItem(title: "特征读写", detail: "使用默认 UUID 演示写入和读取", action: .characteristicReadWrite),
            TFYSwiftFeatureDemoItem(title: "开启通知", detail: "订阅默认通知特征", action: .notifyOn),
            TFYSwiftFeatureDemoItem(title: "取消通知", detail: "取消默认通知特征订阅", action: .notifyOff),
            TFYSwiftFeatureDemoItem(title: "描述读写", detail: "读取或写入默认特征下的描述", action: .descriptorReadWrite)
        ]),
        TFYSwiftFeatureDemoSection(title: "工具能力", items: [
            TFYSwiftFeatureDemoItem(title: "Hex/Data 工具", detail: "十六进制、字节数组、截取、反转转换", action: .hexDataTools),
            TFYSwiftFeatureDemoItem(title: "RSSI 与地址工具", detail: "信号等级、距离估算、蓝牙地址格式化", action: .signalTools),
            TFYSwiftFeatureDemoItem(title: "重试与异步工具", detail: "重试管理器、主线程/后台/延迟执行", action: .retryAsyncTools)
        ])
    ]
}

class TFYSwiftMineController: UIViewController {

    private lazy var tableView: UITableView = {
        let tab = UITableView(frame: CGRect.zero, style: .grouped)
        tab.showsHorizontalScrollIndicator = false
        tab.contentInsetAdjustmentBehavior = .never
        tab.rowHeight = 80
        tab.estimatedSectionFooterHeight = 0.01
        tab.estimatedSectionHeaderHeight = 0.01
        tab.backgroundColor = .white
        tab.delegate = self
        tab.dataSource = self
        return tab
    }()
    
    private lazy var bleManager: TFYSwIFTEasyBlueToothManager = {
        let manage = TFYSwIFTEasyBlueToothManager.shareInstance
        let options:TFYSwiftEasyManagerOptions = TFYSwiftEasyManagerOptions(queue: DispatchQueue.main)
        options.scanTimeOut = 6
        options.connectTimeOut = 10
        options.autoConnectAfterDisconnect = true
        manage.managerOptions = options
        return manage
    }()

    private var currentPeripheral:TFYSwiftEasyPeripheral?
    private var retryManager:TFYBluetoothRetryManager?
    private let sections = TFYSwiftFeatureDemoCatalog.sections
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "功能演示"
        configureBluetoothStateCallback()
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    deinit {
        bleManager.disconnectAllPeripheral()
    }
}

extension TFYSwiftMineController: UITableViewDelegate,UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let withIdentifier:String = "feature-demo-cell"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: withIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: withIdentifier)
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
            cell?.detailTextLabel?.numberOfLines = 2
        }
        let item = sections[indexPath.section].items[indexPath.row]
        cell?.textLabel?.text = item.title
        cell?.detailTextLabel?.text = item.detail
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        perform(action: sections[indexPath.section].items[indexPath.row].action)
    }
}

private extension TFYSwiftMineController {

    func configureBluetoothStateCallback() {
        bleManager.bluetoothStateChanged = { [weak self] peripheral, state in
            DispatchQueue.main.async {
                if let peripheral = peripheral {
                    self?.currentPeripheral = peripheral
                }
                print("蓝牙状态: \(state), 设备: \(peripheral?.name ?? "无")")
            }
        }
    }

    func perform(action:TFYSwiftFeatureDemoAction) {
        switch action {
        case .managerOptions:
            showManagerOptions()
        case .bluetoothState:
            checkBluetoothStatus()
        case .scanAll:
            scanAllDevices()
        case .scanByName:
            scanDeviceByName()
        case .scanByRule:
            scanDeviceByRule()
        case .scanAndConnectByName:
            scanAndConnectByName()
        case .connectByIdentifier:
            connectByIdentifier()
        case .disconnectAll:
            bleManager.disconnectAllPeripheral()
            currentPeripheral = nil
            TFYProgressSwiftHUD.showSucceed("已断开全部设备")
        case .readRSSI:
            readRSSI()
        case .discoverServices:
            discoverServices()
        case .discoverCharacteristics:
            discoverCharacteristics()
        case .discoverDescriptors:
            discoverDescriptors()
        case .characteristicReadWrite:
            showCharacteristicReadWrite()
        case .notifyOn:
            setNotifyValue(true)
        case .notifyOff:
            setNotifyValue(false)
        case .descriptorReadWrite:
            showDescriptorReadWrite()
        case .hexDataTools:
            showHexDataTools()
        case .signalTools:
            showSignalTools()
        case .retryAsyncTools:
            showRetryAsyncTools()
        }
    }

    func showManagerOptions() {
        let options = bleManager.managerOptions
        let serviceUUIDs = options?.scanServiceArray?.map { $0.uuidString }.joined(separator: "\n") ?? "不限制服务"
        showResult(title: "管理器配置", message: """
        扫描超时: \(options?.scanTimeOut ?? 0) 秒
        连接超时: \(options?.connectTimeOut ?? 0) 秒
        自动重连: \((options?.autoConnectAfterDisconnect ?? false) ? "开启" : "关闭")
        配置有效: \((options?.validateOptions() ?? false) ? "是" : "否")
        扫描服务:
        \(serviceUUIDs)
        """)
    }
    
    func checkBluetoothStatus() {
        let isAvailable = TFYBluetoothUtils.isBluetoothAvailable()
        let stateDescription = TFYBluetoothUtils.getBluetoothStateDescription()
        
        showResult(title: "蓝牙状态", message: """
        蓝牙可用: \(isAvailable ? "是" : "否")
        状态: \(stateDescription)
        """)
    }

    func scanAllDevices() {
        TFYProgressSwiftHUD.show("正在扫描...")
        bleManager.scanAllDeviceWithRule(rule: nil) { [weak self] deviceArray, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                self?.currentPeripheral = deviceArray.first
                self?.showDeviceList(title: "扫描全部设备", devices: deviceArray, error: error)
            }
        }
    }

    func scanDeviceByName() {
        showInputAlert(title: "按名称扫描", message: "输入设备名称关键字", placeholder: "BLE", defaultValue: "BLE") { [weak self] name in
            TFYProgressSwiftHUD.show("正在扫描...")
            self?.bleManager.scanDeviceWithName(name: name) { peripheral, error in
                DispatchQueue.main.async {
                    TFYProgressSwiftHUD.dismiss()
                    self?.currentPeripheral = peripheral
                    self?.showSingleDevice(title: "按名称扫描", peripheral: peripheral, error: error)
                }
            }
        }
    }

    func scanDeviceByRule() {
        TFYProgressSwiftHUD.show("正在扫描 BLE- 设备...")
        bleManager.scanAllDeviceWithRule { peripheral in
            return peripheral.name?.hasPrefix("BLE-") ?? false
        } callback: { [weak self] deviceArray, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                self?.currentPeripheral = deviceArray.first
                self?.showDeviceList(title: "按规则扫描", devices: deviceArray, error: error)
            }
        }
    }

    func scanAndConnectByName() {
        showInputAlert(title: "扫描并连接设备", message: "输入设备名称关键字", placeholder: "BLE-GUC2_9876", defaultValue: "BLE-GUC2_9876") { [weak self] name in
            TFYProgressSwiftHUD.show("正在扫描并连接...")
            self?.bleManager.scanAndConnectDeviceWithName(name: name) { peripheral, error in
                DispatchQueue.main.async {
                    TFYProgressSwiftHUD.dismiss()
                    self?.currentPeripheral = peripheral
                    self?.showSingleDevice(title: "扫描并连接设备", peripheral: peripheral, error: error)
                }
            }
        }
    }

    func connectByIdentifier() {
        showInputAlert(title: "Identifier 连接", message: "输入已保存的设备 UUID", placeholder: "设备 UUID", defaultValue: "5E40E1BC-732E-042E-7C56-9F89D59FB0E8") { [weak self] identifier in
            TFYProgressSwiftHUD.show("正在连接...")
            self?.bleManager.connectDeviceWithIdentifier(identifier: identifier) { peripheral, error in
                DispatchQueue.main.async {
                    TFYProgressSwiftHUD.dismiss()
                    self?.currentPeripheral = peripheral
                    self?.showSingleDevice(title: "Identifier 连接", peripheral: peripheral, error: error)
                }
            }
        }
    }

    func readRSSI() {
        guard let peripheral = requireCurrentPeripheral() else { return }
        TFYProgressSwiftHUD.show("正在读取 RSSI...")
        bleManager.readRSSIWithPeripheral(peripheral: peripheral) { [weak self] peripheral, RSSI, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                if let error = error {
                    self?.showResult(title: "读取 RSSI", message: error.localizedDescription)
                } else {
                    self?.showResult(title: "读取 RSSI", message: "\(peripheral.name ?? "未知设备")\nRSSI: \(RSSI)")
                }
            }
        }
    }

    func discoverServices() {
        guard let peripheral = requireCurrentPeripheral() else { return }
        TFYProgressSwiftHUD.show("正在发现服务...")
        peripheral.discoverAllDeviceServiceWithCallback { [weak self] _, serviceArray, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                if let error = error {
                    self?.showResult(title: "发现服务", message: error.localizedDescription)
                } else {
                    let message = serviceArray.map { "\($0.UUID.uuidString)  \($0.isEnabled ? "可用" : "不可用")" }.joined(separator: "\n")
                    self?.showResult(title: "发现服务", message: message.isEmpty ? "没有发现服务" : message)
                }
            }
        }
    }

    func discoverCharacteristics() {
        guard let peripheral = requireCurrentPeripheral() else { return }
        TFYProgressSwiftHUD.show("正在发现特征...")
        peripheral.discoverAllDeviceServiceWithCallback { [weak self] _, serviceArray, error in
            if let error = error {
                DispatchQueue.main.async {
                    TFYProgressSwiftHUD.dismiss()
                    self?.showResult(title: "发现特征", message: error.localizedDescription)
                }
                return
            }
            let group = DispatchGroup()
            var lines:[String] = []
            for service in serviceArray {
                group.enter()
                service.discoverCharacteristicWithCharacteristicUUIDs { characteristics, _ in
                    lines.append("服务 \(service.UUID.uuidString)")
                    characteristics.forEach { lines.append("  \($0.name ?? "未知特征")  \($0.propertiesString)") }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                TFYProgressSwiftHUD.dismiss()
                self?.showResult(title: "发现特征", message: lines.isEmpty ? "没有发现特征" : lines.joined(separator: "\n"))
            }
        }
    }

    func discoverDescriptors() {
        guard let peripheral = requireCurrentPeripheral() else { return }
        TFYProgressSwiftHUD.show("正在发现描述...")
        peripheral.discoverAllDeviceServiceWithCallback { [weak self] _, serviceArray, error in
            if let error = error {
                DispatchQueue.main.async {
                    TFYProgressSwiftHUD.dismiss()
                    self?.showResult(title: "发现描述", message: error.localizedDescription)
                }
                return
            }
            let group = DispatchGroup()
            var lines:[String] = []
            for service in serviceArray {
                group.enter()
                service.discoverCharacteristicWithCharacteristicUUIDs { characteristics, _ in
                    let innerGroup = DispatchGroup()
                    for characteristic in characteristics {
                        innerGroup.enter()
                        characteristic.discoverDescriptorWithCallback { descriptors, _ in
                            descriptors.forEach { lines.append("\(characteristic.name ?? "未知特征") -> \($0.UUID?.uuidString ?? "未知描述")") }
                            innerGroup.leave()
                        }
                    }
                    innerGroup.notify(queue: .main) {
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                TFYProgressSwiftHUD.dismiss()
                self?.showResult(title: "发现描述", message: lines.isEmpty ? "没有发现描述" : lines.joined(separator: "\n"))
            }
        }
    }

    func showCharacteristicReadWrite() {
        guard requireCurrentPeripheral() != nil else { return }
        let alert = UIAlertController(title: "特征读写", message: "使用默认服务和特征 UUID 演示", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "写入默认数据", style: .default) { [weak self] _ in
            self?.writeDefaultCharacteristic()
        })
        alert.addAction(UIAlertAction(title: "读取默认特征", style: .default) { [weak self] _ in
            self?.readDefaultCharacteristic()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    func writeDefaultCharacteristic() {
        guard let peripheral = requireCurrentPeripheral(),
              let data = "22HY63475E15".bluehexDataStrict() ?? "22HY63475E15".blueheadecimal() else { return }
        TFYProgressSwiftHUD.show("正在写入...")
        bleManager.writeDataWithPeripheral(peripheral: peripheral, serviceUUID: UUID_SERVICE, writeUUID: UUID_WRITE, data: data) { [weak self] value, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                self?.showOperationResult(title: "写入默认数据", value: value, error: error)
            }
        }
    }

    func readDefaultCharacteristic() {
        guard let peripheral = requireCurrentPeripheral() else { return }
        TFYProgressSwiftHUD.show("正在读取...")
        bleManager.readValueWithPeripheral(peripheral: peripheral, serviceUUID: UUID_SERVICE, readUUID: UUID_WRITE) { [weak self] value, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                self?.showOperationResult(title: "读取默认特征", value: value, error: error)
            }
        }
    }

    func setNotifyValue(_ enabled:Bool) {
        guard let peripheral = requireCurrentPeripheral() else { return }
        TFYProgressSwiftHUD.show(enabled ? "正在开启通知..." : "正在取消通知...")
        bleManager.notifyDataWithPeripheral(peripheral: peripheral, serviceUUID: UUID_SERVICE, notifyUUID: UUID_NOTIFICATION, notifyValue: enabled) { [weak self] value, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                self?.showOperationResult(title: enabled ? "开启通知" : "取消通知", value: value, error: error)
            }
        }
    }

    func showDescriptorReadWrite() {
        guard requireCurrentPeripheral() != nil else { return }
        let alert = UIAlertController(title: "描述读写", message: "使用默认服务和特征 UUID 演示", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "读取描述", style: .default) { [weak self] _ in
            self?.readDefaultDescriptor()
        })
        alert.addAction(UIAlertAction(title: "写入描述", style: .default) { [weak self] _ in
            self?.writeDefaultDescriptor()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    func readDefaultDescriptor() {
        guard let peripheral = requireCurrentPeripheral() else { return }
        TFYProgressSwiftHUD.show("正在读取描述...")
        bleManager.readDescriptorWithPeripheral(peripheral: peripheral, serviceUUID: UUID_SERVICE, characterUUID: UUID_WRITE) { [weak self] value, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                self?.showOperationResult(title: "读取描述", value: value, error: error)
            }
        }
    }

    func writeDefaultDescriptor() {
        guard let peripheral = requireCurrentPeripheral(),
              let data = "0100".bluehexDataStrict() else { return }
        TFYProgressSwiftHUD.show("正在写入描述...")
        bleManager.writeDescriptorWithPeripheral(peripheral: peripheral, serviceUUID: UUID_SERVICE, characterUUID: UUID_WRITE, data: data) { [weak self] value, error in
            DispatchQueue.main.async {
                TFYProgressSwiftHUD.dismiss()
                self?.showOperationResult(title: "写入描述", value: value, error: error)
            }
        }
    }

    func showHexDataTools() {
        let hex = "48:65-6C 6C6F"
        let data = hex.bluehexDataStrict() ?? Data()
        let bytes = data.toByteArray()
        let rebuilt = Data.fromByteArray(bytes)
        showResult(title: "Hex/Data 工具", message: """
        原始 Hex: \(hex)
        严格解析: \(data.bluehexString())
        文本: \(String(data: data, encoding: .utf8) ?? "")
        字节数组: \(bytes)
        反转: \(data.reversedBytes().bluehexString())
        截取 1,2: \(data.subdata(from: 1, length: 2)?.bluehexString() ?? "")
        数组还原: \(rebuilt.bluehexString())
        UUID 有效: \("1800".isValidUUID() ? "是" : "否")
        地址有效: \("AA:BB:CC:DD:EE:FF".isValidBluetoothAddress() ? "是" : "否")
        """)
    }

    func showSignalTools() {
        let rssi = NSNumber(value: -62)
        showResult(title: "RSSI 与地址工具", message: """
        RSSI: \(rssi)
        信号等级: \(TFYBluetoothUtils.calculateSignalStrength(rssi: rssi))
        估算距离: \(String(format: "%.2f", TFYBluetoothUtils.calculateDistance(rssi: rssi))) 米
        地址格式化: \(TFYBluetoothUtils.formatBluetoothAddress("aabbccddeeff"))
        字节转 Hex: \(TFYBluetoothUtils.bytesToHexString([0x0A, 0xFF]))
        Hex 转字节: \(TFYBluetoothUtils.hexStringToBytes("0A:FF") ?? [])
        """)
    }

    func showRetryAsyncTools() {
        let retryManager = TFYBluetoothRetryManager(maxRetryCount: 2, retryDelay: 0.2)
        self.retryManager = retryManager
        var attempts = 0
        retryManager.executeWithRetry { (completion: @escaping (Result<String, Error>) -> Void) in
            attempts += 1
            if attempts < 2 {
                completion(.failure(NSError(domain: "演示失败后重试", code: -1)))
            } else {
                completion(.success("第 \(attempts) 次尝试成功"))
            }
        } onSuccess: { [weak self] (value: String) in
            TFYSwiftAsynce.mainAsync {
                self?.retryManager = nil
                self?.showResult(title: "重试与异步工具", message: "\(value)\n后台/主线程工具可通过 TFYSwiftAsynce 调用。")
            }
        } onFailure: { [weak self] error in
            TFYSwiftAsynce.mainAsync {
                self?.retryManager = nil
                self?.showResult(title: "重试与异步工具", message: error.localizedDescription)
            }
        }
    }

    func requireCurrentPeripheral() -> TFYSwiftEasyPeripheral? {
        guard let peripheral = currentPeripheral else {
            showResult(title: "需要设备", message: "请先完成扫描并连接设备，再使用这个功能。")
            return nil
        }
        guard peripheral.state == .connected else {
            showResult(title: "设备未连接", message: "当前设备: \(peripheral.name ?? "未知设备")\n请先连接设备。")
            return nil
        }
        return peripheral
    }

    func showDeviceList(title:String, devices:[TFYSwiftEasyPeripheral], error:Error?) {
        if let error = error {
            showResult(title: title, message: error.localizedDescription)
            return
        }
        let message = devices.enumerated().map { index, peripheral in
            "\(index + 1). \(peripheral.name ?? "未知设备")\n   UUID: \(peripheral.identifierString ?? "")\n   RSSI: \(peripheral.RSSI?.stringValue ?? "-")"
        }.joined(separator: "\n")
        showResult(title: title, message: message.isEmpty ? "没有发现设备" : message)
    }

    func showSingleDevice(title:String, peripheral:TFYSwiftEasyPeripheral?, error:Error?) {
        if let error = error {
            showResult(title: title, message: error.localizedDescription)
            return
        }
        guard let peripheral = peripheral else {
            showResult(title: title, message: "没有返回设备")
            return
        }
        showResult(title: title, message: """
        名称: \(peripheral.name ?? "未知设备")
        UUID: \(peripheral.identifierString ?? "")
        状态: \(peripheral.state.rawValue)
        RSSI: \(peripheral.RSSI?.stringValue ?? "-")
        """)
    }

    func showOperationResult(title:String, value:Any?, error:Error?) {
        if let error = error {
            showResult(title: title, message: error.localizedDescription)
            return
        }
        if let data = value as? Data {
            showResult(title: title, message: data.bluehexString())
        } else if let value = value {
            showResult(title: title, message: "\(value)")
        } else {
            showResult(title: title, message: "操作完成")
        }
    }

    func showInputAlert(title:String, message:String, placeholder:String, defaultValue:String, completion:@escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = defaultValue
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            let text = alert.textFields?.first?.text ?? ""
            if text.isEmpty {
                self.showResult(title: title, message: "输入不能为空")
            } else {
                completion(text)
            }
        })
        present(alert, animated: true)
    }

    func showResult(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
