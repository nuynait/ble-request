//
//  BLEDataChunk.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-12.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLEDataChunk {
  static let NOTIFY_MTU = 20 // the amount of data size to sent through ble protocol.
  
  let all: Data
  
  private var _index: Int = 0
  private var _lastAmount: Int = 0
  
  init(data: Data) {
    all = data
  }
  
  /**
   Next data chunk to send. **Note that** everytime when access `next()` the data index for sending will be increased to next level.
   
   - Returns: Next chunk to send. Will return `nil` when reach the end.
   */
  public func next() -> Data? {
    var amount = all.count - _index // total amount of data left
    
    // Amount exceeds the required size. So only send required size
    if amount > BLEDataChunk.NOTIFY_MTU {
      amount = BLEDataChunk.NOTIFY_MTU
    } else if amount <= 0 {
      return nil
    }
    
    _lastAmount = amount
    _index += amount
    
    return Data(bytes: BLEDataUtils.getBytes(all), count: amount)
  }
  
  /**
   Rollback last data send process. If data send failed last time, you can call this function to rollback. It can only rollback the recent data send.
   */
  public func rollback() {
    _index -= _lastAmount
    _lastAmount = 0
  }
}
