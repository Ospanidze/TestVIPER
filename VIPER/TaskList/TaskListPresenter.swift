//
//  TaskListPresenter.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

import Foundation
import RealmSwift

protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func numberOfTaskLists() -> Int
    func taskList(at index: Int) -> TaskList
    func cellDidTap(at indexPath: IndexPath)
    func deleteTaskList(at indexPath: IndexPath)
    func editTaskList(_ taskList: TaskList, with newTitle: String, indexPath: IndexPath)
    func markTaskListAsDone(at indexPath: IndexPath)
    func save(taskListTitle: String)
    func sortingList(at index: Int)
}

class TaskListPresenter {
    weak var view: TaskListViewProtocol?
    var router: TaskListRouterProtocol
    var interactor: TaskListInteractorProtocol
    
    private var taskLists: Results<TaskList>!

    init(interactor: TaskListInteractorProtocol, router: TaskListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

extension TaskListPresenter: TaskListPresenterProtocol {
    func viewDidLoad() {
        interactor.fetchTaskLists { [weak self] taskLists in
            self?.taskLists = taskLists
            self?.view?.reloadData()
        }
        
        interactor.createTempDataIfNeeded { [weak self] in
            self?.view?.reloadData()
        }
    }
    
    func numberOfTaskLists() -> Int {
        return taskLists.count
    }
    
    func taskList(at index: Int) -> TaskList {
        return taskLists[index]
    }
    
    func cellDidTap(at indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]
        router.openTasks(in: taskList)
        view?.reloadRows(at: indexPath)
    }
    
    func deleteTaskList(at indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]
        interactor.deleteTaskList(taskList) { [weak self] in
            self?.view?.deleteRows(at: indexPath)
        }
    }
    
    func editTaskList(_ taskList: TaskList, with newTitle: String, indexPath: IndexPath) {
        interactor.editTaskList(taskList, newTitle: newTitle) {
            self.view?.reloadRows(at: indexPath)
        }
    }
    
    func markTaskListAsDone(at indexPath: IndexPath) {
        let taskList = taskLists[indexPath.row]
        interactor.markTaskListAsDone(taskList) { [weak self] in
            self?.view?.reloadRows(at: indexPath)
        }
    }
    
    func save(taskListTitle: String) {
        interactor.save(taskListTitle: taskListTitle) { taskList in
            let indexPath = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0)
            view?.insetRows(at: indexPath)
        }
    }
    
    func sortingList(at index: Int) {
        taskLists = index == 0
        ? taskLists.sorted(byKeyPath: "date")
        : taskLists.sorted(byKeyPath: "title")
        view?.reloadData()
    }
}
