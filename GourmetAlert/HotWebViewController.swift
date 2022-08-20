//
//  HotWebViewController.swift
//  GourmetAlert
//
//  Created by 今橋浩樹 on 2022/08/13.
//

import UIKit
import WebKit

class HotWebViewController: UIViewController {

    var webView: WKWebView!
    
    
    var storedShopName: String?
    var storedShopAddress: String?
    var storedURL: String?
    
    
    var bookmarkButtonItem: UIBarButtonItem!
    
    override func loadView() {
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let count = (self.navigationController?.viewControllers.count ?? 2) - 2
        if (self.navigationController?.viewControllers[count] as? ViewController) == nil {
            print(" from FavoriteViewController")
            } else {
            bookmarkButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(addButtonTapped))
            self.navigationItem.rightBarButtonItem = bookmarkButtonItem
        }
        
        guard let detailUrl = storedURL else { return }
        webViewLoad(detailUrl)
        

    }
    
    @objc func addButtonTapped() {
        if let storyboard: UIStoryboard = self.storyboard {
            guard let nextView = storyboard.instantiateViewController(withIdentifier: "favorite") as? FavoriteViewController else { return }
            
            nextView.receivedShopName = storedShopName
            nextView.receivedShopAddress = storedShopAddress
            nextView.receivedShopURL = storedURL
            
            nextView.openMode = switchOpenMode.forCreate.rawValue
            
            self.present(nextView, animated: true, completion: nil)
            print("tapped!")
        }
        
    }


}

extension HotWebViewController: WKNavigationDelegate {
    func webViewLoad(_ nextUrl: String) {
        if let url = URL(string: nextUrl) {
            webView.load(URLRequest(url:url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
}
