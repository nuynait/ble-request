//
//  BLECTApi.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLECTApi {
  private static let action = BLECTActionManager()

  public static func getActions() -> [BLECTActionItem] {
    return action.map
  }
}
