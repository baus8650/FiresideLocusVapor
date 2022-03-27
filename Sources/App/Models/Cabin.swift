//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Vapor
import Fluent

final class Cabin: Model {
    static let schema = "cabins"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$cabin)
    var counselor: [Counselor]
    
    @Children(for: \.$cabin)
    var campers: [Camper]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
        
    }
}

extension Cabin: Content {}
