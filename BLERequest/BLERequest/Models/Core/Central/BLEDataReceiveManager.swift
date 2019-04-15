//
//  BLEDataReceiveManager.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-14.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLEDataReceiveManager {
  var _mutableData: NSMutableData?
  
  public func receiveDataChunk(data: Data) {
    if _mutableData == nil {
      _mutableData = NSMutableData()
    }
    
    guard let mutableData = _mutableData else {
      BLEDebugUtils.p(l: .wtf, t: "Impossible nil for mutableData.")
      return
    }
    
    let stringFromData = String(data: data, encoding: String.Encoding.utf8)
    if stringFromData == BLEString.EOM {
      // End of file. Finish sending ...
      guard let jsonString = String(data: mutableData.copy() as! Data, encoding: .utf8) else {
        BLEDebugUtils.p(l: .wtf, t: "Json deserialize from data failed. Data size: \(mutableData.count)")
        return
      }

      BLEDebugUtils.p(l: .d, t: "Data received: \(String(describing: jsonString))")
      jsonReceived(jsonString: jsonString)
    } else {
      // In the middle of sending. Appending to previous data.
      mutableData.append(data)
    }
  }
  
  private func jsonReceived(jsonString: String) {
    // TODO: Handle function for JSON string received.
  }
}
