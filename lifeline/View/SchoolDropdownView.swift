//
//  SchoolDropdownView.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import UIKit
import SnapKit

protocol SchoolDropdownViewDelegate: class {
    func schoolDropdown(_ view: SchoolDropdownView, didSelect item: String, at index: Int)
}

class SchoolDropdownView: UIView, UITableViewDelegate, UITableViewDataSource {
    private struct Constants {
        static let cellIdentifier = "SchoolDropdownTableViewCellIdentifier"
    }
    
    weak var delegate: SchoolDropdownViewDelegate?
    
    var items = [String]()
    var selectedItem: String?
    var isDropdownShowing = false
    
    var dangerLevel: DangerLevel = .ok {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = true
        let backgroundImageView = UIImageView(image: UIImage(named: "dark_background_image"))
        backgroundImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = backgroundImageView
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubview(tableView)
    }
    
    override func updateConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(48.0)
        }
        
        super.updateConstraints()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isDropdownShowing ? items.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as? SchoolDropdownTableViewCell ?? SchoolDropdownTableViewCell(style: .default, reuseIdentifier: Constants.cellIdentifier)
        
        if indexPath.row == 0 {
            cell.dangerImageView.isHidden = false
            cell.dangerImageView.image = dangerLevel.image
            
            cell.dropdownImageView.isHidden = false
            cell.dropdownImageView.image = isDropdownShowing ? UIImage(named: "chevron_up") : UIImage(named: "chevron_down")
            cell.nameLabel.text = selectedItem
        } else {
            let index = indexPath.row - 1
            let item = items[index]
            
            cell.dangerImageView.isHidden = true
            cell.dropdownImageView.isHidden = true
            cell.nameLabel.text = item
        }
        
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        isDropdownShowing = !isDropdownShowing
        
        if indexPath.row > 0 {
            let index = indexPath.row - 1
            
            selectedItem = items[index]
            delegate?.schoolDropdown(self, didSelect: items[index], at: index)
        }
        
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        
        tableView.snp.updateConstraints { make in
            make.height.equalTo(self.isDropdownShowing ? 48.0 * Double(self.items.count + 1) : 48.0)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.superview?.layoutIfNeeded()
        }
    }
}
