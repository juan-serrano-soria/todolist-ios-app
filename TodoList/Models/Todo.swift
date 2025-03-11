//
//  Todo.swift
//  TodoList
//
//  Created by Serrano Soria, Juan on 06/03/2025.
//

import Foundation

struct Todo: Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
    }
}
