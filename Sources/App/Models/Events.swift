//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Vapor
import Fluent

final class Events: Model, Content {
    static let schema = "events"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String

    @Field(key: "location")
    var location: String
    
    @Field(key: "startTime")
    var startTime: String
    
    @Field(key: "duration")
    var duration: Int
    
    @Field(key: "day")
    var day: String
    
    @Field(key: "week")
    var week: Int
    
    @Parent(key: "group")
    var group: Groups
    
    init() {}
    
    init(id: UUID? = nil, name: String, location: String, startTime: String, duration: Int, day: String, week: Int, group: UUID) {
        self.id = id
        self.name = name
        self.location = location
        self.startTime = startTime
        self.duration = duration
        self.day = day
        self.week = week
        self.$group.id = group
    }
    
}
