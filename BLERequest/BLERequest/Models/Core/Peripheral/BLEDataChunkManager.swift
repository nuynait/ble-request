//
//  BLEDataChunkManager.swift
//  BLERequest
//
//  Created by Tianyun Shan on 2019-04-12.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
 This `BLEDataChunkManager` is used by `BLEPeripheralCore`. It is responsible to send response to bluetooth central (client). It will send data chunk by chunk. See `BLEDataChunk` for detail. If bluetooth is not ready yet, it will queue up the `BLEDataChunk` inside a queue and free the queue up after bluetooth subscribed the central.
 */
class BLEDataChunkManager {
  
  private unowned let _peripheral: CBPeripheralManager
  private unowned let _characteristics: CBMutableCharacteristic
  
  private var _isSubcribed: Bool = false
  
  /**
   Data in queue. If currently there is a json in transfer, add to textQueue instead. Everytime data sent finished, it will check this queue and if its not empty, it will move the first one to `_curDataChunk`
   */
  private var _dataQueue: [BLEDataChunk] = []
  private var _curDataChunk: BLEDataChunk?
  
  init(peripheralManager: CBPeripheralManager, characteristics: CBMutableCharacteristic) {
    _peripheral = peripheralManager
    _characteristics = characteristics
  }
  
  // *******************************
  //
  // MARK: Public Api
  //
  // *******************************
  
  /**
   Call this function to change the subscription state. If subscribed, then we will need to start clear the queue. All data added to the queue needs to start send one by one to central
   
   - Parameter isSubscribed: Bluetooth peripheral is subscribed to characteristic or not.
   */
  public func setSubscribed(_ isSubscribed: Bool) {
    _isSubcribed = isSubscribed
    if _isSubcribed {
      startClearQueue()
    }
  }
  
  /**
   If there are current data chunks exists, call this function to continue send the data chunk.
   */
  public func continueSendChunks() {
    if _curDataChunk != nil {
      sendChunks()
    }
  }
  
  /**
   Call this function to send `String` text to bluetooth central. This function will init the send process if subscribed to peripheral. Otherwise it will add to the queue to wait until subscribed.
   
   - Parameter text: The text to send.
   */
  public func sendText(_ text: String) {
    guard _curDataChunk == nil, _isSubcribed else {
      if !_isSubcribed {
        // If not subscribed, remove curDataChunk add to queue
        _curDataChunk = nil
      }
      
      guard let dataToSend = text.data(using: String.Encoding.utf8) else {
        BLEDebugUtils.p(l: .wtf, t: "dataToSend does not exists. text.data(using: String.Encoding.utf8) failed.")
        return
      }
      
      _dataQueue.append(BLEDataChunk(data: dataToSend))
      return
    }
    
    guard let data = text.data(using: String.Encoding.utf8) else {
      BLEDebugUtils.p(l: .wtf, t: "Cannot get data from text: \(text)")
      return
    }
    
    _curDataChunk = BLEDataChunk(data: data)
    sendChunks()
  }
  
  /**
   Call this function to send `Data` data to bluetooth central. This function will init the send process if subscribed to peripheral. Otherwise it will add to the queue to wait until subscribed.
   
   - Parameter data: The data to send.
   */
  public func sendData(_ data: Data) {
    BLEDebugUtils.p(l: .v, t: "Send data. data.size: \(data.count)")
    guard _curDataChunk == nil, _isSubcribed else {
      // Channel is busy, add to the queue
      if !_isSubcribed {
        // If not subscribed, remove curDataChunk add to queue
        _curDataChunk = nil
      }
      BLEDebugUtils.p(l: .v, t: "Data add to queue. Current queue: \(_dataQueue.count), data.size: \(data.count)")
      _dataQueue.append(BLEDataChunk(data: data))
      return
    }
    _curDataChunk = BLEDataChunk(data: data)
    sendChunks()
  }
  
  // *******************************
  //
  // MARK: Private Functions
  //
  // *******************************
  
  /**
   Start clear the queue. The queue is used to temporary save the data chunk. If user init to send the data chunk when it is not subscribed yet, it will add to the queue. When peripheral subscribed to the characteristics of a central, we will need to start clear the queue if possible.
   */
  private func startClearQueue() {
    guard _curDataChunk == nil else {
      BLEDebugUtils.p(l: .wtf, t: "Current data chunk is not nil when start clear queue")
      return
    }
    
    if let nextChunk = _dataQueue.first {
      _curDataChunk = nextChunk
      _dataQueue.removeFirst()
      sendChunks()
    }
  }
  
  /**
   Repeatedly send chunk to central until all data chunk sent. Call this function to start sending datas.
   */
  private func sendChunks() {
    while (_curDataChunk != nil) {
      let result = sendChunk()
      if !result {
        // Traffic stucked. Return for now. Wait until `pheripheralManagerIsReady` delegate to resume sendChunks...
        return
      }
    }
  }
  
  /**
   Send a part of the data chunk. Only call this function as a helper to send all chunks.
   
   - Returns: `True` if successfully send a chunk, `False` if not.
   */
  private func sendChunk() -> Bool {
    guard let dataChunk = _curDataChunk else {
      BLEDebugUtils.p(l: .wtf, t: "data chunk does not exists.")
      return true
    }
    
    guard let dataToSend = dataChunk.next() else {
      // No data left. Send EOM
      BLEDebugUtils.p(l: .v, t: "Send EOM Chunk")
      guard let eomData = BLEString.EOM.data(using: String.Encoding.utf8) else {
        BLEDebugUtils.p(l: .wtf, t: "eomData does not exists. EOM_CHAR.data(using: String.Encoding.utf8) failed.")
        return false
      }
      let didSend = _peripheral.updateValue(eomData, for: _characteristics, onSubscribedCentrals: nil)
      if didSend {
        // send successfully, finish up
        BLEDebugUtils.p(l: .v, t: "Send EOM chunk successfully.")
        _curDataChunk = nil
        startClearQueue()
        return true
      } else {
        BLEDebugUtils.p(l: .e, t: "Send EOM Failed.")
        return false
      }
    }
    
    BLEDebugUtils.p(l: .v, t: "Send chunk")
    let didSend = _peripheral.updateValue(dataToSend, for: _characteristics, onSubscribedCentrals: nil)
    if !didSend {
      BLEDebugUtils.p(l: .e, t: "Send to Central Failed")
      dataChunk.rollback()
      return false
    }
    BLEDebugUtils.p(l: .v, t: "Send chunk succeed, data sent: \(dataToSend.count)")
    return true
  }
}
