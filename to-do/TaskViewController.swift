//
//  TaskViewController.swift
//  to-do
//
//  Created by Геннадий Дмитриев on 18/05/2019.
//  Copyright © 2019 Геннадий Дмитриев. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import RxCocoa
import RxSwift

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView: UITableView
    let alertController: UIAlertController
    let taskViewModel: TaskViewModel
    var notificationToken: NotificationToken?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        tableView = UITableView()
        alertController = UIAlertController(title: "Новая задача", message: "", preferredStyle: .alert)
        taskViewModel = TaskViewModel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Загрузить Задачи", style: .plain, target: self, action: #selector(getTaskList))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = self.view.frame
        
        subscribeOnUpdate()
        createAlertController()
    }
    
    private func subscribeOnUpdate() {
        notificationToken = taskViewModel.taskObserve { changes in
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    private func createAlertController () {
        alertController.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { alert -> Void in
            let textField = self.alertController.textFields![0] as UITextField
            self.taskViewModel.addEvent.on(.next(textField.text ?? ""))

        }))
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        alertController.addTextField(configurationHandler: { (textField : UITextField!) -> Void in textField.placeholder = "Условие задачи" })
    }
    
    @objc func getTaskList() {
        AF.request(Constants.TASK_LIST_URL, method: .get)
            .validate()
            .responseJSON { (response) -> Void in
                switch response.result {
                case .success:
                    self.taskViewModel.getEvent.on(.next(response.value as! NSArray))
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    @objc func addTask() {
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskViewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        let taskData = taskViewModel.tasks[indexPath.row]
        cell.textLabel?.text = taskData.title
        cell.accessoryType = taskData.completed ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.taskViewModel.changeEvent.on(.next(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.taskViewModel.deleteEvent.on(.next(indexPath.row))
    }
}
