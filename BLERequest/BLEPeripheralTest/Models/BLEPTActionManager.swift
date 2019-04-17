//
//  BLEPTMapActionManager.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLEPTActionManager {
  let map: [BLEPTActionItem] = [
    BLEPTActionItem(name: "Print Test Log", action: {
      print("Testing...")
    })
  ]
}
