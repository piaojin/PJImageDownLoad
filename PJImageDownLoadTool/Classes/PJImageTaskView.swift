//
//  PJImageTaskView.swift
//  PJImageDownLoadTool
//
//  Created by piaojin on 2019/4/6.
//  Copyright © 2019 ywyw.piaojin. All rights reserved.
//

import Alamofire
import Cocoa

public typealias PJImageDownLoadCompleteBlock = (Bool) -> ()

private enum TextFieldType: Int {
    case url
    case fileName
}

class PJImageTaskView: NSTableRowView {
    
    var urlTextField: NSTextField = {
        let urlTextField = NSTextField()
        urlTextField.placeholderString = "Input url here..."
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        urlTextField.tag = TextFieldType.url.rawValue
        return urlTextField
    }()
    
    var fileNameTextField: NSTextField = {
        let fileNameTextField = NSTextField()
        fileNameTextField.placeholderString = "Input file name"
        fileNameTextField.translatesAutoresizingMaskIntoConstraints = false
        fileNameTextField.tag = TextFieldType.fileName.rawValue
        return fileNameTextField
    }()
    
    var downLoadButton: NSButton = {
        let downLoadButton = NSButton()
        downLoadButton.title = "DownLoad"
        downLoadButton.translatesAutoresizingMaskIntoConstraints = false
        downLoadButton.bezelStyle = NSButton.BezelStyle.regularSquare
        return downLoadButton
    }()
    
    var imageTask: PJImageTask? {
        didSet {
            if let tempImageTask = imageTask {
                self.updateUI(task: tempImageTask)
            }
        }
    }
    
    var downLoadCompleteBlock: PJImageDownLoadCompleteBlock?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initView()
        self.initData()
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return event
        }
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyDown(with event: NSEvent) {
        if event.characters == "\r" {
            self.downLoadAction()
        }
    }
    
    private func initView() {
        self.selectionHighlightStyle = .none
        self.addSubview(self.fileNameTextField)
        self.fileNameTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        self.fileNameTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        self.fileNameTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        self.fileNameTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.addSubview(self.downLoadButton)
        self.downLoadButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        self.downLoadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        self.downLoadButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        self.addSubview(self.urlTextField)
        self.urlTextField.topAnchor.constraint(equalTo: self.fileNameTextField.topAnchor).isActive = true
        self.urlTextField.leadingAnchor.constraint(equalTo: self.fileNameTextField.trailingAnchor, constant: 10).isActive = true
        self.urlTextField.bottomAnchor.constraint(equalTo: self.fileNameTextField.bottomAnchor).isActive = true
        self.urlTextField.trailingAnchor.constraint(equalTo: self.downLoadButton.leadingAnchor, constant: -10).isActive = true
    }
    
    private func initData() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(notification:)), name: NSControl.textDidChangeNotification, object: nil)
        
        self.downLoadButton.target = self
        self.downLoadButton.action = #selector(downLoadAction)
    }
    
    @objc private func downLoadAction() {
        if let state = self.imageTask?.state, (state == .completed || state == .inProgress) {
            return
        }
        
        guard let lastSavePath = PJImageCache.shared.lastSavePath  else {
            self.showAlert(messageText: "Notice", informativeText: "Please select save path!")
            return
        }
        
        if self.urlTextField.stringValue.isEmpty || self.fileNameTextField.stringValue.isEmpty {
            self.showAlert(messageText: "Notice", informativeText: "The url and file name cannot be null!")
            return
        }
        
        if let downLoadUrl = try? self.urlTextField.stringValue.asURL() {
            if let destinationURL = URL(string: "\(lastSavePath)\(self.fileNameTextField.stringValue).\(downLoadUrl.pathExtension)") {
                
                if let tempPath = destinationURL.absoluteString.removingPercentEncoding {
                    let tempFilePath = tempPath as NSString
                    let sRange = tempFilePath.range(of: "file://")
                    let str = tempFilePath.substring(with: NSMakeRange(sRange.location + sRange.length, tempFilePath.length - sRange.length))
                    
                    if FileManager.default.fileExists(atPath: str) {
                        self.showAlert(messageText: "Notice", informativeText: "The file name is ready used, please change another one!")
                        return
                    }
                }
                
                let downloadRequest: DownloadRequest = Alamofire.AF.download(downLoadUrl) { (url, response) -> (destinationURL: URL, options: DownloadRequest.Options) in
                    return (destinationURL, DownloadRequest.Options.createIntermediateDirectories)
                }
                
                downloadRequest.response { (response) in
                    DispatchQueue.main.async(execute: {
                        if response.error == nil {
                            self.updateDownLoadState(state: .completed)
                        } else {
                            self.updateDownLoadState(state: .failure)
                            self.showAlert(messageText: "Error", informativeText: "DownLoad error: \(String(describing: response.error))", alertStyle: .critical)
                        }
                        self.downLoadCompleteBlock?(response.error == nil)
                    })
                }
            } else {
                self.updateDownLoadState(state: .determined)
                self.showAlert(messageText: "Error", informativeText: "Can't get destinationURL absoluteString removingPercentEncoding!", alertStyle: .critical)
            }
        } else {
            self.updateDownLoadState(state: .determined)
            self.showAlert(messageText: "Error", informativeText: "Get downLoadUrl error!", alertStyle: .critical)
        }
    }
    
    private func updateDownLoadState(state: DownLoadState) {
        var title: String = ""
        switch state {
        case .completed:
            title = DownLoadState.completeStr
        case .determined:
            title = DownLoadState.downLoadStr
        case .failure:
            title = DownLoadState.retryStr
        case .inProgress:
            title = DownLoadState.downLoadingStr
        }
        self.imageTask?.state = state
        self.downLoadButton.title = title
    }
    
    private func updateUI(task: PJImageTask) {
        self.updateDownLoadState(state: task.state)
        self.urlTextField.stringValue = task.downLoadUrl
        self.fileNameTextField.stringValue = task.fileName
    }
    
    @objc private func textFieldDidChange(notification: NSNotification) {
        if let textField = notification.object as? NSTextField {
            if textField.tag == TextFieldType.url.rawValue {
                self.imageTask?.downLoadUrl = textField.stringValue
            } else {
                self.imageTask?.fileName = textField.stringValue
            }
        }
    }
    
    private func showAlert(messageText: String, informativeText: String, alertStyle: NSAlert.Style = .warning) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = messageText
        alert.informativeText = informativeText
        if let window = NSApplication.shared.keyWindow {
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        self.fileNameTextField.becomeFirstResponder()
        return result
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
