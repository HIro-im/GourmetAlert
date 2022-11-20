# グルメアラート

<h2>アプリ概要</h2>

 ホットペッパーAPIを使って、ホットペッパーからフリーワード検索でお店の検索結果を出力させることと、お気に入りのお店を保存できるアプリ。  
 検索結果をタップすると、ホットペッパーの画面に遷移して、情報を確認することが出来る。  
 また、お気に入り登録をする際に、お昼で行きたいか夕食で行きたいかを選択しておくことで、それぞれのリストに区別して保存しておくことが出来る。  
 さらに、12時と18時には通知を行い、その際にお昼・夕食それぞれで登録しておいたお店の内、最新の店名が通知に表示されるようになっている。  
 この通知をタップすると、それぞれに対応したリストが表示される。
 
 
![GourmetAlert](https://user-images.githubusercontent.com/82436202/202898053-8bfc3c4a-03e2-42e8-8376-609c240e9a32.gif)


<h2>機能一覧</h2>

* ホットペッパー内のフリーワード検索機能
* 検索結果の一覧出力
* Webビューでのホットペッパーの元ページ表示
* 検索結果へ戻る機能
* お気に入り登録機能(通知時間帯選択と保存リスト選択可能)
* お気に入り一覧出力(別タブで出力)
* お気に入り内容から元ページへの遷移
* お気に入り削除
* お気に入りの通知タイミング変更
* ローカル通知出力
* 通知タップによるお気に入り一覧遷移


<h2>開発環境</h2>

* MacBook Air (M1, 2020)
* macOS Monterey 
* Xcode(Version 13.4)
* Swift version 5.6.1

<h2>使用技術</h2>

* UIKit
* WebKit
* Realm
* Alamofire/AlamofireImage
* SwiftyJSON
* UNUserNotificationCenter
* API(ホットペッパーAPI)
