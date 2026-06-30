//
//  PromiEvent.swift
//  MagicSDK
//
//  Created by Jerry Liu on 7/10/20.
//

import Foundation
import PromiseKit

public class EventCenter {

    enum Error: Swift.Error {
        case eventCallbackMissing
    }
    private var eventLog = false

    private typealias EventCompletion = ([AnyValue]?) -> Void
    private var onceHandlerDict: Dictionary<String, EventCompletion> = [:]
    private var persistentHandlerDict: Dictionary<String, EventCompletion> = [:]

    func addOnceObserver(eventName: String, eventLog: Bool, completion: @escaping () -> Void) {
        addOnceObserver(eventName: eventName, eventLog: eventLog) { (_: [AnyValue]?) in completion() }
    }

    func addOnceObserver(eventName: String, eventLog: Bool, completion: @escaping ([AnyValue]?) -> Void) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDidReceiveEvent(_:)), name: Notification.Name(eventName), object: nil)
        self.eventLog = eventLog
        onceHandlerDict[eventName] = completion
    }

    func addPersistentObserver(eventName: String, eventLog: Bool, completion: @escaping () -> Void) {
        addPersistentObserver(eventName: eventName, eventLog: eventLog) { (_: [AnyValue]?) in completion() }
    }

    func addPersistentObserver(eventName: String, eventLog: Bool, completion: @escaping ([AnyValue]?) -> Void) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDidReceiveEvent(_:)), name: Notification.Name(eventName), object: nil)
        self.eventLog = eventLog
        persistentHandlerDict[eventName] = completion
    }

    @objc func onDidReceiveEvent(_ notification: Notification) {
        if let eventResult = (notification.userInfo?["event"]) as? MagicEventResult<[AnyValue]>,
           let event = eventResult.event {

            if eventLog {
                print("MagicSDK Event: \(eventResult)")
            }

            if let handler = onceHandlerDict[event] {
                NotificationCenter.default.removeObserver(self, name: Notification.Name(event), object: nil)
                onceHandlerDict.removeValue(forKey: event)
                handler(eventResult.params)
            } else if let handler = persistentHandlerDict[event] {
                handler(eventResult.params)
            }
        }
    }

    func removeAllObservers() {
        for eventName in onceHandlerDict.keys {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(eventName), object: nil)
        }
        for eventName in persistentHandlerDict.keys {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(eventName), object: nil)
        }
        onceHandlerDict.removeAll()
        persistentHandlerDict.removeAll()
    }

    init() {}
}
