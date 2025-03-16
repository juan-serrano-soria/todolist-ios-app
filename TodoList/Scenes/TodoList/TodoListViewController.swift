//
//  ViewController.swift
//  TodoList
//
//  Created by Serrano Soria, Juan on 04/03/2025.
//

import UIKit


// MARK: - Storage Errors
enum StorageError: Error {
    case saveFailure
    case loadFailure
    
    var message: String {
        switch self {
        case .saveFailure:
            return "Failed to save todos"
        case .loadFailure:
            return "Failed to load todos"
        }
    }
}


class TodoListViewController: UIViewController {
    
    // MARK: - Properties
    private var todos: [Todo] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var currentTodos: [Todo] {
        guard searchController.isActive,
              let searchText = searchController.searchBar.text,
              !searchText.isEmpty else {
            return todos
        }
        
        return todos.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    // Empty state
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No todos yet!\nTap + to add a new todo"
        label.numberOfLines = 0 // allow multiple lines
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadTodos()
        updateEmptyState()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !todos.isEmpty
    }
    
    private func setupNavigationBar() {
        title = "Todo List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Todos"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false // to fix initial hidden search bar
        definesPresentationContext = true
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    // MARK: - Storage Methods
    private func saveTodos() {
        do {
            let encodedData = try JSONEncoder().encode(todos)
            UserDefaults.standard.set(encodedData, forKey: "todos")
            UserDefaults.standard.synchronize() // fixes the problem of persistence
        } catch {
            showError(StorageError.saveFailure)
        }
    }
    
    private func loadTodos() {
        guard let savedData = UserDefaults.standard.data(forKey: "todos") else { return }
        
        do{
            let loadedTodos = try JSONDecoder().decode([Todo].self, from: savedData)
            todos = loadedTodos
        } catch {
            showError(StorageError.loadFailure)
        }
    }
    
    private func showError(_ error: StorageError) {
        let alert = UIAlertController(
            title: "Error",
            message: error.message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let alert = UIAlertController(
            title: "New Todo",
            message: "Enter a new todo item",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Enter todo..."
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text,
                  !text.isEmpty else { return }
            
            let newTodo = Todo(title: text)
            self?.todos.append(newTodo)
            self?.tableView.reloadData()
            self?.saveTodos()
            self?.updateEmptyState()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

}

// MARK: - UITableView DataSource and Delegate
extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTodos.count
    }
    
    // Configure and return cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let todo = currentTodos[indexPath.row]
        
        if todo.isCompleted {
            let attributedText = NSAttributedString(
                string: todo.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.systemGray
                ]
            )
            cell.textLabel?.attributedText = attributedText
        } else {
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = todo.title
        }
        
        cell.accessoryType = todo.isCompleted ? .checkmark : .none
        return cell
    }
    
    // select and mark as complete
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                cell.transform = .identity
                // Get the actual todo from currentTodos
                let todo = self.currentTodos[indexPath.row]
                // Find and update in the main todos array
                if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                    self.todos[index].isCompleted.toggle()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        saveTodos()
    }
    
    // swipe to remove
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the todo to delete
            let todoToDelete = currentTodos[indexPath.row]
            // Remove from main array
            if let index = todos.firstIndex(where: { $0.id == todoToDelete.id }) {
                todos.remove(at: index)
                tableView.reloadData()
                saveTodos()
                updateEmptyState()
            }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
}

