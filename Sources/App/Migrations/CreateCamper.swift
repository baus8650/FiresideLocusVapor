//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent

struct CreateCamper: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("campers")
            .id()
            .field("firstName", .string, .required)
            .field("lastName", .string, .required)
            .field("age", .int, .required)
            .field("instrument", .string, .required)
            .field("cabin", .uuid, .required, .references("cabins", "id"))
            .field("program", .string, .required)
            .field("ensemble", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("campers").delete()
    }
}
