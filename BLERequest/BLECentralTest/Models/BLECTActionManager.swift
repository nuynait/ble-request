//
//  BLECTMapActionManager.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation
import BLERequest

class BLECTActionManager {
  let core: BLECTCentralManager = BLECTCentralManager()

  private let _map: [BLECTActionItem] = [
    BLECTActionItem(name: "Print Test Log", action: {
      print("Testing...")
    })
  ]

  /**
   This map will dynamically populate depending on different state `BLECentralCore` has. See `buildDynamicMap()` for detail
   */
  private var _dynamicMap: [BLECTActionItem] = [] {
    didSet {
      BLECTNotification.main.postNotification(.action)
    }
  }

  public var actions: [BLECTActionItem] {
    get {
      return _map + _dynamicMap
    }
  }

  public func setup() {
    BLECTNotification.main.addObserverAndPost(type: .central, observer: self, selector: #selector(buildDynamicMap))
  }

  // *******************************
  //
  // MARK: Sync with Central State.
  //
  // *******************************

  /**
   Build the dynamic map depending on different state of `BLECentralCore`.
   */
  @objc public func buildDynamicMap() {
    // Build from the beginning.
    _dynamicMap.removeAll()

    // Scan
    if core.isScan {
      _dynamicMap.append(BLECTActionItem(name: "Stop Scan", action: {
        BLERequestApi.central.stopScan()
      }))
    } else {
      _dynamicMap.append(BLECTActionItem(name: "Start Scan", action: {
        let _ = BLERequestApi.central.scan()
      }))
    }

    // Connect
    if core.isConnected {
      // Disconnect
      _dynamicMap.append(BLECTActionItem(name: "Disconnect", action: {
        // TODO: Disconnect
      }))
    } else {
      // Not connected, list all discovered device and add connect actions.
      for device in core.discovered {
        _dynamicMap.append(BLECTActionItem(name: "Connect to: \(device.name ?? "EMPTY"))", action: {
          
        }))
      }
    }
  }

}
