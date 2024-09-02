//
//  TaskListRouter.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

protocol TaskListRouterProtocol {
    func openTasks(in taskLisk: TaskList)
}

class TaskListRouter: TaskListRouterProtocol {
    weak var viewController: TaskListViewController?
    
    func openTasks(in taskLisk: TaskList) {
        let vc = TaskModuleBuilder.build(taskList: taskLisk)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
