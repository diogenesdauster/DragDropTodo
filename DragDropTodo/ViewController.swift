//
//  ViewController.swift
//  DragDropTodo
//
//  Created by Diógenes Dauster on 8/20/19.
//  Copyright © 2019 Dauster. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    
    @IBOutlet weak var topTableView: UITableView!
    @IBOutlet weak var bottomTableView: UITableView!
    
    var todoList: TodoList
    
    required init?(coder: NSCoder) {
        todoList = TodoList()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        topTableView.dataSource = self
        bottomTableView.dataSource = self
        
        topTableView.dragDelegate = self
        topTableView.dropDelegate = self
        
        bottomTableView.dragDelegate = self
        bottomTableView.dropDelegate = self
        
        topTableView.dragInteractionEnabled = true
        bottomTableView.dragInteractionEnabled = true
        
        
    }
    
    func getDateSourcePriority(for tableView: UITableView) -> TodoList.Priority {
        
        if tableView == self.topTableView {
            return TodoList.Priority.high
        } else {
            return TodoList.Priority.low
        }
    }
        
}


extension ViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {        
        
        let priority = self.getDateSourcePriority(for: tableView)
        return todoList.dragItems(for: indexPath, on: priority)
    }
    
}

extension ViewController: UITableViewDropDelegate {
    
    // this method tells which kind of data the table view can receive
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return todoList.canHandle(session)
    }
    
    // this method makes the animation and the drop become more confortable for the user
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }

    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        let priority = getDateSourcePriority(for: tableView)
        var indexPaths: [IndexPath] = []
        
        for item in coordinator.items {
            if let sourceIndexPath = item.dragItem.localObject as? IndexPath {
                todoList.move(priority, at: sourceIndexPath.row, to: destinationIndexPath.row)
                indexPaths.append(sourceIndexPath)
            }
        }
        
        if tableView == topTableView {
            //bottomTableView.reloadData()
            bottomTableView.deleteRows(at: indexPaths, with: .automatic)
        } else {
            //topTableView.reloadData()
            topTableView.deleteRows(at: indexPaths, with: .automatic)
        }
        
        tableView.insertRows(at: [destinationIndexPath], with: .automatic)
        
    }
    
}


extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let priority = self.getDateSourcePriority(for: tableView)
        return todoList.todoList(priority: priority).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let priority = self.getDateSourcePriority(for: tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = todoList.todoList(priority: priority)[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var section: String?
        
        if tableView == topTableView {
            section = "High Priority Todo"
        } else {
            section = "Low Priority Todo"
        }
        
        return section
    }
    
}

