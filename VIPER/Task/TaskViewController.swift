//
//  TaskViewController.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

import UIKit

protocol TaskViewProtocol: AnyObject {
    func get(title: String)
    func reloadData()
    func deselectRow(at indexPath: IndexPath)
    func deleteRows(at indexPath: IndexPath)
    func reloadRows(at indexPath: IndexPath)
    func insetRows(at indexPath: IndexPath)
    func moveRow(at indexPath: IndexPath, to destinationIndexPath: IndexPath)
}

class TaskViewController: UIViewController {
    // MARK: - Public
    var presenter: TaskPresenterProtocol?
    
    private let taskTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    // MARK: - Overrire Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        presenter?.viewDidLoad()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        taskTableView.setEditing(editing, animated: animated)
    }
    
    @objc private func plusTapped() {
        showAlert()
    }
}

//MARK: - UITableViewDataSource
extension TaskViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter?.numberOfSection() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfTasks(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath
        )
        let task = presenter?.task(at: indexPath.section, and: indexPath.row)
        var content = cell.defaultContentConfiguration()
        content.text = task?.title
        content.secondaryText = task?.note
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        presenter?.getTitleHeader(section: section)
    }
}

//MARK: - UITableViewDelegate
extension TaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = presenter?.task(at: indexPath.section, and: indexPath.row)
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            self.presenter?.deleteTask(at: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: task, indexPath: indexPath)
            isDone(true)
        }
        
        let doneTitle = presenter?.getDoneTitle(section: indexPath.section)
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { _, _, isDone in
            self.presenter?.markTaskAsDone(at: indexPath)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [
            doneAction, editAction, deleteAction
        ])
    }
}

// MARK: - Private functions
private extension TaskViewController {
    func initialize() {
        view.backgroundColor =  .white
        setupTaskTableView()
        setupBarButtonItems()
    }
    
    func setupTaskTableView() {
        taskTableView.frame = view.bounds
        taskTableView.delegate = self
        taskTableView.dataSource = self
        view.addSubview(taskTableView)
    }
    
    func setupBarButtonItems() {
        let plusButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(plusTapped)
        )
        
        navigationItem.rightBarButtonItems = [plusButton, editButtonItem]
    }
}

//MARK: ShowAlert
extension TaskViewController {
    private func showAlert(
        with task: Task? = nil,
        indexPath: IndexPath? = nil
    ) {
        let tasksAlertFactory = TaskAlertControllerFactory(
            userAction: task != nil ? .editTask : .newTask,
            taskTitle: task?.title,
            taskNote: task?.note
        )
        
        let alert = tasksAlertFactory.createAlert { [weak self] taskTitle, taskNote in
            if let task, let indexPath {
                self?.presenter?.editTask(task, to: taskTitle, withNote: taskNote, indexPath: indexPath)
                return
            }
            self?.presenter?.save(taskTitle: taskTitle, taskNote: taskNote)
        }
        present(alert, animated: true)
    }
}

// MARK: - TaskViewProtocol
extension TaskViewController: TaskViewProtocol {
    func get(title: String) {
        self.title = title
    }
    
    func reloadData() {
        taskTableView.reloadData()
    }
    
    func deselectRow(at indexPath: IndexPath) {
        taskTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func deleteRows(at indexPath: IndexPath) {
        taskTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func reloadRows(at indexPath: IndexPath) {
        taskTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func insetRows(at indexPath: IndexPath) {
        taskTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func moveRow(at indexPath: IndexPath, to destinationIndexPath: IndexPath) {
        taskTableView.moveRow(at: indexPath, to: destinationIndexPath)
    }
    
}
