//
//  UITableViewCell + ext.swift
//  VIPER
//
//  Created by Айдар Оспанов on 03.09.2024.
//

import UIKit

extension UITableViewCell {
    
    func configure(with model: CellModel?) {
        guard let model else { return }
        var content = defaultContentConfiguration()
        
        content.text = model.title
        content.secondaryText = model.subtitle
        accessoryType = model.accessoryType
        contentConfiguration = content
    }
}
