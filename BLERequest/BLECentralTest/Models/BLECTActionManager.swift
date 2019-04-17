//
//  BLECTMapActionManager.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLECTActionManager {
  let map: [BLECTActionItem] = [
    BLECTActionItem(name: "Print Test Log", action: {
      print("Testing...")
    })
  ]
}
