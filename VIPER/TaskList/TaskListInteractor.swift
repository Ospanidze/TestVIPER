//
//  TaskListInteractor.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

import Foundation
import RealmSwift

protocol TaskListInteractorProtocol: AnyObject {
    func fetchTaskLists(completion: @escaping (Results<TaskList>) -> Void)
    func createTempDataIfNeeded(completion: @escaping () -> Void)
    func deleteTaskList(_ taskList: TaskList, completion: @escaping () -> Void)
    func editTaskList(_ taskList: TaskList, newTitle: String, completion: @escaping () -> Void)
    func markTaskListAsDone(_ taskList: TaskList, completion: @escaping () -> Void)
    func save(taskListTitle: String, completion: (TaskList) -> Void)
}

class TaskListInteractor: TaskListInteractorProtocol {
    weak var presenter: TaskListPresenterProtocol?
    
    private let dataManager = DataManager.shared
    private let storageManager = StorageManager.shared
    
    func fetchTaskLists(completion: @escaping (Results<TaskList>) -> Void) {
        let taskLists = storageManager.fetchAllTaskLists()
        completion(taskLists)
    }
    
    func createTempDataIfNeeded(completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {
            DataManager.shared.createTempData {
                UserDefaults.standard.set(true, forKey: "done")
                completion()
            }
        }
    }
    
    func deleteTaskList(_ taskList: TaskList, completion: @escaping () -> Void) {
        storageManager.delete(taskList)
        completion()
    }
    
    func editTaskList(_ taskList: TaskList, newTitle: String, completion: @escaping () -> Void) {
        storageManager.edit(taskList, newValue: newTitle)
        completion()
    }
    
    func markTaskListAsDone(_ taskList: TaskList, completion: @escaping () -> Void) {
        storageManager.done(taskList)
        completion()
    }
    
    func save(taskListTitle: String, completion: (TaskList) -> Void) {
        storageManager.save(taskListTitle, completion: completion)
    }
}
