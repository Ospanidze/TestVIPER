//
//  StorageManager.swift
//  VIPER
//
//  Created by Айдар Оспанов on 02.09.2024.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    private let realm = try! Realm()
    
    private init() {}
    
    // MARK: - Task List
    func save(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    func save(_ taskListTitle: String, completion: (TaskList) -> Void) {
        write {
            let taskList = TaskList(value: [taskListTitle])
            realm.add(taskList)
            completion(taskList)
        }
    }
    
    func delete(_ taskList: TaskList) {
        write {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
        }
    }
    
    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.title = newValue
        }
    }

    func done(_ taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }

    // MARK: - Tasks
    func save(_ taskTitle: String, withTaskNote taskNote: String, to taskList: TaskList, completion: (Task) -> Void) {
        write {
            let task = Task(value: [taskTitle, taskNote])
            taskList.tasks.append(task)
            completion(task)
        }
    }
    
    func delete(_ task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func edit(_ task: Task, to newValue: String, withNote note: String = "") {
        write {
            task.title = newValue
            task.note = note
        }
    }
    
    func done(_ task: Task) {
        write {
            task.isComplete.toggle()
        }
    }
    
    // MARK: - Reading
    func fetchAllTaskLists() -> Results<TaskList> {
        return realm.objects(TaskList.self)
    }
    
//    func fetchTaskList(byTitle title: String) -> TaskList? {
//        return realm.objects(TaskList.self).filter("title = %@", title).first
//    }
//    
//    func fetchTasks(from taskList: TaskList) -> List<Task> {
//        return taskList.tasks
//    }
    
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
