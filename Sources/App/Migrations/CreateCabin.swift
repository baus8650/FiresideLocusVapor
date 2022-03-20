//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent

struct CreateCabin: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("cabins")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("cabins").delete()
    }
}
