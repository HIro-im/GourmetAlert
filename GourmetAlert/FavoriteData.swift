//
//  FavoriteData.swift
//  GourmetAlert
//
//  Created by 今橋浩樹 on 2022/08/13.
//

import Foundation
import RealmSwift

class FavoriteData: Object {
    @Persisted(primaryKey: true)var id = 0
    @Persisted var shopName = ""
    @Persisted var shopAddress = ""
    @Persisted var shopURL = ""
    @Persisted var notificationTiming = 0
}
