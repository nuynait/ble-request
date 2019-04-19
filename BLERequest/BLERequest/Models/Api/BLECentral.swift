//
//  BLECentral.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-17.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

open class BLECentral {
  private let _centralCore = BLECentralCore()

  /**
   Call this function to initialize central.
   */
  public func setup() {
    _centralCore.setup()
  }
}
