//
//  BLEDataUtils.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-12.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLEDataUtils {
  static func getBytes(_ data: Data) -> [UInt8] {
    return [UInt8](data)
  }
}
