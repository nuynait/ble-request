//
//  BLECTCentralManager.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-19.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation
import CoreBluetooth
import BLERequest

/**
 Receiving delegate from `BLECentralCore`, Adapt to `BLECentralActionDelegate`
 */
class BLECTCentralManager {
  private var _isScan: Bool = false
  private var _discovered: [CBPeripheral] = []
  private var _isConnected: Bool = false

  public var isScan: Bool {
    get {
      return _isScan
    }
  }

  public var discovered: [CBPeripheral] {
    get {
      return _discovered
    }
  }

  public var isConnected: Bool {
    get {
      return _isConnected
    }
  }

}

extension BLECTCentralManager: BLECentralActionDelegate {
  func scanStateChanged(isScan: Bool) {
    _isScan = isScan
    BLECTNotification.main.postNotification(.central)
  }
  func didDiscover(peripherals: [CBPeripheral]) {
    _discovered = peripherals
    BLECTNotification.main.postNotification(.central)
  }
  func connectedStateChanged(isConnected: Bool) {
    _isConnected = isConnected
    BLECTNotification.main.postNotification(.central)
  }
}
