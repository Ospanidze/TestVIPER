//
//  TaskList.swift
//  VIPER
//
//  Created by Айдар Оспанов on 02.09.2024.
//

import RealmSwift
import Foundation

class TaskList: Object {
    @Persisted var title = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

class Task: Object {
    @Persisted var title = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
