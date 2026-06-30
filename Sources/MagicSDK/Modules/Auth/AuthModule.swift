//
//  AuthModule.swift
//  Magic
//
//  Created by Jerry Liu on 3/3/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation
import MagicSDK_Web3
import PromiseKit

public class AuthModule: BaseModule {
    // MARK: - Login with SMS
    public func loginWithSMS (_ configuration: LoginWithSmsConfiguration, response: @escaping Web3ResponseCompletion<String> ) {
        let request = RPCRequest<[LoginWithSmsConfiguration]>(method: AuthMethod.magic_auth_login_with_sms.rawValue, params: [configuration])
        self.provider.send(request: request, response: response)
    }
    
    public func loginWithSMS (_ configuration: LoginWithSmsConfiguration) -> Promise<String> {
        return Promise { resolver in
            loginWithSMS(configuration, response: promiseResolver(resolver))
        }
    }
    
    // MARK: - Login with EmailOTP
    public func loginWithEmailOTP(_ configuration: LoginWithEmailOTPConfiguration, response: @escaping Web3ResponseCompletion<String>) {
        let request = RPCRequest<[LoginWithEmailOTPConfiguration]>(method: AuthMethod.magic_auth_login_with_email_otp.rawValue, params: [configuration])
        self.provider.send(request: request, response: response)
    }

    public func loginWithEmailOTP(_ configuration: LoginWithEmailOTPConfiguration) -> Promise<String> {
        return Promise { resolver in
            loginWithEmailOTP(configuration, response: promiseResolver(resolver))
        }
    }

    /// Event-driven overload for `showUI: false` flows. Returns a `MagicEventPromise`
    /// that lets callers subscribe to inbound events and emit OTP back to the relayer.
    ///
    /// Example:
    /// ```swift
    /// magic.auth.loginWithEmailOTP(LoginWithEmailOTPConfiguration(email: email, showUI: false), eventLog: true)
    ///     .on(eventName: LoginWithEmailOTPEventOnReceived.emailOTPSent.rawValue) {
    ///         // prompt user for OTP
    ///     }
    ///     .on(eventName: LoginWithEmailOTPEventOnReceived.invalidEmailOTP.rawValue) {
    ///         // show error
    ///     }
    ///     .done { didToken in
    ///         // authenticated
    ///     }
    ///
    /// // When user submits OTP:
    /// handle.emit(eventType: LoginWithEmailOTPEventEmit.verifyEmailOTP.rawValue, arg: otp)
    /// ```
    @discardableResult
    public func loginWithEmailOTP(_ configuration: LoginWithEmailOTPConfiguration, eventLog: Bool) -> MagicEventPromise<String> {
        // Build the request once so its id is the same one sent to the relayer.
        let request = RPCRequest<[LoginWithEmailOTPConfiguration]>(method: AuthMethod.magic_auth_login_with_email_otp.rawValue, params: [configuration])
        let payloadId = request.id

        return MagicEventPromise(eventCenter: magicEventCenter, eventLog: eventLog, emitHandler: { [weak self] eventType, arg in
            self?.sendIntermediaryEvent(payloadId: payloadId, eventType: eventType, arg: arg)
        }) { [weak self] resolver in
            self?.provider.send(request: request, response: promiseResolver(resolver))
        }
    }

    public enum LoginWithEmailOTPEventOnReceived: String {
        case emailOTPSent       = "email-otp-sent"
        case invalidEmailOTP    = "invalid-email-otp"
        case expiredEmailOTP    = "expired-email-otp"
        case loginThrottled     = "login-throttled"
        case maxAttemptsReached = "max-attempts-reached"
    }

    public enum LoginWithEmailOTPEventEmit: String {
        case verifyEmailOTP = "verify-email-otp"
        case cancel         = "cancel"
    }

    public enum MFAEventOnReceived: String {
        case mfaSentHandle          = "mfa-sent-handle"
        case invalidMfaOTP          = "invalid-mfa-otp"
        case recoveryCodeSentHandle = "recovery-code-sent-handle"
        case invalidRecoveryCode    = "invalid-recovery-code"
        case recoveryCodeSuccess    = "recovery-code-success"
    }

    public enum MFAEventEmit: String {
        case verifyMFACode      = "verify-mfa-code"
        case verifyRecoveryCode = "verify-recovery-code"
        case lostDevice         = "lost-device"
        case cancel             = "cancel"
    }

    public enum DeviceVerificationEventOnReceived: String {
        case deviceNeedsApproval           = "device-needs-approval"
        case deviceVerificationEmailSent   = "device-verification-email-sent"
        case deviceApproved                = "device-approved"
        case deviceVerificationLinkExpired = "device-verification-link-expired"
    }

    public enum DeviceVerificationEventEmit: String {
        case deviceRetry = "device-retry"
    }

    public enum LoginEmailOTPLinkEvent: String {
        case emailNotDeliverable = "email-not-deliverable"
        case emailSent           = "email-sent"
        case retry               = "retry"
    }
}
