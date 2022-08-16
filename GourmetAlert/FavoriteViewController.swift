//
//  FavoriteViewController.swift
//  GourmetAlert
//
//  Created by 今橋浩樹 on 2022/08/13.
//

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController {

    
    @IBOutlet weak var selectShopName: UILabel!
    @IBOutlet weak var selectShopAddress: UILabel!
    @IBOutlet weak var selectURL: UILabel!
    
    @IBOutlet weak var notificationTiming: UISegmentedControl!
    
    var receivedShopName: String?
    var receivedShopAddress: String?
    var receivedShopURL: String?
    
    var currentId: Int = 0
    var currentLunchCount: Int = 0
    var currentDinnerCount: Int = 0
    let saveLimit: Int = 2
    var limitOver: Bool = false

    let idForLunch:String = "Lunch"
    let idForDinner:String = "Dinner"
    var notificationId:String = ""
    
    var searchKey: Int = 0
    var latestIndex: Int = 0
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentData()
        
        selectShopName.text = receivedShopName
        selectShopAddress.text = receivedShopAddress
        selectURL.text = receivedShopURL

    }
    

    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        returnView()
    
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        limitOver = false

        checkLimit()
        if limitOver == true { return }
    
        realmRegister()
        notificationRegister()
        returnView()
        
    }
    
    func returnView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkLimit() {
        switch notificationTiming.selectedSegmentIndex {
        case SegmentSelected.isLunch.rawValue:
            if currentLunchCount >= saveLimit {
                print("昼が限界")
                limitOver = true
            }
        case SegmentSelected.isDinner.rawValue:
            if currentDinnerCount >= saveLimit {
                print("夕が限界")
                limitOver = true
            }
        default:
            print("checkLimit Irregular")
            limitOver = true
        }
    }
    
    func realmRegister() {
        let favorite = FavoriteData()
        favorite.id = currentId + 1
        favorite.shopName = selectShopName.text!
        favorite.shopAddress = selectShopAddress.text!
        favorite.shopURL = selectURL.text!
        
        switch notificationTiming.selectedSegmentIndex {
        case SegmentSelected.isLunch.rawValue:
            favorite.notificationTiming = Timing.lunch.rawValue
        case SegmentSelected.isDinner.rawValue:
            favorite.notificationTiming = Timing.dinner.rawValue
        default:
            print("Irregular")
            return
        }
        
        try! realm.write {
            realm.add(favorite)
        }
        
        fetchCurrentData()
    }
    
    func fetchCurrentData() {
        let currentData = realm.objects(FavoriteData.self)
        if (currentData != nil && currentData.count != 0) {
            currentId = currentData.value(forKeyPath: "@max.id") as! Int
        }
        
        let forLunch = realm.objects(FavoriteData.self).filter("notificationTiming == %@", Timing.lunch.rawValue)
        print("昼データ\(forLunch)")
        currentLunchCount = forLunch.count
        print(currentLunchCount)
        
        let forDinner = realm.objects(FavoriteData.self).filter("notificationTiming == %@", Timing.dinner.rawValue)
        print("夕データ\(forDinner)")
        currentDinnerCount = forDinner.count
        print(currentDinnerCount)

    }
    
    func notificationRegister() {

        let content = UNMutableNotificationContent()

        switch notificationTiming.selectedSegmentIndex {
        case SegmentSelected.isLunch.rawValue:
            searchKey = Timing.lunch.rawValue
            latestIndex = currentLunchCount - 1
            notificationId = idForLunch
            
        case SegmentSelected.isDinner.rawValue:
            searchKey = Timing.dinner.rawValue
            latestIndex = currentDinnerCount - 1
            notificationId = idForDinner
            
        default:
            print("Irregular")
            return
        }
        
        let forNotificationRecord = realm.objects(FavoriteData.self).filter("notificationTiming == %@", searchKey)
        let latestRecord = forNotificationRecord[latestIndex].shopName
        
        content.title = latestRecord
        content.body = "気になっていたお店に行きませんか"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
