//
//  FavoriteListViewController.swift
//  GourmetAlert
//
//  Created by 今橋浩樹 on 2022/08/17.
//

import UIKit
import RealmSwift

class FavoriteListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    
    var selectedTiming: Int = 0
    
    var filtData: Results<FavoriteData>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        setTiming()
        
        filtData = getData(selectedTiming)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 挙動観測のための一文
        print("table viewWillAppear")
        
        // realm内のテーブルを取り出して、メンバ変数への格納と件数を取得する
        setTiming()
        filtData = getData(selectedTiming)
        
        // リストビューを再読込する
        tableView.reloadData()
        
    }
    
    func setTiming() {
        switch navigationController?.tabBarItem.tag {
        case Timing.lunch.rawValue:
            selectedTiming = Timing.lunch.rawValue
        case Timing.dinner.rawValue:
            selectedTiming = Timing.dinner.rawValue
        default:
            print("another")
        }
    }
    
    func getData(_ selectTab: Int) -> Results<FavoriteData> {
        let filterData = realm.objects(FavoriteData.self).filter("notificationTiming == %@", selectTab)
        return filterData
    }


}

extension FavoriteListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let counter = filtData?.count {
            return counter
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // ここを強制アンラップにしない方法はないか
        cell.textLabel?.text = filtData?[indexPath.row].shopName
        cell.detailTextLabel?.text = filtData?[indexPath.row].shopAddress
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 遷移先のビューコントローラのインスタンスを用意する
        if let vc = storyboard?.instantiateViewController(withIdentifier: "favorite") as? FavoriteViewController {
            
            // リストからタップされたIDを渡す
            vc.receivedId = filtData?[indexPath.row].id
            
            vc.openMode = switchOpenMode.forReference.rawValue
            
            // 遷移を実行させる(階層をつなげた遷移(=ナビゲーションバーのbackが使える)を実現したいのでpushする
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    
}
