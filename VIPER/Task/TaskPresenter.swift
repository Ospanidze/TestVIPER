//
//  TaskPresenter.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

import Foundation
import RealmSwift

protocol TaskPresenterProtocol: AnyObject {
    func viewDidLoad()
    func task(at section: Int, and index: Int) -> Task
    func numberOfSection() -> Int
    func numberOfTasks(section: Int) -> Int
    func getTitleHeader(section: Int) -> String
    func getDoneTitle(section: Int) -> String
    func deleteTask(at indexPath: IndexPath)
    func editTask(_ task: Task, to newValue: String, withNote note: String, indexPath: IndexPath)
    func markTaskAsDone(at indexPath: IndexPath)
    func save(taskTitle: String, taskNote: String)
}

extension TaskPresenterProtocol {
    func numberOfSection() -> Int {
        2
    }
}

class TaskPresenter {
    weak var view: TaskViewProtocol?
    var router: TaskRouterProtocol
    var interactor: TaskInteractorProtocol
    
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    init(interactor: TaskInteractorProtocol, router: TaskRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

extension TaskPresenter: TaskPresenterProtocol {
    
    func viewDidLoad() {
        view?.get(title: interactor.title)
        currentTasks = interactor.getTasks().filter("isComplete = false")
        completedTasks = interactor.getTasks().filter("isComplete = true")
    }
    
    func task(at section: Int, and index: Int) -> Task {
        let task = section == 0
        ? currentTasks[index]
        : completedTasks[index]
        return task
    }
    
    func numberOfTasks(section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    func getTitleHeader(section: Int) -> String {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    func getDoneTitle(section: Int) -> String {
        section == 0 ? "done" : "undone"
    }
    
    func deleteTask(at indexPath: IndexPath) {
        let task = task(at: indexPath.section, and: indexPath.row)
        interactor.deleteTask(task) {
            view?.deleteRows(at: indexPath)
        }
    }
    
    func editTask(_ task: Task, to newValue: String, withNote note: String, indexPath: IndexPath) {
        interactor.editTask(task, to: newValue, withNote: note) {
            view?.reloadRows(at: indexPath)
        }
    }
    
    func markTaskAsDone(at indexPath: IndexPath) {
        let task = task(at: indexPath.section, and: indexPath.row)
        let currentTaskIndexPath = IndexPath(
            row: currentTasks.index(of: task) ?? 0,
            section: 0
        )
        
        let completeTaskIndexPath = IndexPath(
            row: completedTasks.index(of: task) ?? 0,
            section: 1
        )
        
        let destinationRow = indexPath.section == 0
        ? completeTaskIndexPath
        : currentTaskIndexPath
        interactor.markTaskAsDone(task) {
            view?.moveRow(at: indexPath, to: destinationRow)
        }
    }
    
    func save(taskTitle: String, taskNote: String) {
        interactor.save(taskTitle: taskTitle, withTaskNote: taskNote) { task in
            let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
            view?.insetRows(at: rowIndex)
        }
    }
}
