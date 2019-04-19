//
//  BLEPeripheral.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-17.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

open class BLEPeripheral {
  private let _peripheralCore = BLEPeripheralCore()

  /**
   Call this function to initialize peripheral.

   - Parameter device: The device name that acts as the peripheral.
   */
  public func setup(device: String) {
    _peripheralCore.setup(device: device)
  }
}
