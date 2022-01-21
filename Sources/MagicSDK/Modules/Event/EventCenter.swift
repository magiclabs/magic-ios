//
//  PromiEvent.swift
//  MagicSDK
//
//  Created by Jerry Liu on 7/10/20.
//

import Foundation
import PromiseKit

public class EventCenter {
    
    enum Error: Swift.Error{
        case eventCallbackMissing
    }
    private var eventLog = false
    
    private typealias EventCompletion = () -> Void
    private var eventHandlerDict: Dictionary<String, EventCompletion> = [:]

    func addOnceObserver (eventName: String, eventLog: Bool, completion: @escaping () -> Void) -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDidReceiveEventOnce(_:)), name: Notification.Name.init(eventName), object: nil)
        self.eventLog = eventLog
        eventHandlerDict[eventName] = completion
    }

    /// Recieve events
    @objc func onDidReceiveEventOnce(_ notification: Notification) {

        if let eventResult = (notification.userInfo?["event"]) as? MagicEventResult<[AnyValue]>, let handler = eventHandlerDict[eventResult.event] {
            
            if (eventLog) {
                print("MagicSDK Event: \(eventResult)")
            }
            
            NotificationCenter.default.removeObserver(self, name: Notification.Name(eventResult.event), object: nil)
            handler()
        } else {
//            handleRollbarError(Error.eventCallbackMissing)
        }
    }
    
    init (){}
}
