//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent
import Vapor

struct GenerateCabins: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        var cabins = [Cabin]()
        for i in 1...12 {
            let cabin = Cabin(name: "Cabin \(i)")
            cabins.append(cabin)
        }
        return cabins.create(on: database)
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("cabins").delete()
    }
}
