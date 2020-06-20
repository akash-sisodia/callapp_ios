//
//  AppDelegate.swift
//  CallApp
//
//  Created by Akash Singh Sisodia on 19/06/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import UIKit

var sceneDelegate: SceneDelegate?
var appDelegate: AppDelegate?

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var networkReachable = false
    //private let reachability = try! Reachability()
    
    let mainStoryboard: UIStoryboard = {
        return UIStoryboard(name: "Main", bundle: nil)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 13.0, *) {
            window = sceneDelegate?.window
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            self.window = window
        }
        initialConfiguration()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func initialConfiguration() {
        /*
         // Setup Firebase
         FirebaseApp.configure()
         
         // Register device for remote notifications.
         registerForPushNotifications()
         
         // Enable Reachability
         RechabilityHelper.setup()
         
         // Configure IQKeyboardManager
         setupKeyboard()
         
         // Check User Session
         checkUserSession()
         */
    }
    
    /// setting up IQKeyboardManager
    func setupKeyboard() {
        /*
         IQKeyboardManager.shared.enable = true
         IQKeyboardManager.shared.shouldResignOnTouchOutside = true
         IQKeyboardManager.shared.shouldPlayInputClicks = true
         IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
         IQKeyboardManager.shared.enableAutoToolbar = true
         */
    }
    
    /// Validating user's login session
    func checkUserSession() {
        /*
         if LoggedInUser.shared.checkLastUserSession() {
         setupRootViewController()
         } else {
         setUpInitialViewController()
         }
         */
    }
}
/*
 //Root Navigations
 extension AppDelegate {
 
 //Setup Root View Controller
 func setupRootViewController() -> Void {
 
 let navigationController = UINavigationController(rootViewController: getDashboard())
 navigationController.setNavigationBarHidden(true, animated: false)
 self.window?.rootViewController = navigationController
 }
 
 /// Initial View Controller will be launched on first installation and no user session is present
 /// - Returns: initial controller inside a navigation controller
 func setUpInitialViewController() -> Void {
 
 let navigationController = UINavigationController(rootViewController: getLanding())
 navigationController.setNavigationBarHidden(true, animated: false)
 self.window?.rootViewController = navigationController
 }
 
 public func getDashboard() -> UIViewController {
 
 let slideMenuVC = mainStoryboard.instantiateViewController(withIdentifier: "SlideMenuVC") as! SlideMenuVC
 let home = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
 let slideMenuController = SlideMenuController(mainViewController: home, leftMenuViewController: slideMenuVC)
 return slideMenuController
 }
 
 /// Landing View controller for initial launch
 /// - Returns: landingviewcontroller
 public func getLanding() -> UIViewController {
 
 return mainStoryboard.instantiateViewController(withIdentifier: "EnterPhoneVC") as! EnterPhoneVC
 }
 }
 
 // MARK: APNS Methods
 extension AppDelegate: UNUserNotificationCenterDelegate {
 
 /// Registring for push notifications
 private func registerForPushNotifications() {
 
 let center = UNUserNotificationCenter.current()
 center.delegate = self
 
 center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
 guard error == nil, granted else {
 print("User Notifications: Permission not granted")
 return
 }
 
 self.getNotificationSettings()
 }
 }
 
 private func getNotificationSettings() {
 UNUserNotificationCenter.current().getNotificationSettings { settings in
 guard settings.authorizationStatus == .authorized else {
 return
 }
 
 DispatchQueue.main.async {
 UIApplication.shared.registerForRemoteNotifications()
 }
 }
 }
 
 /// check if apn is enabled in the application
 /// - Returns: boolean value if application is registered for push notification or not
 func isAPNSEnable() -> Bool {
 return UIApplication.shared.isRegisteredForRemoteNotifications
 }
 
 func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
 let _ = deviceToken.map({ String(format: "%02.2hhx", $0 ) }).joined()
 InstanceID.instanceID().instanceID { (result, error) in
 if let error = error {
 print("Error fetching remote instance ID: \(error)")
 } else if let result = result {
 print("Remote instance ID token: \(result.token)")
 LoggedInUser.deviceToken = result.token
 print("Remote instance ID token: \(result.token)")
 
 }
 }
 }
 
 func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
 print(error.localizedDescription)
 }
 
 func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
 //appDelegate.appBadgeCount += 1
 let userInfo = notification.request.content.userInfo
 handleNotifications(userInfo, isFromBanner: false)
 completionHandler([.sound, .badge, .alert])
 }
 
 func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
 let userInfo = response.notification.request.content.userInfo
 handleNotifications(userInfo, isFromBanner: true)
 completionHandler()
 }
 
 private func handleNotifications(_ userInfo: [AnyHashable: Any], isFromBanner: Bool) {
 guard UserDefaults.standard.bool(forKey: "UserLoggedIn"), let topController = UIApplication.topViewController() else {
 return
 }
 
 print(userInfo)
 if let notificationType = userInfo["gcm.notification.type"] as? String {
 
 if notificationType == "request" {
 if let id = userInfo["gcm.notification.transcationId"] as? String {
 
 }
 }
 }
 }
 }
 */
