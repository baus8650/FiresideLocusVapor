//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/21/22.
//

import Fluent
import Vapor

final class Groups: Model, Content {
    static let schema = "groups"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$group)
    var events: [Events]
    
    @Siblings(through: CamperGroupPivot.self, from: \.$group, to: \.$camper)
    var campers: [Camper]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Groups {
    static func addGroup(_ name: String, to camper: Camper, on req: Request) -> EventLoopFuture<Void> {
        return Groups.query(on: req.db)
            .filter(\.$name == name)
            .first()
            .flatMap { foundGroup in
                if let existingGroup = foundGroup {
                    return camper.$groups
                        .attach(existingGroup, on: req.db)
                } else {
                    let group = Groups(name: name)
                    return group.save(on: req.db).flatMap {
                        camper.$groups
                            .attach(group, on: req.db)
                    }
                }
            }
    }
}
