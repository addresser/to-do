//
//  TaskViewModel.swift
//  to-do
//
//  Created by Геннадий Дмитриев on 19/05/2019.
//  Copyright © 2019 Геннадий Дмитриев. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

struct TaskViewModel {
    let realm: Realm
    let tasks: Results<Task>
    
    var getEvent: PublishSubject<NSArray> = PublishSubject()
    var addEvent: PublishSubject<String> = PublishSubject()
    var changeEvent: PublishSubject<Int> = PublishSubject()
    var deleteEvent: PublishSubject<Int> = PublishSubject()
    
    var taskObserve: (@escaping (RealmCollectionChange<Results<Task>>) -> Void) -> NotificationToken{
        return tasks.observe
    }
    
    init() {
        realm = try! Realm()
        tasks = realm.objects(Task.self).sorted(byKeyPath: "title", ascending: false)

        _ = getEvent.subscribe(handler(clojure: getTasks))
        _ = addEvent.subscribe(handler(clojure: addTask))
        _ = changeEvent.subscribe(handler(clojure: changeTask))
        _ = deleteEvent.subscribe(handler(clojure: deleteTask))
    }
    
    private func getTasks (value: NSArray)  -> Void {
        for task in value {
            try! self.realm.write {
                self.realm.add(Task(value: task))
            }
        }
    }
    
    private func addTask (value: String)  -> Void {
        let task = Task(value: ["title": value])
        
        try! self.realm.write {
            self.realm.add(task)
        }
    }
    
    private func changeTask (value: Int)  -> Void {
        let task = self.tasks[value]
        
        try! self.realm.write {
            task.completed = !task.completed
        }
    }
    
    private func deleteTask (value: Int)  -> Void {
        let task = self.tasks[value]
        
        try! self.realm.write {
            self.realm.delete(task)
        }
    }
    
    private func handler<T> (clojure: @escaping (_ value: T) -> Void) -> (_ on: Event<T>) -> Void {
        return { (event: Event<T>) in
            switch event {
            case .error(let error):
                print(error)
            case .next(let value):
                clojure(value)
            case .completed:
                print("completed!")
            }
        }
    }
}
