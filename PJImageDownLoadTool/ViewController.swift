//
//  ViewController.swift
//  PJImageDownLoadTool
//
//  Created by piaojin on 2019/4/6.
//  Copyright © 2019 ywyw.piaojin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    private let newKeyAction = "n"
    private let cleanKeyAction = "k"
    private let saveToKeyAction = "s"
    
    var savePathLabel: NSTextField = {
        let savePathLabel = NSTextField(labelWithString: "")
        savePathLabel.translatesAutoresizingMaskIntoConstraints = false
        return savePathLabel
    }()
    
    var cleanButton: NSButton = {
        let cleanButton = NSButton()
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        cleanButton.title = "Clean"
        cleanButton.bezelStyle = NSButton.BezelStyle.regularSquare
        return cleanButton
    }()
    
    var addButton: NSButton = {
        let addButton = NSButton()
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.title = "Add"
        addButton.bezelStyle = NSButton.BezelStyle.regularSquare
        return addButton
    }()
    
    var saveToButton: NSButton = {
        let saveToButton = NSButton()
        saveToButton.translatesAutoresizingMaskIntoConstraints = false
        saveToButton.title = "SaveTo"
        saveToButton.bezelStyle = NSButton.BezelStyle.regularSquare
        return saveToButton
    }()
    
    var tableView: NSTableView = {
        let tableView = NSTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsColumnSelection = true
        tableView.headerView = nil
        return tableView
    }()
    
    var tasks: [PJImageTask] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.initData()
    }
    
    private func initView() {
        self.title = "PJImageDownLoad"
        
        self.view.addSubview(self.cleanButton)
        self.cleanButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.cleanButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.cleanButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        self.cleanButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true

        self.view.addSubview(self.saveToButton)
        self.saveToButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.saveToButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.saveToButton.trailingAnchor.constraint(equalTo: self.cleanButton.leadingAnchor, constant: -10).isActive = true
        self.saveToButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        
        self.view.addSubview(self.addButton)
        self.addButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.addButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.addButton.trailingAnchor.constraint(equalTo: self.saveToButton.leadingAnchor, constant: -10).isActive = true
        self.addButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        
        self.view.addSubview(self.savePathLabel)
        self.savePathLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.savePathLabel.topAnchor.constraint(equalTo: self.addButton.topAnchor).isActive = true
        self.savePathLabel.bottomAnchor.constraint(equalTo: self.addButton.bottomAnchor).isActive = true
        self.savePathLabel.trailingAnchor.constraint(equalTo: self.addButton.leadingAnchor, constant: -10).isActive = true
        
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = .width
        
        self.view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.cleanButton.bottomAnchor, constant: 10).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
        
        scrollView.documentView = self.tableView
        
        self.tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    private func initData() {
        self.savePathLabel.stringValue = "Save to: \(PJImageCache.shared.lastSavePath?.absoluteString.removingPercentEncoding ?? "Please selected save path!")"
        
        self.tasks.append(PJImageTask())
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.cleanButton.target = self
        self.cleanButton.action = #selector(cleanAction)
        
        self.addButton.target = self
        self.addButton.action = #selector(addAction)
        
        self.saveToButton.target = self
        self.saveToButton.action = #selector(saveToAction)
        
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) { (event) -> NSEvent? in
            return self.keyDownAction(with: event)
        }
    }
    
    private func keyDownAction(with event: NSEvent) -> NSEvent {
        if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue) != 0 {
            guard let key = event.characters else {
                return event
            }
            
            switch key.lowercased() {
            case newKeyAction:
                self.addAction()
            case cleanKeyAction:
                self.cleanAction()
            case saveToKeyAction:
                self.saveToAction()
            default: break
            }
        }
        return event
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc private func addAction() {
        self.tasks.append(PJImageTask())
        self.tableView.reloadData()
        let lastView = self.tableView.rowView(atRow: self.tasks.count - 1, makeIfNecessary: true)
        lastView?.becomeFirstResponder()
    }
    
    @objc private func saveToAction() {
        self.selectFile()
    }
    
    @objc private func cleanAction() {
        self.tasks.removeAll()
        self.addAction()
    }
    
    private func selectFile() {
        let dialog = NSOpenPanel()
        dialog.title = "Save file to"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.directoryURL = PJImageCache.shared.lastSavePath
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let filePath = dialog.url {
                print("selected file save path: \(filePath)")
                let filePathStr = (filePath.absoluteString.removingPercentEncoding ?? "") as NSString
                let sRange = filePathStr.range(of: "file://")
                let str = filePathStr.substring(with: NSMakeRange(sRange.location + sRange.length, filePathStr.length - sRange.length)).removingPercentEncoding
                if let tempStr = str {
                    PJImageCache.shared.lastSavePath = URL(fileURLWithPath: tempStr, isDirectory: true)
                    self.savePathLabel.stringValue = "Save to: \(tempStr)"
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.tasks.count
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let imageTaskView = PJImageTaskView()
        imageTaskView.imageTask = self.tasks[row]
        imageTaskView.downLoadCompleteBlock = { isSuccess in
            if isSuccess {
//                tableView.beginUpdates()
//                self.tasks.remove(at: row)
//                tableView.reloadData()
//                tableView.endUpdates()
//                if self.tasks.count == 0 {
//                    self.addAction()
//                }
                
                var shouldAddNewEmptyTask = true
                
                for task in self.tasks {
                    if task.state != .completed {
                        shouldAddNewEmptyTask = false
                        break
                    }
                }
                
                if shouldAddNewEmptyTask {
                    self.addAction()
                }
            }
        }
        return imageTaskView
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return PJImageTaskView()
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 44.0
    }
    
//    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
//        let deleteAction = NSTableViewRowAction(style: NSTableViewRowAction.Style.destructive, title: "Delete") { (action, tempRow) in
//            self.tasks.remove(at: tempRow)
//            tableView.reloadData()
//        }
//        return [deleteAction]
//    }
//
//    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
//        return true
//    }
}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        tableView.deselectRow(tableView.selectedRow)
    }
}

