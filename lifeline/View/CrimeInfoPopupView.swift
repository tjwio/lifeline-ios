//
//  CrimInfoPopupView.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import UIKit
import SnapKit

class CrimeInfoPopupView: UIView {
    
    var items: [(icon: String, value: String)]
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .avenirDemi(size: 22.0)
        label.textColor = .white
        
        return label
    }()
    
    let drawerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "drawer"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "dark_background_image"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return imageView
    }()
    
    lazy var stackView: UIStackView = {
        let views = items.map { self.getStackView(icon: $0.icon, value: $0.value) }
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 12.0
        stackView.setContentHuggingPriority(.required, for: .vertical)
        
        return stackView
    }()
    
    init(items: [(icon: String, value: String)]) {
        self.items = items
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = UIColor(hexColor: 0x1C212D)
        
        addSubview(drawerImageView)
        addSubview(titleLabel)
        addSubview(stackView)
        
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        drawerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12.0)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.drawerImageView.snp.bottom).offset(12.0)
            make.leading.equalToSuperview().offset(24.0)
            make.trailing.equalToSuperview().offset(-24.0)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8.0)
            make.leading.equalToSuperview().offset(24.0)
            make.trailing.equalToSuperview().offset(-24.0)
            make.bottom.equalToSuperview().offset(-24.0)
        }
        
        super.updateConstraints()
    }
    
    private func getStackView(icon: String, value: String) -> UIStackView {
        let iconLabel = UILabel()
        iconLabel.font = .materialIcons(size: 20.0)
        iconLabel.text = icon
        iconLabel.textColor = .white
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.font = .avenirMedium(size: 16.0)
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [iconLabel, valueLabel])
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 10.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
}
