//
//  debug.swift
//  BLESerialTerminal
//
//  Created by 藤治仁 on 2021/07/17.
//

import Foundation

///デバックモード設定
func debugLog(_ obj: Any?,
              function: String = #function,
              line: Int = #line) {
    #if DEBUG
    if let obj = obj {
        print("[\(function):\(line)] : \(obj)")
    } else {
        print("[\(function):\(line)]")
    }
    #endif
}

func errorLog(_ obj: Any?,
              function: String = #function,
              line: Int = #line) {
    #if DEBUG
    if let obj = obj {
        print("ERROR [\(function):\(line)] : \(obj)")
    } else {
        print("ERROR [\(function):\(line)]")
    }
    #endif
}

var isSimulator:Bool {
    get {
        #if targetEnvironment(simulator)
        // iOS simulator code
        return true
        #else
        return false
        #endif
    }
}
