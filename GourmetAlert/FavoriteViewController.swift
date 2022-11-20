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
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var notificationTiming: UISegmentedControl!
    
    var composeButtonItem: UIBarButtonItem!
    var trashButtonItem: UIBarButtonItem!
    
    var receivedShopName: String?
    var receivedShopAddress: String?
    var receivedShopURL: String?
    
    var currentId: Int = 0
    var currentLunchCount: Int = 0
    var currentDinnerCount: Int = 0
    let saveLimit: Int = 10
    var limitOver: Bool = false

    let idForLunch:String = "Lunch"
    let idForDinner:String = "Dinner"
    var notificationId:String = ""
    
    let titleForAlert = "登録件数オーバー"
    let messageForCreate = "登録先のお店を1件削除してください"
    let messageForReference = "変更先のお店を1件削除してください"
    
    var searchKey: Int = 0
    var latestIndex: Int = 0
    
    var selectedId: Int = 0
    var selectTab: Int = 0
    var editTiming: Int = 0
    // 仮で作成するが、後でちゃんとリファクタリングすること
    // 編集時のみ、変更前の通知と変更後の通知をいじらなければいけないので、
    // そのために必要な変数を作る
    var editNotificationTiming: Int = 0
    var editNotificationId: String = ""
    var subtitle: String = ""
    
    var notificationTimer: DateComponents?

    let realm = try! Realm()
    
    
    // 詳細画面を開いたときの状態を識別する
    var openMode: Int = 0
    // 保存・取消ボタンの処理を切り替えるための変数
    var switchProcess: Int = 0
    
    var receivedId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        buttonConfig(openMode)
        setData(openMode)
        
        
        switch openMode {
        case switchOpenMode.forCreate.rawValue:
            fetchCurrentData()
            
        case switchOpenMode.forReference.rawValue:
            fetchCurrentData()
            addTapRecognizer()
        default:
            print("Irregular case")
        }
        
        

    }
    
    func addTapRecognizer() {
        // URLが書いてあるラベルをタップすると処理が行われるようにしている
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapURL))
        self.selectURL.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // URLリンクタップ時の処理
    @objc func tapURL() {
        // 確認用のptint(削除可能)
        print("tapURL")
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "HotWeb") as? HotWebViewController {
            vc.storedURL = selectURL.text
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
            
    func buttonConfig(_ currentMode: Int) {
        
        switch currentMode {
        case switchOpenMode.forCreate.rawValue:
            cancelButton.isHidden = false
            saveButton.isHidden = false
            notificationTiming.isEnabled = true
            
        case switchOpenMode.forReference.rawValue:
            cancelButton.isHidden = true
            saveButton.isHidden = true
            notificationTiming.isEnabled = false
            
            composeButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeButtonTapped))
            trashButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonTapped))
            self.navigationItem.rightBarButtonItems = [composeButtonItem, trashButtonItem]

        default:
            print("Received Error")
        }
        
    }
    
    func setData(_ currentMode: Int) {
        switch currentMode {
        case switchOpenMode.forCreate.rawValue:
            selectShopName.text = receivedShopName
            selectShopAddress.text = receivedShopAddress
            selectURL.text = receivedShopURL
            // 初期値(選択のデフォルト)
            notificationTiming.selectedSegmentIndex = SegmentSelected.isLunch.rawValue
            
        case switchOpenMode.forReference.rawValue:
            let selectedData = realm.objects(FavoriteData.self).filter("id == %@", receivedId)
            
            selectShopName.text = selectedData[0].shopName
            selectShopAddress.text = selectedData[0].shopAddress
            selectURL.text = selectedData[0].shopURL

            if selectedData[0].notificationTiming ==  Timing.lunch.rawValue {
                notificationTiming.selectedSegmentIndex = SegmentSelected.isLunch.rawValue
                
            } else {
                notificationTiming.selectedSegmentIndex = SegmentSelected.isDinner.rawValue
                
            }
            
            setParamForNotification(ofSetMode: setParamMode.forEdit.rawValue, selectedData[0].notificationTiming)
            selectedId = selectedData[0].id

        default:
            print("Received Error")
        }
        
    }
    
    // メモを修正するための処理
    @objc func composeButtonTapped() {
        
        // 戻るボタン・編集ボタン・削除ボタンを非表示にする
        // (統一感を出すために戻るボタンを非表示にする)
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.hidesBackButton = true
                
        // 取消ボタン・保存ボタンの表示を行う
        cancelButton.isHidden = false
        saveButton.isHidden = false
        
        notificationTiming.isEnabled = true
        
    }
    
    // メモを削除するための処理
    @objc func trashButtonTapped() {
        let alert = UIAlertController(title: "ブックマークの削除", message: "このブックマークを削除してもよろしいですか？", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "キャンセル", style: .default)
        
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: {(action) -> Void in

            // 削除したいデータを検索する
            let deleteData = self.realm.objects(FavoriteData.self).filter("id == %@", self.selectedId)
            
            do {
                try self.realm.write {
                    self.realm.delete(deleteData)
                }
            } catch {
                print("Error \(error)")
            }
            
            self.notificationDecrement(self.searchKey, self.notificationId)
            
            // リストに遷移するための処理(pushだと階層が深くなってしまって、戻るボタンが表示されてしまうため、popを使う)
            self.navigationController?.popViewController(animated: true)

        })
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    

    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        switch openMode {
        case switchOpenMode.forCreate.rawValue:
            returnView()
            
        case switchOpenMode.forReference.rawValue:
            cancelButton.isHidden = true
            saveButton.isHidden = true
            self.navigationItem.rightBarButtonItems = [composeButtonItem, trashButtonItem]
            self.navigationItem.hidesBackButton = false
            
        default:
            print("Irregular cancel")
        }

    
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        limitOver = false

        checkLimit()
        if limitOver == true {
            
            switch openMode {
            case switchOpenMode.forCreate.rawValue:
                limitOverMessagePresent(messageFor: messageForCreate)
                
            case switchOpenMode.forReference.rawValue:
                limitOverMessagePresent(messageFor: messageForReference)
                
            default:
                print("Irregular Alert")
            }
            
            return
        }
    
        switch openMode {
        case switchOpenMode.forCreate.rawValue:
            realmRegister()
            switch notificationTiming.selectedSegmentIndex {
            case SegmentSelected.isLunch.rawValue:
                setParamForNotification(ofSetMode: setParamMode.forNotEdit.rawValue, Timing.lunch.rawValue)
                
            case SegmentSelected.isDinner.rawValue:
                setParamForNotification(ofSetMode: setParamMode.forNotEdit.rawValue, Timing.dinner.rawValue)
                
            default:
                print("saveButton For SaveMode error")
            }
            notificationRegister(searchKey,notificationId)

        case switchOpenMode.forReference.rawValue:
            realmUpdate()
            notificationDecrement(searchKey, notificationId)
            notificationRegister(editNotificationTiming, editNotificationId)
            
        default:
            print("Irregular save")
        }
        returnView()

        
    }
    
    func returnView() {

        switch openMode {
        case switchOpenMode.forCreate.rawValue:
            self.dismiss(animated: true, completion: nil)
            
        case switchOpenMode.forReference.rawValue:
            navigationController?.popViewController(animated: true)
            
        default:
            print("Irregular return")
            
        }
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
    
    func realmUpdate() {
        let editData = self.realm.objects(FavoriteData.self).filter("id == %@", self.selectedId)
        
        switch notificationTiming.selectedSegmentIndex {
        case SegmentSelected.isLunch.rawValue:
            editTiming = Timing.lunch.rawValue
        case SegmentSelected.isDinner.rawValue:
            editTiming = Timing.dinner.rawValue
        default:
            print("Irregular")
            return
        }
        
        do {
            try realm.write {
                editData[0].notificationTiming = editTiming
            }
        } catch {
            print("Error: \(error)")
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
    
    
    // この下の処理は特にリファクタリングをかけたい(重複が多すぎる)
    func notificationRegister(_ searchKey: Int, _ notificationId: String) {

        // 共通化できそう
        
        let content = UNMutableNotificationContent()

        let forNotificationRecord = realm.objects(FavoriteData.self).filter("notificationTiming == %@", searchKey)
        let latestRecord = forNotificationRecord[forNotificationRecord.count - 1].shopName
        
        content.title = latestRecord
        
        // content.bodyの設定
        notificationBodyMessage(notificationId)
        
        content.body = subtitle
        
        notificationSetTimer(notificationId)
        
        guard let date = notificationTimer else { return }
        
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func notificationDecrement(_ searchKey: Int, _ notificationId: String) {
        let filterData = realm.objects(FavoriteData.self).filter("notificationTiming == %@", searchKey)
        if filterData == nil || filterData.count == 0 {
            print("alert delete")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        } else {
            // 共通化できそう
            notificationRegister(searchKey, notificationId)
        }
        
    }
        
    func setParamForNotification(ofSetMode setMode: Int, _ notificationTiming: Int) {
        
        switch notificationTiming {
        case Timing.lunch.rawValue:
            searchKey = Timing.lunch.rawValue
            notificationId = idForLunch
            
        case  Timing.dinner.rawValue:
            searchKey = Timing.dinner.rawValue
            notificationId = idForDinner
            
        default:
            print("setParamForNotification First error")
        }
        
        // 更新処理以外は以降の処理を実施しないようreturnで抜けさせる
        if setMode == setParamMode.forNotEdit.rawValue {
            return
        }

        //　更新処理時の通知登録処理用にパラメータをセットする
        switch notificationTiming {
        case Timing.lunch.rawValue:
            editNotificationTiming = Timing.dinner.rawValue
            editNotificationId = idForDinner
            
        case  Timing.dinner.rawValue:
            editNotificationTiming = Timing.lunch.rawValue
            editNotificationId = idForLunch
            
        default:
            print("setParamForNotification Second error")
        }
        
    }
    
    // content.bodyの設定
    func notificationBodyMessage(_ notificationId: String) {
        switch notificationId {
        case idForLunch:
            subtitle = "お昼ごはんで気になっているお店があります"
            
        case idForDinner:
            subtitle = "夕ご飯で気になっているお店があります"
            
        default:
            print("Subtitle is Irregular")
        }
        
    }
    
    func notificationSetTimer(_ notificationId: String) {
        switch notificationId {
        case idForLunch:
            notificationTimer = DateComponents(hour:12, minute:00)
            
        case idForDinner:
            notificationTimer = DateComponents(hour:18, minute:00)
        
        default:
            print("setDateComponents error")
        }
    }
    
    func limitOverMessagePresent(messageFor messageContent: String) {
        let alert = UIAlertController(title: titleForAlert, message: messageContent, preferredStyle: .alert)
        
        let OK = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(OK)
        
        self.present(alert, animated: true, completion: nil)
    }

}
