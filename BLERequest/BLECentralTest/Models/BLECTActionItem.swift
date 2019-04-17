//
//  BLECTActionItem.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLECTActionItem {
  let name: String
  let action: () -> ()

  init(name: String, action: @escaping () -> ()) {
    self.name = name
    self.action = action
  }
}
