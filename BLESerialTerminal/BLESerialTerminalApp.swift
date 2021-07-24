//
//  BLESerialTerminalApp.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import SwiftUI

@main
struct BLESerialTerminalApp: App {
    init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            UserDefaultsKeyServiceUUID: DefaultServiceUUID,
            UserDefaultsKeyWriteServiceUUID : DefaultWriteServiceUUID,
            UserDefaultsKeyNotifyServiceUUID : DefaultNotifyServiceUUID,
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}
