//
//  ViewController.swift
//  GourmetAlert
//
//  Created by 今橋浩樹 on 2022/08/12.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

struct shopData {
    var shopName = [String]()
    var shopAddress = [String]()
    var shopLogoImage = [String]()
    var shopURL = [String]()
}

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var articles = shopData()
    var image = UIImage()
    
    let baseURL = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=c73cb0c281eb859a"
    let countParameter = "&count=30"
    let format = "&format=json"
    
    func getArticleData(url: String) {
        
        refreshData()
        
        AF.request(url, method: .get)
            .responseData { response in
                switch (response.result) {
                case .success(let data):
                    print("Success! Got the data")
                    
                    let responseData: JSON = JSON(data)
                    print(responseData)
                    
                    // ここでデータを配列にはめる
                    for i in 0..<responseData["results"]["shop"].count {
                        
                    }
                }
                
            }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func refreshData() {
        self.articles.shopName.removeAll()
        self.articles.shopAddress.removeAll()
        self.articles.shopLogoImage.removeAll()
        self.articles.shopURL.removeAll()
        
    }


}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}



extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let changeSearchBar = searchBar.text?.replacingOccurrences(of: " ", with: ",") else { return }
        guard let changeSearchBar = searchBar.text?.replacingOccurrences(of: "　", with: ",") else { return }
        guard let encodeKeyBoard = changeSearchBar.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        
    }
}
