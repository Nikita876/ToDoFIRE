//
//  TasksViewController.swift
//  ToDoFIRE
//
//  Created by Никита Коголенок on 4.03.21.
//

import UIKit
import Firebase

class TasksViewController: UIViewController {
    // MARK: - Variabel
    var user: AppUser!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Lifecycle
    /// viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = AppUser(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    /// viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: { [weak self] (snapshot) in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        })
    }
    /// viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    // MARK: Methods
    /// for delete cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["copleted": isCompleted])
    }
    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    // MARK: - Actions
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Tasks", message: "Add new tasks", preferredStyle: .alert)
        
        alertController.addTextField()
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first,
                  textField.text != ""
            else { return }
            // создаем задачу, где храниться задача на сервере,
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
        }
        let cancelAction = UIAlertAction(title: "Cansel", style: .default, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sighOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = .clear
        //cell.textLabel?.text = "This is cell number \(indexPath.row)"
        let task = tasks[indexPath.row]
        let taskTitle = task.title
        let isCompleted = task.completed
        cell.textLabel?.text = taskTitle
        cell.textLabel?.textColor = .white
        toggleCompletion(cell, isCompleted: isCompleted)
        
        
        return cell
    }
}
