//
//  BLEDebugUtils.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-11.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLEDebugUtils {
  @objc public enum Level: Int {
    case v
    case d
    case e
    case wtf
    
    
    public func raw() -> String {
      switch self {
      case .v:
        return "👀"
      case .d:
        return "⛏"
      case .e:
        return "⚠️"
      case .wtf:
        return "🚫"
      }
    }
  }
  
  static let queue = DispatchQueue(label: "Serialize Debug")
  
  /**
   Print function used in Swift. For calling function in objective-c, please use `objcP:l:f:t` instead.
   
   Print will only log message under debug mode and will abort the process for critial errors.
   
   - Parameter l:  Log level.
   - Parameter file: [Optional] File name for the print.
   - Parameter function: [Optional] Function name for the print.
   - Parameter line: [Optional] Line number for the print.
   - Parameter t: Text message or error message
   */
  public static func p(l: Level, file: String = #file, function: String = #function, line: Int = #line, t: String) {
    #if DEBUG
    // Start print in a serialized queue.
    queue.sync {
      print("Mapsted Log: |\(l.raw())|: \(t) [File: \(file), Function: \(function), Line#: \(line)]")
      if l == .wtf {
        abort()
      }
    }
    #endif
  }
}
