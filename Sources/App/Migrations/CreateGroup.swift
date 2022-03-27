//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/21/22.
//

import Fluent

struct CreateGroup: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("groups")
      .id()
      .field("name", .string, .required)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("groups").delete()
  }
}
