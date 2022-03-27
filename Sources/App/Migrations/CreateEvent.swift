//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent

struct CreateEvent: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("events")
            .id()
            .field("name", .string, .required)
            .field("location", .string, .required)
            .field("startTime", .string, .required)
            .field("duration", .int, .required)
            .field("day", .string, .required)
            .field("week", .int, .required)
            .field("group", .uuid, .required, .references("groups", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("events").delete()
    }
}
