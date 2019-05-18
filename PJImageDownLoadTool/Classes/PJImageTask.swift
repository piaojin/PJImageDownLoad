//
//  PJImageTask.swift
//  PJImageDownLoadTool
//
//  Created by piaojin on 2019/4/6.
//  Copyright © 2019 ywyw.piaojin. All rights reserved.
//

import Cocoa

enum DownLoadState {
    case inProgress
    case completed
    case failure
    case determined
    
    static let completeStr = "Complete"
    static let retryStr = "Retry"
    static let downLoadingStr = "DownLoading"
    static let downLoadStr = "DownLoad"
}

class PJImageTask: NSObject {
    var downLoadUrl: String = ""
    var localPath: String = ""
    var fileName: String = ""
    var state: DownLoadState = .determined
}
