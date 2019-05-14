//
//  OZTable.swift
//  ZOwn
//
//  Created by zx on 2018/12/20.
//  Copyright © 2018年 oak. All rights reserved.
//

import UIKit

struct OZTableRowModel {
    var cell: UITableViewCell.Type
    var reuseId: String?
    var data: Any?
    var height: CGFloat = 0
}

typealias OZTableDataStructure = [OZTableRowModel]
typealias OZTableDataSectionStructure = Dictionary<Int, OZTableDataStructure>
typealias OZTableCellConfig = ((_ cell: UITableViewCell, _ data: Any?) -> Void)

class SSCommonTable: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var frame: CGRect {
        get {
            return self.tableView.frame
        }
        set {
            self.tableView.frame = newValue
        }
    }
    
    private(set) var tableView: UITableView
    
    private(set) var tableData: Any?
    
    private var cellBinding: OZTableCellConfig?
    
    var sectionCount: Int {
        get {
            
            if let data = self.tableData as? OZTableDataSectionStructure {
                return data.keys.count
            }
            
            return 1
        }
    }
    
    
    // MARK: - lifecycle
    
    deinit {
        print(self.description + "deinit")
    }
    
    override init() {
        self.tableView = UITableView.init(frame: CGRect.zero)
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // reloadData()会改变contentOffset，关掉这几个属性可以解决。
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
    }
    
    // MARK: - public
    func addTo(parent: UIView, frame: CGRect? = nil) {
        parent.addSubview(self.tableView)
        
        if frame != nil {
            self.frame = frame!
        }
    }
    
    func remove() {
        self.tableView.removeFromSuperview()
    }
    
    func updateData(_ data: Any?) {
        self.tableData = data
    }
    
    func configure(cell binding: @escaping OZTableCellConfig) {
        self.cellBinding = binding
        
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func reloadRows(_ rows: [Any], animation: UITableViewRowAnimation) {
        
        var array: [IndexPath]?
        
        if let indexs = rows as? [IndexPath] {
            array = indexs
        }else if let cells = rows as? [UITableViewCell] {
            var indexs = [IndexPath]()
            for cell in cells {
                if let index = self.tableView.indexPath(for: cell) {
                    indexs.append(index)
                }
            }
            array = indexs
        }
        
        if array?.isEmpty == false {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: array!, with: animation)
            self.tableView.endUpdates()
        }
        
    }
    
    // MARK: - private
    private func dataInSection(_ section: Int) -> OZTableDataStructure? {
        
        if let data = self.tableData as? OZTableDataStructure {
            return data
        }
        
        if let data = self.tableData as? OZTableDataSectionStructure {
            return data[section]
        }
        
        return nil
        
    }
    
    // MARK: -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = self.dataInSection(section) {
            return array.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let models = self.dataInSection(indexPath.section), indexPath.row < models.count {
            
            let model = models[indexPath.row]
            
            var cell: UITableViewCell?
            
            if model.reuseId != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: model.reuseId!)
            }
            
            if cell == nil {
                cell = model.cell.init(style: .default, reuseIdentifier: model.reuseId)
            }
            
            //            if let binding = self.cellBinding {
            //                binding(cell!, model.data)
            //            }
            
            return cell!
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let models = self.dataInSection(indexPath.section), indexPath.row < models.count {
            let model = models[indexPath.row]
            self.cellBinding?(cell, model.data)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let models = self.dataInSection(indexPath.section), indexPath.row < models.count {
            let model = models[indexPath.row]
            return model.height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}

