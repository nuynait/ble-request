//
//  BLECTActionViewController.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-15.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import UIKit

class BLECTActionViewController: UIViewController {

  static let obj = "BLECTActionViewController"

  init() {
    super.init(nibName: BLECTActionViewController.obj, bundle: Bundle(for: type(of: self)))
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    setViews()

    // init model and view for the first version.
    updateModel()
    updateView()
  }

  // *******************************
  //
  // MARK: Setup
  //
  // *******************************
  @IBOutlet weak var collectionView: UICollectionView!

  let CELL_REUSE_IDENTIFIER = "BLECTActionCollectionCell"
  let CELL_WIDTH = 80.0
  let CELL_HEIGHT = 36.0

  private func setViews() {
    setCollectionView()
  }

  private func setCollectionView() {
    collectionView.register(UINib(nibName: CELL_REUSE_IDENTIFIER, bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: CELL_REUSE_IDENTIFIER)
  }

  // *******************************
  //
  // MARK: Model
  //
  // *******************************

  var actions: [BLECTActionItem] = []
  
  func updateModel() {
    actions = BLECTApi.getActions()
  }

  // *******************************
  //
  // MARK: Redraw
  //
  // *******************************

  func updateView() {
    collectionView.reloadData()
  }

}

extension BLECTActionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return actions.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_REUSE_IDENTIFIER, for: indexPath) as? BLECTActionCollectionCell else {
      assert(false, "no reusable cell")
      return UICollectionViewCell(frame: CGRect.zero)
    }

    let action = actions[indexPath.row]
    cell.setAction(action)
    return cell
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: CELL_WIDTH, height: CELL_HEIGHT)
  }
}
