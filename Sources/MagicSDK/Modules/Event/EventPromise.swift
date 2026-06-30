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
    private var emitHandler: ((_ eventType: String, _ arg: Any?) -> Void)?
    private var errorHandler: ((_ error: Error) -> Void)?

    /// Subscribe to an inbound event (fires once, then unregisters).
    @discardableResult
    public func on(eventName: String, completion: @escaping () -> Void) -> MagicEventPromise {
        eventCenter.addOnceObserver(eventName: eventName, eventLog: eventLog, completion: completion)
        return self
    }

    /// Subscribe to an inbound event whose first param is a String (fires once).
    @discardableResult
    public func on(eventName: String, completion: @escaping (String?) -> Void) -> MagicEventPromise {
        eventCenter.addOnceObserver(eventName: eventName, eventLog: eventLog) { params in
            completion(params?.first?.string)
        }
        return self
    }

    /// Subscribe to an inbound event that may fire multiple times (e.g. invalid OTP retries).
    @discardableResult
    public func onPersistent(eventName: String, completion: @escaping () -> Void) -> MagicEventPromise {
        eventCenter.addPersistentObserver(eventName: eventName, eventLog: eventLog, completion: completion)
        return self
    }

    /// Subscribe to errors — mirrors magic-js's `.on('error', handler)` on PromiEvent.
    /// Called whenever the underlying promise rejects (RPC errors, network failures, etc.).
    @discardableResult
    public func onError(_ handler: @escaping (_ error: Error) -> Void) -> MagicEventPromise {
        errorHandler = handler
        return self
    }

    /// Emit an intermediary event back to the relayer (e.g. submit OTP).
    /// Pass the scalar value directly — not wrapped in an array.
    public func emit(eventType: String, arg: Any? = nil) {
        emitHandler?(eventType, arg)
    }

    public func done(on: DispatchQueue? = conf.Q.return, flags: DispatchWorkItemFlags? = nil, _ body: @escaping (T) throws -> Void) -> Promise<Void> {
        return self.donePromise.done(on: on, flags: flags, body)
    }

    @discardableResult
    public func `catch`(on: DispatchQueue? = conf.Q.return, _ body: @escaping (Error) -> Void) -> MagicEventPromise {
        donePromise.catch(on: on, body)
        return self
    }

    init(eventCenter: EventCenter, eventLog: Bool, emitHandler: ((_ eventType: String, _ arg: Any?) -> Void)? = nil, _ resolver: @escaping (_ resolver: Resolver<T>) -> Void) {
        let (promise, seal) = Promise<T>.pending()
        self.donePromise = promise
        self.eventCenter = eventCenter
        self.eventLog = eventLog
        self.emitHandler = emitHandler

        // Run the resolver and wire error emission on rejection — mirrors PromiEvent's
        // `.emit('error', err)` in magic-js before re-throwing to `.catch` callers.
        Promise<T>(resolver: resolver).pipe { result in
            switch result {
            case .fulfilled(let value):
                seal.fulfill(value)
            case .rejected(let error):
                self.errorHandler?(error)
                seal.reject(error)
            }
        }
    }
}
