//
//  AppDelegate.swift
//  ParticleTracker
//
//  Created by JakkritS on 5/17/2559 BE.
//  Copyright © 2559 AppIllustrator. All rights reserved.
//

import UIKit
import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let firebaseURL = "https://particletracker.firebaseio.com/"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey("AIzaSyD2yeLAAH586ua-oZVoPN_3b_pD-n07neY")
       
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL,
                     sourceApplication: String?, annotation: AnyObject) -> Bool {
    
        let wasHandled = FBSDKApplicationDelegate.sharedInstance()
            .application(application, openURL: url,
                         sourceApplication: sourceApplication, annotation: annotation)
        if(wasHandled) {
            sendAuthToFirebase()
        }
        
        return wasHandled
    }
    
    func sendAuthToFirebase() {
        print(#function)
        //Reference to Firebase
        let firebaseRef = Firebase(url: firebaseURL)
        //FB Access Token
        let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
     
        print(firebaseRef)
        firebaseRef.authWithOAuthProvider("facebook", token: fbAccessToken) { (error, authData) in
            if(error != nil) {
                print("Firebase Login Failed \(error)")
            } else {
                print("Firebase Logged in \(authData)")
                
                let newUser = ["provider": authData.provider,
                               "displayName": authData.providerData["displayName"] as! String,
                               "email": authData.providerData["email"] as! String]
                firebaseRef.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
            }
        }
    }
    
    func deauthToFirebase() {
        //TODO: - StopLocationUpdates
    }
}
























