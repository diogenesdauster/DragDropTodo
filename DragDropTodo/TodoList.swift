//
//  TodoList.swift
//  DragDropTodo
//
//  Created by Diógenes Dauster on 8/20/19.
//  Copyright © 2019 Dauster. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

struct TodoList {
    
    enum Priority: CaseIterable {
        case high,low
    }
    
    private var highPriority:[String]
    private var lowPriority:[String]
    
    init() {
        
        let row0 = "Save Money"
        let row1 = "Study iOS"
        let row2 = "Study React"
        let row3 = "Work Hard"
        let row4 = "Earn Money"
        let row5 = "Buy a Car"
        let row6 = "Buy a Clothes"
        let row7 = "Travel from Peru"
        let row8 = "Find a Girlfriend"
        let row9 = "Help my Family"
        
        highPriority = [row0,row1,row2,row3,row4]
        lowPriority = [row5,row6,row7,row8,row9]
        
    }
    
    func todoList(priority: Priority) -> [String] {
        switch priority {
        case .high:
            return highPriority
        case .low:
            return lowPriority
        }
    }
    
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func dragItems(for indexPath: IndexPath,on priority: Priority) -> [UIDragItem] {
        var todo: String
        
        if priority == .high {
            todo = highPriority[indexPath.row]
        } else {
            todo = lowPriority[indexPath.row]
        }

        let data = todo.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = indexPath
        return [dragItem]

    }
    
    mutating func moveItem(_ priority: Priority,at sourceIndex: Int, to destinationIndex: Int) {
        
        switch priority {
        case .high:
            let todo = highPriority.remove(at: sourceIndex)
            highPriority.insert(todo, at: destinationIndex)
        case .low:
            let todo = lowPriority.remove(at: sourceIndex)
            lowPriority.insert(todo, at: destinationIndex)
            
        }
        
    }
    
    mutating func move(_ priority: Priority,at sourceIndex: Int, to destinationIndex: Int) {
        
        switch priority {
        case .high:
            let todo = lowPriority.remove(at: sourceIndex)
            highPriority.insert(todo, at: destinationIndex)
        case .low:
            let todo = highPriority.remove(at: sourceIndex)
            lowPriority.insert(todo, at: destinationIndex)
            
        }
        
    }
    
}
