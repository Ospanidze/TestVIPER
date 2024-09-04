//
//  TaskListViewController.swift
//  Super easy dev
//
//  Created by Айдар Оспанов on 02.09.2024
//

import UIKit
import SnapKit

protocol TaskListViewProtocol: AnyObject {
    func reloadData()
    func deselectRow(at indexPath: IndexPath)
    func deleteRows(at indexPath: IndexPath)
    func reloadRows(at indexPath: IndexPath)
    func insetRows(at indexPath: IndexPath)
}

class TaskListViewController: UIViewController {
    
    // MARK: - Public
    var presenter: TaskListPresenterProtocol?
    
    private let taskListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.rowHeight = 44
        tableView.sectionHeaderHeight = 29
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var taskListSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Date", "A-Z"])
        segment.selectedSegmentTintColor = .white
        segment.backgroundColor = .systemGray5
        segment.selectedSegmentIndex = 0
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        segment.setTitleTextAttributes(attributes, for: .normal)
        segment.addTarget(self, action: #selector(taskListSegmentControlTapped), for: .valueChanged)
        return segment
    }()

    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskListTableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        taskListTableView.setEditing(editing, animated: animated)
    }
    
    @objc private func plusTapped() {
        print("Plus button tapped")
        showAlert()
    }
    
    @objc private func taskListSegmentControlTapped(sender: UISegmentedControl) {
        presenter?.sortingList(at: sender.selectedSegmentIndex)
    }
}

// MARK: - TaskListViewProtocol
extension TaskListViewController: TaskListViewProtocol {
    func reloadData() {
        taskListTableView.reloadData()
    }
    
    func deselectRow(at indexPath: IndexPath) {
        taskListTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func deleteRows(at indexPath: IndexPath) {
        taskListTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func reloadRows(at indexPath: IndexPath) {
        taskListTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func insetRows(at indexPath: IndexPath) {
        taskListTableView.insertRows(at: [indexPath], with: .automatic)
    }
}

//MAKR: - UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfTaskLists() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let taskCellModel = presenter?.getCellModel(indexPath: indexPath)
        cell.configure(with: taskCellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        headerView.addSubview(taskListSegmentControl)
        taskListSegmentControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return headerView
    }
}

//MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.cellDidTap(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = presenter?.taskList(at: indexPath.row)
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            self.presenter?.deleteTaskList(at: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: taskList, indexPath: indexPath)
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            self.presenter?.markTaskListAsDone(at: indexPath)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [
            doneAction, editAction, deleteAction
        ])
    }
}

//MARK: ShowAlert
extension TaskListViewController {
    private func showAlert(
        with taskList: TaskList? = nil,
        indexPath: IndexPath? = nil
    ) {
        let listAlertFactory = TaskListAlertControllerFactory(
            userAction: taskList != nil ? .editList : .newList,
            listTitle: taskList?.title
        )
        
        let alert = listAlertFactory.createAlert { [weak self] newValue in
            if let taskList, let indexPath {
                self?.presenter?.editTaskList(taskList, with: newValue, indexPath: indexPath)
                return
            }
            self?.presenter?.save(taskListTitle: newValue)
        }
        present(alert, animated: true)
    }
}

// MARK: - Private functions
private extension TaskListViewController {
    func initialize() {
        view.backgroundColor = .white
        title = "Task List"
        
        setupTaskListTableView()
        setupDelegates()
        setupNavBar()
        
    }
    
    func setupTaskListTableView() {
        view.addSubview(taskListTableView)
        taskListTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupDelegates() {
        taskListTableView.delegate = self
        taskListTableView.dataSource = self
    }
    
    func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar
            .compactScrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let plusButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(plusTapped)
        )
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = plusButton
    }
}

