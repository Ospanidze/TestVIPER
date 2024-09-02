//
//  TaskInteractor.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

import Foundation
import RealmSwift

protocol TaskInteractorProtocol: AnyObject {
    var title: String { get }
    func getTasks() -> List<Task>
    func deleteTask(_ task: Task, completion: () -> Void)
    func editTask(_ task: Task, to newValue: String, withNote note: String, completion: () -> Void)
    func markTaskAsDone(_ task: Task, completion: () -> Void)
    func save(taskTitle: String, withTaskNote taskNote: String, completion: (Task) -> Void)
}

class TaskInteractor: TaskInteractorProtocol {
    var title = "Unknown"
    
    weak var presenter: TaskPresenterProtocol?
    private let storageManager = StorageManager.shared
    
    let taskList: TaskList
    
    init(taskList: TaskList) {
        self.taskList = taskList
        title = taskList.title
    }
    
    func getTasks() -> List<Task> {
        taskList.tasks
    }
    
    func deleteTask(_ task: Task, completion: () -> Void) {
        storageManager.delete(task)
        completion()
    }
    
    func editTask(_ task: Task, to newValue: String, withNote note: String, completion: () -> Void) {
        storageManager.edit(task, to: newValue, withNote: note)
        completion()
    }
    
    func markTaskAsDone(_ task: Task, completion: () -> Void) {
        storageManager.done(task)
        completion()
    }
    
    func save(taskTitle: String, withTaskNote:String, completion: (Task) -> Void) {
        storageManager.save(
            taskTitle,
            withTaskNote: withTaskNote,
            to: taskList,
            completion: completion
        )
    }
    
}
