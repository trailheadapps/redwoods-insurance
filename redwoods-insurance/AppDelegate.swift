/*
Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.

Redistribution and use of this software in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.
* Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
endorse or promote products derived from this software without specific prior written
permission of salesforce.com, inc.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import UIKit
import SalesforceSDKCore

class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	override
	init() {
		super.init()
		SalesforceManager.initializeSDK()
		AuthHelper.registerBlock(forCurrentUserChangeNotifications: { [weak self] in
			self?.resetViewState {
				self?.setupRootViewController()
			}
		})

	}

	// MARK: - App delegate lifecycle

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		SFPushNotificationManager.sharedInstance().registerForRemoteNotifications()

		//Uncomment the code below to see how you can customize the color, textcolor, font and fontsize of the navigation bar
		//var loginViewConfig = LoginViewControllerConfig()
		//Set showSettingsIcon to NO if you want to hide the settings icon on the nav bar
		//loginViewConfig.showSettingsIcon = false
		//Set showNavBar to NO if you want to hide the top bar
		//loginViewConfig.showNavbar = true
		//loginViewConfig.navBarColor = UIColor(red: 0.051, green: 0.765, blue: 0.733, alpha: 1.0)
		//loginViewConfig.navBarTextColor = UIColor.white
		//loginViewConfig.navBarFont = UIFont(name: "Helvetica", size: 16.0)
		//UserAccountManager.sharedInstance().loginViewControllerConfig = loginViewConfig
		AuthHelper.loginIfRequired { [weak self] in
			self?.setupRootViewController()
		}

		return true
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

		SFPushNotificationManager.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
		if (UserAccountManager.shared.currentUserAccount?.credentials.accessToken != nil) {
			SFPushNotificationManager.sharedInstance().registerSalesforceNotifications(completionBlock: nil, fail: nil)
		}
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
		// Respond to any push notification registration errors here.
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		// Uncomment following block to enable IDP Login flow
		// return  UserAccountManager.sharedInstance().handleIDPAuthenticationResponse(url, options: options)
		return false
	}

	func setupRootViewController() {
		self.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil)
			.instantiateInitialViewController()
		self.window!.makeKeyAndVisible()
	}

	func resetViewState(_ postResetBlock: @escaping () -> Void) {
		if let rootViewController = self.window!.rootViewController {
			if let _ = rootViewController.presentedViewController {
				rootViewController.dismiss(animated: false, completion: postResetBlock)
				return
			}
		}
		postResetBlock()
	}

}
