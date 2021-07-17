//
//  StartViewModel.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import Foundation

class StartViewModel: ObservableObject {
    @Published var peripherals: [PeripheralItem] = []
    
    private let bleSerivce = BLESerivice.shared
    private var scanTimerHandler : Timer?
    private let scanTimerTimeOut = 2.0

    func startScan() {
        self.bleSerivce.startScan { peripheralItem in
            DispatchQueue.main.async {
                self.peripherals.append(peripheralItem)
            }
        }
        scanTimerHandler = Timer.scheduledTimer(withTimeInterval: scanTimerTimeOut, repeats: false) { _ in
            _ = self.bleSerivce.stopScan()
        }
    }
}

