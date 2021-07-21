//
//  BleViewModel.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import Foundation
import CoreBluetooth

class BleViewModel: ObservableObject {
    @Published var recivedText: String = ""
    
    private let bleSerivce = BLEService.shared
    private var writeServiceUUID: String {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: UserDefaultsKeyWriteServiceUUID) ?? DefaultWriteServiceUUID
        }
    }
    private var notifyServiceUUID: String {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: UserDefaultsKeyNotifyServiceUUID) ?? DefaultNotifyServiceUUID
        }
    }
    
    func connect(peripheral: CBPeripheral) {
        _ = bleSerivce.connectPeripheral(peripheral: peripheral, notifyUUID: notifyServiceUUID, writeUUID: writeServiceUUID) { recivedText in
            DispatchQueue.main.async {
                self.recivedText += recivedText
            }
        }
    }
    
    func disconnect() {
        _ = bleSerivce.disconnectPeripheral()
    }
    
    func send(_ text: String) {
        bleSerivce.send(text)
    }
}
