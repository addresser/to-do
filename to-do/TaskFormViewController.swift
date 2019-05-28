//
//  ViewController.swift
//  to-do
//
//  Created by Геннадий Дмитриев on 18/05/2019.
//  Copyright © 2019 Геннадий Дмитриев. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON

class TaskFormViewController: UIViewController {
    var addTuskButton: UIButton!
    var abortButton: UIButton!
    var textView: UITextView!
    
    let taskViewModel: TaskViewModel
    
    init(viewModel: TaskViewModel) {
        taskViewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews () {
        textView = UITextView()
        textView.text = "Условие задачи..."
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.font = UIFont(name: "Courier", size: 20)
        textView.isScrollEnabled = true
        
        addTuskButton = UIButton()
        addTuskButton.setTitle("Добавить задачу", for: .normal)
        addTuskButton.backgroundColor = .gray
        addTuskButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        
        abortButton = UIButton()
        abortButton.setTitle("Отмена", for: .normal)
        abortButton.backgroundColor = .gray
        abortButton.addTarget(self, action: #selector(abort), for: .touchUpInside)
        
        
        let stack = UIStackView(arrangedSubviews: [textView, addTuskButton, abortButton])
        
        self.view.addSubview(stack)
        self.createConstraints(views: stack)
    }
    
    private func createConstraints (views: UIStackView) {
        views.axis = .vertical
        views.spacing = 8
        
        views.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.size.equalTo(250)
        }
    }
 
    @objc func addTask () {
        taskViewModel.addEvent.on(.next([
            "id": taskViewModel.incrementID(),
            "title": textView.text ?? "",
        ]))
        
        abort()
    }
    
    @objc func abort () {
        self.present(
            UINavigationController(rootViewController: TaskViewController(nibName: nil, bundle: nil)),
            animated: true, completion: nil
        )
    }
}

