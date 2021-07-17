//
//  StartView.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import SwiftUI

struct StartView: View {
    @StateObject var startViewModel = StartViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List (self.startViewModel.peripherals){ peripheral in
                    NavigationLink(
                        destination: TerminalView(peripheral: peripheral.peripheral),
                        label: {
                            Text("\(peripheral.name)")
                        })
                }
                .listStyle(PlainListStyle())
                
                Spacer()
                
                Button(action: {
                    startViewModel.startScan()
                }) {
                    Text("Scan")
                }
            }
            .navigationTitle("BLE Serial Terminal")
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: SettingView(),
                        label: {
                            Image(systemName: "gearshape.fill")
                        })
                }
            })
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
