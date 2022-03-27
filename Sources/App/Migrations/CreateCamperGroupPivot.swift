//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/21/22.
//

import Fluent

struct CreateCamperGroupPivot: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        // 3
        database.schema("camper-group-pivot")
        // 4
            .id()
        // 5
            .field("camperID", .uuid, .required,
                   .references("campers", "id", onDelete: .cascade))
            .field("groupID", .uuid, .required,
                   .references("groups", "id", onDelete: .cascade))
        // 6
            .create()
    }
    
    // 7
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("camper-group-pivot").delete()
    }
}
