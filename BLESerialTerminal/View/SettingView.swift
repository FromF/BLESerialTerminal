//
//  SettingView.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import SwiftUI

struct SettingView: View {
    @AppStorage(UserDefaultsKeyWriteServiceUUID) var writeServiceUUID: String = DefaultWriteServiceUUID
    @AppStorage(DefaultNotifyServiceUUID) var notifyServiceUUID: String = DefaultNotifyServiceUUID
    var body: some View {
        List() {
            Section(header: Text("Characteristic UUID RX")) {
                TextField("Characteristic UUID RX", text: $writeServiceUUID, onCommit: {
                    if writeServiceUUID.count == 0 {
                        writeServiceUUID = DefaultWriteServiceUUID
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
            .textCase(nil)
            Section(header: Text("Characteristic UUID TX")) {
                TextField("Characteristic UUID TX", text: $notifyServiceUUID, onCommit: {
                    if notifyServiceUUID.count == 0 {
                        notifyServiceUUID = DefaultNotifyServiceUUID
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
            .textCase(nil)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Settings")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
