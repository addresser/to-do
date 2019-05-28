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
import RxSwift
import SwiftyJSON

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView: UITableView
    let taskViewModel: TaskViewModel
    var notificationToken: NotificationToken?

    let cellIndex: String = "Cell"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        tableView = UITableView()
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
        
        tableView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        
        subscribeOnUpdate()
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
    
    @objc func addTask() {
        self.present(TaskFormViewController(viewModel: taskViewModel), animated: true, completion: nil)
    }

    @objc func getTaskList() {
        AF.request(Constants.TASK_LIST_URL, method: .get)
            .validate()
            .responseJSON { (response) -> Void in
                switch response.result {
                case .success(let value):
                    for (_, data) in JSON(value) {
                        var taskObj = data.dictionaryObject!
                        taskObj["completed"] = Bool(exactly: taskObj["completed"] as! NSNumber)!
                        taskObj["id"] = self.taskViewModel.incrementID()
                        
                        self.taskViewModel.addEvent.on(.next(taskObj))
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskViewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndex) ?? UITableViewCell(style: .default, reuseIdentifier: cellIndex)
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
