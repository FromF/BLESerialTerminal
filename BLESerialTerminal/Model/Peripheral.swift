//
//  Peripheral.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import Foundation
import CoreBluetooth

struct PeripheralItem : Identifiable {
    let id = UUID()
    let uuid: String
    let name: String
    let peripheral: CBPeripheral
    let rssi: NSNumber
}
