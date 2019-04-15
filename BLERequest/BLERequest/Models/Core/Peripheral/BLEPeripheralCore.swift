//
//  BLEPeripheralCore.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-11.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEPeripheralCore: NSObject {
  // Managers.
  private lazy var _peripheralManager: CBPeripheralManager = { [unowned self] in
    return CBPeripheralManager(delegate: self, queue: nil) // On the main queue for now.
    }()
  private lazy var _dataChunkManager: BLEDataChunkManager = { [unowned self] in
    return BLEDataChunkManager(peripheralManager: _peripheralManager, characteristics: _responseCharacteristic)
  }()
  
  // Service & Characteristics.
  private lazy var _service: CBMutableService = {
    let service = CBMutableService(type: CBUUID(string: BLEUUID.SERVICE_UUID), primary: true)
    service.characteristics = [_responseCharacteristic, _requestCharacteristic]
    return service
  }()
  private lazy var _responseCharacteristic: CBMutableCharacteristic = {
    return CBMutableCharacteristic(type: CBUUID(string: BLEUUID.RESPONSE_CHAR_UUID), properties: .notify, value: nil, permissions: .readable)
  }()
  private lazy var _requestCharacteristic: CBMutableCharacteristic = {
    return CBMutableCharacteristic(type: CBUUID(string: BLEUUID.REQUST_CHAR_UUID), properties: .write, value: nil, permissions: .writeable)
  }() // Use to receive request from the central (mac client)
  
  // Private Class Variable
  private let DEVICE_NAME: String
  
  // *******************************
  //
  // MARK: Initialization
  //
  // *******************************
  
  init(deviceName: String) {
    self.DEVICE_NAME = deviceName
    super.init()
  }
  
  /**
   Before using `BLEPeripheralCore`, call setup to setup bluetooth.
   */
  public func setup() {
    // NOTE: Init order matters.
    // TODO: I don't like this lazy method. Change to optional variables and setup the detail here. Reason is if we forgot to setup, we can catch the issue later.
    _ = _peripheralManager // init peripheral manager
    _ = _service // init service and characteristic.
    _ = _dataChunkManager // init the data chunk manager. This need to wait until peripheral manager and service finish init.
  }
  
  // *******************************
  //
  // MARK: Private Functions
  //
  // *******************************
  
  /**
   This function is use to turn on/off advertising.
   
   - Set to `true` on `didUpdateState` when bluetooth state is `poweredOn`
   */
  private func setAdvertising(isEnable: Bool) {
    if isEnable {
      _peripheralManager.startAdvertising( [
        CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: BLEUUID.SERVICE_UUID)],
        CBAdvertisementDataLocalNameKey: DEVICE_NAME
        ])
      BLEDebugUtils.p(l: .d, t: "Bluetooth Peripheral Start Advertising.")
    } else {
      _peripheralManager.stopAdvertising()
      BLEDebugUtils.p(l: .d, t: "Bluetooth Peripheral Stop Advertising.")
    }
  }
}

extension BLEPeripheralCore: CBPeripheralManagerDelegate {
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOff:
      BLEDebugUtils.p(l: .wtf, t: "Please enable bluetooth on device to continue.")
      // TODO: OPTION TO ASK POWER ON BLUETOOTH
    case .poweredOn:
      // Bluetooth is ready. start advertising
      setAdvertising(isEnable: true)
      return
    case .resetting, .unauthorized, .unknown, .unsupported:
      BLEDebugUtils.p(l: .wtf, t: "Bluetooth on this device is not supported.")
      @unknown default:
      BLEDebugUtils.p(l: .wtf, t: "Unknown result for bluetooth device.")
      return
    }
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
    BLEDebugUtils.p(l: .d, t: "Subscribed to characteristics.")
    _dataChunkManager.setSubscribed(true)
  }
  
  func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    _dataChunkManager.continueSendChunks()
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    for request in requests {
      guard request.characteristic.uuid == CBUUID(string: BLEUUID.REQUST_CHAR_UUID) else {
        BLEDebugUtils.p(l: .wtf, t: "Error. uuid not match to request UUID.")
        return
      }

      if let data = request.value {
        let requestType = String(bytes: data, encoding: String.Encoding.utf8)
        BLEDebugUtils.p(l: .e, t: "Received request, request type: \(String(describing: requestType))")
        // TODO: After get request type, need to get response.
      }
    }
  }
}
