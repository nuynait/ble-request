//
//  BLECentralCore.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-14.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLECentralCore: NSObject {
  private var _centralManager: CBCentralManager?
  private var _receiveManager: BLEDataReceiveManager?

  private var _isScan: Bool = false
  private var _isPoweredOn: Bool = false
  
  // Saved peripherals
  private var _discovered: [CBPeripheral] = [] // TODO: Remove from the list if expired or connected failed.
  private var _connected: CBPeripheral?
  
  // Saved characteristics
  private var _response: CBCharacteristic?
  private var _request: CBCharacteristic?

  // Expose variable
  /**
   All peripheral that has been discovered.
   */
  public var discovered: [CBPeripheral] {
    get {
      return _discovered
    }
  }

  /**
   Check if there is a peripheral connected to central. Connected means connect to peripheral, discovered service, have response characteristic notified and request characteristic discoverd.
   */
  public var isConnected: Bool {
    get {
      return (_connected != nil) && (_response != nil) && (_request != nil)
    }
  }

  /**
   If you want to receive response from the `BLECentralCore`, assign `BLECentralActionDelegate` here.
   */
  public weak var delegate: BLECentralActionDelegate?

  /**
   Call this function to setup the central. Setup is required before doing anything else.
   */
  internal func setup() {
    _centralManager = CBCentralManager(delegate: self, queue: nil)
    _receiveManager = BLEDataReceiveManager()
  }

  /**
   Call this function to start scan for peripheral.

   - Returns: `true` if start scan. `false` if scan failed.
   */
  internal func scan() -> Bool {
    guard !_isScan else {
      BLEDebugUtils.p(l: .e, t: "Function scan called, but already scan.")
      return false
    }
    guard let _centralManager = _centralManager else {
      BLEDebugUtils.p(l: .wtf, t: "Please call setup before scan.")
      return false
    }
    _centralManager.scanForPeripherals(withServices: [CBUUID(string: BLEUUID.SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    _isScan = true
    delegate?.scanStateChanged(isScan: true)
    return false
  }

  /**
   Call this function to stop scan for peripheral.
   */
  internal func stopScan() {
    guard _isScan else {
      BLEDebugUtils.p(l: .e, t: "Function stop scan called, but not yet start scan.")
      return
    }
    guard let _centralManager = _centralManager else {
      BLEDebugUtils.p(l: .wtf, t: "Please call setup before scan.")
      return
    }
    _isScan = false
    delegate?.scanStateChanged(isScan: false)
    _centralManager.stopScan()
  }

  /**
   Call this function to init the connect process.

   - Parameter peripheral: A peripheral object. You can get from the discovered list.
   */
  internal func connect(_ peripheral: CBPeripheral) {
    guard let _centralManager = _centralManager else {
      BLEDebugUtils.p(l: .wtf, t: "Please call setup before connect.")
      return
    }
    
    guard _connected == nil else {
      BLEDebugUtils.p(l: .wtf, t: "Already connect to a peripheral")
      return
    }
    
    BLEDebugUtils.p(l: .d, t: "Connect to \(peripheral.name ?? "nil")")
    _centralManager.connect(peripheral, options: nil)
  }
}

extension BLECentralCore: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .poweredOn:
      _isPoweredOn = true
      return
    case .poweredOff:
      // TODO: Message to user to start bluetooth.
      _isPoweredOn = false
      return
    case .resetting, .unauthorized, .unknown, .unsupported:
      BLEDebugUtils.p(l: .wtf, t: "Bluetooth is not supported.")
      _isPoweredOn = false
      @unknown default:
      return
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    guard let name = peripheral.name, RSSI.intValue < -15, RSSI.intValue > -70 else {
      return
    }
    
    if (!_discovered.contains(peripheral)) {
      BLEDebugUtils.p(l: .d, t: "Discover peripheral: \(name), at RSSI: \(RSSI)")
      _discovered.append(peripheral)
      delegate?.didDiscover(peripherals: _discovered)
    }
  }
  
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    BLEDebugUtils.p(l: .wtf, t: "Fail to connect peripheral: \(String(describing: peripheral.name)), Error: \(String(describing: error))")
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    BLEDebugUtils.p(l: .d, t: "Connected to peripheral: \(String(describing: peripheral.name))")
    
    // Assign peripheral to connected. Attach delegate.
    _connected = peripheral
    peripheral.delegate = self
    
    // Connected to peripheral. Discover service.
    peripheral.discoverServices([CBUUID(string: BLEUUID.SERVICE_UUID)])
  }
  
}

extension BLECentralCore: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let error = error {
      BLEDebugUtils.p(l: .wtf, t: "Connecting to service failed. Error: \(error)")
      // TODO: Clean
      return
    }
    
    guard let services = peripheral.services else {
      BLEDebugUtils.p(l: .wtf, t: "Cannot find any services. This should not be possible.")
      // TODO: Clean
      return
    }
    
    for service in services {
      peripheral.discoverCharacteristics([CBUUID(string: BLEUUID.RESPONSE_CHAR_UUID), CBUUID(string: BLEUUID.REQUST_CHAR_UUID)], for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let error = error {
      BLEDebugUtils.p(l: .wtf, t: "Connecting to characteristics failed. Error: \(error)")
      // TODO: Clean
      return
    }
    
    guard let characteristics = service.characteristics else {
      BLEDebugUtils.p(l: .wtf, t: "Connot find any characteristics in service")
      return
    }
    
    for characteristic in characteristics {
      if characteristic.uuid.isEqual(CBUUID(string: BLEUUID.RESPONSE_CHAR_UUID)) {
        // Found response uuid, set notify for incoming data.
        _response = characteristic
        peripheral.setNotifyValue(true, for: characteristic)
      } else if characteristic.uuid.isEqual(CBUUID(string: BLEUUID.REQUST_CHAR_UUID)) {
        _request = characteristic
      }
    }

    delegate?.connectedStateChanged(isConnected: isConnected)
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      BLEDebugUtils.p(l: .wtf, t: "Error sending data. Error: \(error)")
      return
    }
    
    guard let receiveManager = _receiveManager else {
      BLEDebugUtils.p(l: .wtf, t: "Receive manager not exists. Please call setup first before any other actions.")
      return
    }
    
    guard let data = characteristic.value else {
      BLEDebugUtils.p(l: .wtf, t: "Cannot extract the data value from the characteristic.")
      return
    }
    
    receiveManager.receiveDataChunk(data: data)
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    if characteristic.isNotifying {
      BLEDebugUtils.p(l: .d, t: "characteristic is notifying.")
    } else {
      BLEDebugUtils.p(l: .d, t: "Notify stopped")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    // When calling peripheral writeValue with type: CBCharacteristicWriteWithResponse, this funcition will get called after write with response of succeed or failed write with error message.
    if let error = error {
      BLEDebugUtils.p(l: .e, t: "Central core write failed. Error: \(error)")
    }
  }
}
