//
//  BLECentral.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-17.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation
import CoreBluetooth

open class BLECentral {
  private let _core = BLECentralCore()

  /**
   Call this function to initialize central.
   */
  public func setup() {
    _core.setup()
  }

  /**
   Register delegate for `BLECentralActionDelegate`

   - Parameter: Objects extends to protocol `BLECentralActionDelegate`
   */
  public func setDelegate(_ delegate: BLECentralActionDelegate?) {
    _core.delegate = delegate
  }

  /**
   Call this function to start scan for peripheral.

   - Returns: `true` if start scan. `false` if scan failed.
   */
  public func scan() -> Bool {
    return _core.scan()
  }

  /**
   Call this function to stop scan for peripheral.
   */
  public func stopScan() {
    _core.stopScan()
  }

  public func connect(_ peripheral: CBPeripheral) {
    _core.connect(peripheral)
  }
}
