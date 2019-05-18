//
//  PJImageCache.swift
//  PJImageDownLoadTool
//
//  Created by piaojin on 2019/4/6.
//  Copyright © 2019 ywyw.piaojin. All rights reserved.
//

import Cocoa

enum PJImageCacheKey {
    static var lastSavePathKey = "LastSavePathKey"
}

class PJImageCache: NSObject {
    
    static let shared: PJImageCache = PJImageCache()
    
    var lastSavePath: URL? {
        get {
            if let temp_lastSavePath = self._lastSavePath {
                return temp_lastSavePath
            } else {
                self._lastSavePath = NSUserDefaultsController.shared.defaults.url(forKey: PJImageCacheKey.lastSavePathKey)
                return self._lastSavePath
            }
        }
        
        set {
            self._lastSavePath = newValue
            NSUserDefaultsController.shared.defaults.set(newValue, forKey: PJImageCacheKey.lastSavePathKey)
        }
    }
    private var _lastSavePath: URL?
}
