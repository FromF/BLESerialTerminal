//
//  BLEService.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import UIKit
import CoreBluetooth

class BLEService: NSObject {
    static let shared = BLEService()
    
    /// デバイス状態
    var state: CBManagerState {
        return centralManager.state
    }
    ///ペリフェラルスキャン中か？
    var isScanning:Bool {
        return centralManager.isScanning
    }
    ///CBCentralManagerのインスタンス
    private var centralManager: CBCentralManager!
    ///ペリフェラルスキャン結果通知先
    private var peripheralCallBack: ((PeripheralItem) -> Void)?
    ///接続済みのペリフェラル情報
    private var connectedPeripheral: CBPeripheral?
    ///WriteサービスのUUID
    private var writeServiceUUID: String?
    ///NotifyサービスのUUID
    private var notifyServiceUUID: String?
    ///Notifyサービスの通知結果
    private var notifyValueCallBack: ((String) -> Void)?
    ///Writeサービスのキャラスティック
    private var writeCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        
        let queue = DispatchQueue(label: "BLESerivice.swift")
        centralManager = CBCentralManager(delegate: self, queue: queue, options: nil)

    }
    
    // MARK: - ペリフェラルスキャン開始・終了
    /// ペリフェラルスキャン開始
    /// - Parameter peripheral: ペリフェラルスキャン結果
    func startScan(peripheral: @escaping (PeripheralItem) -> Void) {
        let result = self.state == .poweredOn ? true : false

        if result {
            // 重複して検出しない
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            // BLEデバイスの検出を開始
            self.centralManager.scanForPeripherals(withServices: nil, options: options)
            self.peripheralCallBack = peripheral
        }
    }
    
    
    /// ペリフェラルスキャン停止
    /// - Returns: 実行結果
    func stopScan() -> Bool {
        var result = self.state == .poweredOn ? true : false
        
        if result {
            if !self.isScanning {
                result = false
            }
        }
        
        if result {
            // BLEデバイスの検出を終了
            self.centralManager.stopScan()
            self.peripheralCallBack = nil
        }
        
        return result
    }

    // MARK: - ペリフェラルス接続・切断
    func connectPeripheral(peripheral: CBPeripheral, notifyUUID: String, writeUUID: String, notifyValue: @escaping (String) -> Void) -> Bool {
        let result = self.state == .poweredOn ? true : false
        
        if result {
            self.notifyValueCallBack = notifyValue
            self.notifyServiceUUID = notifyUUID
            self.writeServiceUUID = writeUUID
            centralManager.connect(peripheral, options: nil)
        }
        
        return result
    }
    
    func disconnectPeripheral() -> Bool {
        let result = self.state == .poweredOn ? true : false

        if result {
            if let _connectedPeripheral = connectedPeripheral {
                centralManager.cancelPeripheralConnection(_connectedPeripheral)
            }
        }
        
        return result
    }
    
    // MARK: - サービス検索
    /// Serviceの検索
    private func searchService() {
        guard let _connectedPeripheral = connectedPeripheral else {
            errorLog("Unwrap Error")
            return
        }
        
        _connectedPeripheral.delegate = self
        _connectedPeripheral.discoverServices(nil)
    }
    
    // MARK: - キャラクタリスティックのWrite
    func send(_ text: String) {
        guard let _connectedPeripheral = connectedPeripheral else {
            errorLog("Unwrap Error")
            return
        }
        guard let _writeCharacteristic = writeCharacteristic else {
            errorLog("Unwrap Error")
            return
        }
        guard let data = text.data(using: .utf8, allowLossyConversion: true) else {
            errorLog("Unwrap Error")
            return
        }
        
        _connectedPeripheral.writeValue(data, for: _writeCharacteristic, type: .withResponse)
    }
}

extension BLEService: CBCentralManagerDelegate {
    // MARK: - CBCentralManagerDelegate - デバイス起動時のdelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            debugLog("state \(central.state)");
            switch central.state {
            case .poweredOff:
                debugLog("Bluetoothの電源がOff")
            case .poweredOn:
                debugLog("Bluetoothの電源はOn")
            case .resetting:
                debugLog("レスティング状態")
            case .unauthorized:
                debugLog("非認証状態")
            case .unknown:
                debugLog("不明")
            case .unsupported:
                debugLog("非対応")
            @unknown default:
                fatalError()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate - ペリフェラルスキャン時のdelegate
    // BLEデバイスが検出された際に呼び出される.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        debugLog("\(peripheral.name ?? "no name") \(peripheral.identifier.uuidString) \(RSSI)")
        debugLog(" \(advertisementData)")
        
        let kCBAdvDataLocalName = advertisementData["kCBAdvDataLocalName"] as? String
        
        let peripheralItem = PeripheralItem(uuid: peripheral.identifier.uuidString,
                                            name: kCBAdvDataLocalName ?? peripheral.name ?? "no name",
                                            peripheral: peripheral,
                                            rssi: RSSI)
        DispatchQueue.main.async {
            self.peripheralCallBack?(peripheralItem)
        }
    }

}

extension BLEService: CBPeripheralDelegate {
    // MARK: - CBCentralManagerDelegate - ペリフェラル接続/切断時のdelegate
    // Peripheralに接続
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugLog("Connect")
        
        // 接続済みのペリフェラルを保存する
        self.connectedPeripheral = peripheral
        
        DispatchQueue.main.async {
            // サービスの検索開始
            self.searchService()
        }
    }
    
    // Peripheralに接続失敗した際
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        } else {
            errorLog("Not Connect")
        }
    }
    
    // Peripheralの切断
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugLog("Disconnect")
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        }
        
        // 接続済みのペリフェラルを初期化する
        self.connectedPeripheral = nil
        self.writeServiceUUID = nil
        self.notifyServiceUUID = nil
        self.notifyValueCallBack = nil
        self.writeCharacteristic = nil
    }

    // MARK: - CBPeripheralDelegate - サービス検索時のdelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        debugLog("didDiscoverServices")
        
        if let services = peripheral.services {
            for service in services {
                debugLog(service.uuid.uuidString)
                self.connectedPeripheral?.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // MARK: - CBPeripheralDelegate - キャラクタリスティック検索時のdelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        } else if let characteristics = service.characteristics {
            for characteristic in characteristics {
                debugLog(characteristic.uuid.uuidString)
                if let writeServiceUUID = self.writeServiceUUID,
                   characteristic.uuid.uuidString == writeServiceUUID {
                    self.writeCharacteristic = characteristic
                }
                if let notifyServiceUUID = self.notifyServiceUUID,
                   characteristic.uuid.uuidString == notifyServiceUUID {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    // MARK: - CBPeripheralDelegate - キャラクタリスティックRead/Write時のdelegate
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        } else if let value = characteristic.value {
            DispatchQueue.main.async {
                if let string = String(data: value, encoding: .utf8) {
                    let characteristicString = string
                    debugLog("\(characteristicString)")
                    self.notifyValueCallBack?(characteristicString)
                } else {
                    let characteristicString = "\(value)"
                    debugLog("\(characteristicString)")
                    self.notifyValueCallBack?(characteristicString)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if let e = error {
            errorLog("Error: \(e.localizedDescription)")
        } else {
            debugLog("success")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        debugLog("Notify状態更新")
    }
}
