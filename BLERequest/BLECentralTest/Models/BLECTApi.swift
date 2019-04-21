//
//  BLECTApi.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation
import BLERequest

class BLECTApi {
  private static let action = BLECTActionManager()

  public static func setup() {
    // Setup BLERequest framework
    BLERequestApi.central.setup()
    BLERequestApi.central.setDelegate(action.core)

    // Setup my own model
    action.setup()
  }

  public static func getActions() -> [BLECTActionItem] {
    return action.actions
  }
}
