//
//  BLECTMainViewController.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import UIKit

class BLECTMainViewController: UIViewController {

  let actionViewController = BLECTActionViewController()

  override func viewDidAppear(_ animated: Bool) {
    present(actionViewController, animated: true, completion: nil)
  }
  
}

