//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent
import Vapor

final class Counselor: Model {
    static let schema = "counselors"

    @ID
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "isHead")
    var isHead: Bool
    
    @Parent(key: "cabin")
    var cabin: Cabin

    init() {}

    init(id: UUID? = nil, name: String, isHead: Bool = false, cabin: UUID) {
        self.id = id
        self.name = name
        self.isHead = isHead
        self.$cabin.id = cabin
    }
}

extension Counselor: Content {}
