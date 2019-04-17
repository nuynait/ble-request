//
//  BLEPTApi.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLEPTApi {
  private static let action = BLEPTActionManager()

  public static func getActions() -> [BLEPTActionItem] {
    return action.map
  }
}
