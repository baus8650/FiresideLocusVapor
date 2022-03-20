//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent


struct CreateCounselor: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("counselors")
            .id()
            .field("name", .string, .required)
            .field("isHead", .bool, .required)
            .field("cabin", .uuid, .required,. references("cabins", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("counselors").delete()
    }
}
