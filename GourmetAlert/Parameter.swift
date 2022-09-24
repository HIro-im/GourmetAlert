//
//  Parameter.swift
//  GourmetAlert
//
//  Created by 今橋浩樹 on 2022/08/13.
//

import Foundation

enum SegmentSelected :Int {
    case isLunch = 0
    case isDinner = 1
}

enum Timing :Int {
    case lunch = 1
    case dinner = 2
}

enum switchOpenMode: Int {
    case forCreate = 1
    case forReference = 2
}

enum setParamMode: Int {
    case changeOnce = 1
    case changeTwice = 2
}
