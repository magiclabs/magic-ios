//
//  PromiEvent.swift
//  MagicSDK
//
//  Created by Jerry Liu on 7/10/20.
//

import Foundation
import PromiseKit

public class MagicEventPromise<T> {
    
    private var donePromise: Promise<T>
    private var eventCenter: EventCenter
    private var eventLog = false
    
    typealias EventCompletion = () -> Void

    public func once(eventName: String, completion: @escaping () -> Void) -> MagicEventPromise {
        eventCenter.addOnceObserver(eventName: eventName, eventLog: eventLog, completion: completion)
        return self
    }
    
    public func done(on: DispatchQueue? = conf.Q.return, flags: DispatchWorkItemFlags? = nil, _ body: @escaping(T) throws -> Void) -> Promise<Void> {
        return self.donePromise.done(on: on, flags: flags, body)
    }
    
    init (eventCenter: EventCenter, eventLog: Bool, _ resolver: @escaping (_ resolver: Resolver<T>) -> Void) {
        self.donePromise = Promise<T>(resolver: resolver)
        self.eventCenter = eventCenter
        self.eventLog = eventLog
    }
}
