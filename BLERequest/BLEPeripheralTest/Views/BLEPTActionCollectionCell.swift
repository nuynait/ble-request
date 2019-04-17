//
//  BLECTActionCollectionCell.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-16.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import UIKit

class BLEPTActionCollectionCell: UICollectionViewCell {

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  @IBOutlet weak var button: UIButton!
  private var action: (() -> ())?

  public func setAction(_ item: BLEPTActionItem) {
    button.setTitle(item.name, for: .normal)
    button.layer.borderColor = UIColor.red.cgColor
    button.layer.borderWidth = 1.0
    action = item.action
  }

  @IBAction func buttonClicked(_ sender: UIButton) {
    if let action = action {
      action()
    }
  }
}
