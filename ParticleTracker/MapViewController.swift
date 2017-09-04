//
//  ViewController.swift
//  ParticleTracker
//
//  Created by JakkritS on 5/17/2559 BE.
//  Copyright © 2559 AppIllustrator. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton! {
        didSet {
            print("button did set")
            fbLoginButton.readPermissions = ["email"]
        }
    }
    
    let locationManager = CLLocationManager()
    
    var electrons = [SparkDevice]() {
        didSet {
            print(electrons)
        }
    }
    
    var photons = [SparkDevice]() {
        didSet {
            //
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sparkLogin()
        
        fbLoginButton.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera = GMSCameraPosition.cameraWithLatitude(13.7563, longitude: 100.5018, zoom: 6)
        
        mapView.animateToCameraPosition(camera)
        
        mapView.myLocationEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Bangkok"
        marker.snippet = "Thailand"
        marker.map = mapView
        
    }
    
    //MARK: - Login Button Delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        fetchUserProfile()
    }
    
    func fetchUserProfile() {
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, user, requestError) -> Void in
            
            if requestError != nil {
                print(requestError)
                return
            }
            
            let email = user["email"] as! String
            let firstName = user["first_name"] as! String
            let lastName = user["last_name"] as! String
            
            var pictureUrl = ""
            
            if let picture = user["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary, url = data["url"] as? String {
                pictureUrl = url
            }
            
            print("\(email), \(firstName), \(lastName), \(pictureUrl)")
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    //MARK: - Particle Functions
    func sparkLogin() {
        SparkCloud.sharedInstance().loginWithUser("izeroman@gmail.com", password: "044251994") { (error) -> Void in
            if error == nil {
                print("logged in")
                SparkCloud.sharedInstance().getDevices { (devices, error) -> Void in
                    for device in devices as! [SparkDevice] {
                        //self.availableDevices.append(device)
                        if(device.type == .Electron) {
                            print("*********** ELECTRON *************")
                            print(device.name)
                            self.electrons.append(device)
                        } else {
                            print("*********** PHOTON *************")
                            print(device.name)
                        }
                    }
                    self.getVariables()
                }
            } else {
                print("wrong credentials")
            }
        }
    }
    
    func getVariables() {
        for device in electrons {
            device.getVariable("GPS", completion: { (result:AnyObject?, error:NSError?) -> Void in
                if let error = error {
                    print("Failed reading from device: \(error)")
                }
                else {
                    if let gps = result as? String {
                        print("GPS \(gps) ")
                    }
                }
            })
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()

            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true

        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 15)
            
            locationManager.stopUpdatingLocation()
        }
        
    }
}
