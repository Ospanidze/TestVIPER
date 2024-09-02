//
//  TaskListModuleBuilder.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

import UIKit

class TaskListModuleBuilder {
    static func build() -> TaskListViewController {
        let interactor = TaskListInteractor()
        let router = TaskListRouter()
        let presenter = TaskListPresenter(interactor: interactor, router: router)
        let viewController = TaskListViewController()
        presenter.view  = viewController
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        return viewController
    }
}
