//
//  BLECTNotification.swift
//  BLECentralTest
//
//  Created by Tianyun Shan on 2019-04-20.
//  Copyright © 2019 Hourglass Lab. All rights reserved.
//

import Foundation

class BLECTNotification {
  internal static let main = BLECTNotification()

  /**
   Notification Type
   */
  internal enum NotificationType: String {

    /**
     Anything changed in actions.
     */
    case action = "com.hourglasslab.ble.central.test.action"

    /**
     Anything changed in `BLECTCentralManager`.
     */
    case central = "com.hourglasslab.ble.central.test.core"
  }

  /**
   Post a notification when some event changed and need to notify others.

   - Parameter type: The type for the event that's changed.
   */
  internal func postNotification(_ type: NotificationType) {
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: type.rawValue), object: nil)
    }
  }

  /**
   This function adds a specific type observer to a set of observers.
   Then post notification of the type immediately.

   - Parameter type: The notification type.
   - Parameter observer: The object that is watching for notifications.
   - Parameter selector: The selector.
   - seeAlso: `addObserver` only adds an observer, not post.
   */
  internal func addObserverAndPost(type: NotificationType, observer: AnyObject, selector: Selector) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(type.rawValue), object: nil)
    postNotification(type)
  }

  /**
   This function adds a specific type observer to a set of observers.

   - Parameter type: The notification type.
   - Parameter observer: The object that is watching for notifications.
   - Parameter selector: The selector.
   - seeAlso: `addObserverAndPost` not only adds an observer, also post immediately.
   */
  internal func addObserver(type: NotificationType, observer: AnyObject, selector: Selector) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(type.rawValue), object: nil)
  }

  /**
   This function removes all observers.

   - Parameter observer: The objects that are not watching notifications.
   - seeAlso: Use `removeObserver` if you want to remove only one type of observer.
   */
  internal func removeAllObservers(observer: AnyObject) {
    NotificationCenter.default.removeObserver(observer)
  }
}
