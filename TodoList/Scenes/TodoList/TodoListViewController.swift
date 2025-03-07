//
//  ViewController.swift
//  TodoList
//
//  Created by Serrano Soria, Juan on 04/03/2025.
//

import UIKit

class TodoListViewController: UIViewController {
    
    // MARK: - Properties
    private var todos: [Todo] = []
    
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: "Todocell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Todo List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        // handle adding todos
    }

}

// MARK: - UITableView DataSource and Delegate
extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    // Configure and return cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let todo = todos[indexPath.row]
        cell.textLabel?.text = todo.title
        cell.accessoryType = todo.isCompleted ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // add todo completion
    }
    
}

