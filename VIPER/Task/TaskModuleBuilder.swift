//
//  TaskModuleBuilder.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

import UIKit

class TaskModuleBuilder {
    static func build(taskList: TaskList) -> TaskViewController {
        let interactor = TaskInteractor(taskList: taskList)
        let router = TaskRouter()
        let presenter = TaskPresenter(interactor: interactor, router: router)
        let viewController = TaskViewController()
        presenter.view  = viewController
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        return viewController
    }
}
