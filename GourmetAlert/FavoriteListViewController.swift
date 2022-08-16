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

        switch navigationController?.tabBarItem.tag {
        case Timing.lunch.rawValue:
            selectedTiming = Timing.lunch.rawValue
        case Timing.dinner.rawValue:
            selectedTiming = Timing.dinner.rawValue
        default:
            print("another")
        }
        
        filtData = getData(selectedTiming)
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
    
    
}
