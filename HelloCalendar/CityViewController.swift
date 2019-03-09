//
//  CityViewController.swift
//  HelloCalendar
//
//  Created by B.Mossavi on 2/2/19.
//  Copyright © 2019 B.Mossavi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UserNotifications
import CoreLocation
import MapKit
import AVFoundation

class CityViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var fajr: UILabel!
    @IBOutlet weak var shurooq: UILabel!
    @IBOutlet weak var dhuhr: UILabel!
    @IBOutlet weak var maghrib: UILabel!
    @IBOutlet weak var isha: UILabel!
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var switchNotification: UISwitch!
    
    var locationManager = CLLocationManager()
    var switchState: Bool = false
    var cityName = "Tehran"
    var player = AVAudioPlayer()
    var stringArray: [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateJSON(city : cityName)
        cityLabel.text = cityName
        locationSettings()
        
        
        if UserDefaults.standard.object(forKey: "setting") == nil {
            print("settings not exist")
        } else {
            let states = UserDefaults.standard.bool(forKey: "setting")
            switchState = states
            switchNotification.isOn = switchState
        }
    }
    
    //BUTTONS
    @IBAction func changeCityButton(_ sender: Any) {
        if let cityNameChanged = cityTextField.text {
            updateJSON(city: cityNameChanged)
            cityLabel.text = cityNameChanged
        }
    }
    
    @IBAction func switchButton(_ sender: UISwitch) {
        if sender.isOn {
            print("on")
            switchState = true
            playAzan(infoArr: stringArray)
        } else {
            print("off")
            switchState = false
        }
        UserDefaults.standard.set(switchState, forKey: "setting")
    }
    
    @IBAction func pause(_ sender: Any) {
        player.stop()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = CLLocation(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        findCityLocation(from: userLocation) { city, country, error in
            guard let city = city else { return }
            print("city: \(city)")
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.cityLabel.text = city
            })
        }
    }
    
    //FUNCTIONS
    func updateJSON(city : String) {
        
        let baseURL = "http://muslimsalat.com/\(city).json?key=b77e7b911dfea79a65a0cb901039fa6c"

        Alamofire.request(baseURL).responseJSON { response in
            
            if response.result.isSuccess {
                
                print("Success")
                
                let cityJSON : JSON = JSON(response.result.value)
                print(cityJSON["items"])
                
                self.fajr.text = cityJSON["items"][0]["fajr"].stringValue
                self.timeSeperator(time: cityJSON["items"][0]["fajr"].stringValue, tag: "نماز صبح")
                
                self.shurooq.text = cityJSON["items"][0]["shurooq"].stringValue
                self.timeSeperator(time: cityJSON["items"][0]["shurooq"].stringValue, tag: "طلوع آفتاب")
                
                self.dhuhr.text = cityJSON["items"][0]["dhuhr"].stringValue
                self.timeSeperator(time: cityJSON["items"][0]["dhuhr"].stringValue, tag: "نماز ظهر و عصر")
                
                self.maghrib.text = cityJSON["items"][0]["maghrib"].stringValue
                self.timeSeperator(time: cityJSON["items"][0]["maghrib"].stringValue, tag: "غروب آفتاب")
                
                self.isha.text = cityJSON["items"][0]["isha"].stringValue
                self.timeSeperator(time: cityJSON["items"][0]["isha"].stringValue, tag: "نماز مغرب و عشا")
                
            } else {
                print("no")
            }
            
        }
        
    }
    
    func timeSeperator(time: String, tag: String) {
        stringArray = time.components(separatedBy: CharacterSet.decimalDigits.inverted)
        stringArray.insert(tag, at: 2)
        print(stringArray)
        
        notification(infoArr: stringArray)
    }
    
    func notification(infoArr: [String]) {
        
        let content = UNMutableNotificationContent()
        content.title = infoArr[2]
        content.body = "اینک زمان \(infoArr[2]) است"
        content.sound = UNNotificationSound.default
        
        let dateComponent = DateComponents(calendar: Calendar.current, hour: Int(infoArr[0]), minute: Int(infoArr[1]))
        let timeTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: infoArr[2], content: content, trigger: timeTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func playAzan(infoArr: [String]) {
        let date = Calendar.current.date(bySettingHour: Int(infoArr[0])!, minute: Int(infoArr[1])!, second: 00, of: Date())
        let timer = Timer(fireAt: date!, interval: 0, target: self, selector: #selector(play), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .default)
    }
    
    @objc func play() {
        let audioPath = Bundle.main.path(forResource: "azan", ofType: "mp3")
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
            player.play()
        } catch {
            print(error.localizedDescription)
        }
    }

    func findCityLocation(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    func locationSettings() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
