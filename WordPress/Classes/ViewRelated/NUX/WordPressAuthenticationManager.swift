import Foundation


// MARK: - WordPressAuthenticationManager
//
class WordPressAuthenticationManager {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Helpshift is only available to the WordPress iOS App. Our Authentication Framework doesn't have direct access.
    /// We'll setup a mechanism to relay the `helpshiftUnreadCountWasUpdated` event back to the Authenticator.
    ///
    func startRelayingHelpshiftNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(helpshiftUnreadCountWasUpdated), name: .HelpshiftUnreadCountUpdated, object: nil)
    }
}


// MARK: - Notification Handlers
//
extension WordPressAuthenticationManager {

    @objc
    func helpshiftUnreadCountWasUpdated(_ notification: Foundation.Notification) {
        WordPressAuthenticator.shared.supportBadgeCountWasUpdated()
    }
}


// MARK: - WordPressAuthenticator Delegate
//
extension WordPressAuthenticationManager: WordPressAuthenticatorDelegate {

    /// Indicates whether if the Support Action should be enabled, or not.
    ///
    var supportActionEnabled: Bool {
        return true
    }

    /// Indicates if Helpshift is Enabled.
    ///
    var livechatActionEnabled: Bool {
        return HelpshiftUtils.isHelpshiftEnabled()
    }

    /// Returns Helpshift's Unread Messages Count.
    ///
    var supportBadgeCount: Int {
        return HelpshiftUtils.unreadNotificationCount()
    }

    /// Refreshes Helpshift's Unread Count.
    ///
    func refreshSupportBadgeCount() {
        HelpshiftUtils.refreshUnreadNotificationCount()
    }

    /// Returns an instance of SupportViewController, configured to be displayed from a specified Support Source.
    ///
    func presentSupport(from sourceViewController: UIViewController, sourceTag: WordPressSupportSourceTag, options: [String: Any] = [:]) {
        let supportViewController = SupportViewController()
        supportViewController.sourceTag = sourceTag.toSupportSourceTag()
        supportViewController.helpshiftOptions = options

        let navController = UINavigationController(rootViewController: supportViewController)
        navController.navigationBar.isTranslucent = false
        navController.modalPresentationStyle = .formSheet

        sourceViewController.present(navController, animated: true, completion: nil)
    }

    /// Presents Helpshift, with the specified ViewController as a source. Additional metadata is supplied, such as the sourceTag and Login details.
    ///
    func presentLivechat(from sourceViewController: UIViewController, sourceTag: WordPressSupportSourceTag, options: [String: Any]) {
        let presenter = HelpshiftPresenter()
        presenter.sourceTag = sourceTag.toSupportSourceTag()
        presenter.optionsDictionary = options
        presenter.presentHelpshiftConversationWindowFromViewController(sourceViewController,
                                                                       refreshUserDetails: true,
                                                                       completion: nil)
    }
}


// MARK: - WordPressSupportSourceTag ClientApp Helper Methods
//
extension WordPressSupportSourceTag {

    /// Returns the matching SupportSourceTag enum case, matching for the current WordPressSupportSourceTag (Auth Framework) enum case.
    ///
    func toSupportSourceTag() -> SupportSourceTag {
        switch self {
        case .generalLogin:
            return .generalLogin
        case .jetpackLogin:
            return  .jetpackLogin
        case .loginEmail:
            return .loginEmail
        case .login2FA:
            return .login2FA
        case .loginMagicLink:
            return .loginMagicLink
        case .loginSiteAddress:
            return .loginSiteAddress
        case .loginUsernamePassword:
            return .loginUsernamePassword
        case .loginWPComPassword:
            return .loginWPComPassword
        case .wpComCreateSiteCreation:
            return .wpComCreateSiteCreation
        case .wpComCreateSiteDomain:
            return .wpComCreateSiteDomain
        case .wpComCreateSiteDetails:
            return .wpComCreateSiteDetails
        case .wpComSignupEmail:
            return .wpComSignupEmail
        case .wpComSignup:
            return .wpComSignup
        }
    }
}
