//
//  BLECentralActionDelegate.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-19.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol BLECentralActionDelegate: class {
  func scanStateChanged(isScan: Bool)
  func didDiscover(peripherals: [CBPeripheral])
  func connectedStateChanged(isConnected: Bool)
}
