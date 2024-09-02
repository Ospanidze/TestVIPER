//
//  UITableViewCell + ext.swift
//  VIPER
//
//  Created by Айдар Оспанов on 03.09.2024.
//

import UIKit

extension UITableViewCell {
    
    func configure(with taskList: TaskList?) {
        guard let taskList else { return }
        let currenTasks = taskList.tasks.filter("isComplete = false")
        var content = defaultContentConfiguration()
        
        content.text = taskList.title
        
        if taskList.tasks.isEmpty {
            content.secondaryText = "0"
            accessoryType = .none
        } else if currenTasks.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            content.secondaryText = currenTasks.count.formatted()
            accessoryType = .none
        }
        
        contentConfiguration = content
    }
}
