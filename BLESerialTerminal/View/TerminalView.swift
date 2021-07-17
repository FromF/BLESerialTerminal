//
//  TerminalView.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import SwiftUI
import CoreBluetooth

struct TerminalView: View {
    let peripheral: CBPeripheral?
    
    @StateObject var bleViewModel = BleViewModel()
    @State var sendText: String = ""
    
    var body: some View {
        VStack {
            TextView(text: $bleViewModel.recivedText)
                .padding()
            HStack {
                TextField("送信文字", text: $sendText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                    bleViewModel.send(sendText)
                    sendText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                }
            }
            .padding()
        }
        .navigationTitle("\(self.peripheral?.name ?? "unknown")")
        .onAppear() {
            guard let peripheral = self.peripheral else { return }
            self.bleViewModel.connect(peripheral: peripheral)
        }
        .onDisappear() {
            self.bleViewModel.disconnect()
        }
    }
}

struct TerminalView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalView(peripheral:nil)
    }
}
