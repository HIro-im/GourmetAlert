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
    
    let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=c73cb0c281eb859a"
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
                        guard let name = responseData["results"]["shop"][i]["name"].string else { return }
                        self.articles.shopName.append(name)
                        guard let address = responseData["results"]["shop"][i]["address"].string else { return }
                        self.articles.shopAddress.append(address)
                        guard let LogoImage = responseData["results"]["shop"][i]["logo_image"].string else { return }
                        self.articles.shopLogoImage.append(LogoImage)
                        guard let URL = responseData["results"]["shop"][i]["urls"]["pc"].string else { return }
                        self.articles.shopURL.append(URL)
                    }
                    
                case .failure(let error):
                    print("Error: \(String(describing: error))")
                }
                
                if self.articles.shopName.count > 0 {
                    self.tableView?.reloadData()
                }
                
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
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
        return articles.shopName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MainTableViewCell
        cell.shopNameLabel?.text = articles.shopName[indexPath.row]
        cell.shopAddressLabel?.text = articles.shopAddress[indexPath.row]

        if let imageURL = URL(string: self.articles.shopLogoImage[indexPath.row]) {
            cell.img!.af.setImage(withURL: imageURL)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "HotWeb") as? HotWebViewController {
            vc.storedShopName = self.articles.shopName[indexPath.row]
            vc.storedShopAddress = self.articles.shopAddress[indexPath.row]
            vc.storedURL = self.articles.shopURL[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}



extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let changeSearchBar = searchBar.text?.replacingOccurrences(of: " ", with: ",") else { return }
        guard let changeSearchBar = searchBar.text?.replacingOccurrences(of: "　", with: ",") else { return }
        guard let encodeKeyword = changeSearchBar.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        getArticleData(url: baseURL + "&keyword=" + encodeKeyword + countParameter + format)
        self.tableView.reloadData()
        
        searchBar.resignFirstResponder()
    }
}
