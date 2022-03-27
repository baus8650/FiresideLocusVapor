//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//


import Fluent
import Vapor

final class Camper: Model, Content {
    static let schema = "campers"
    
    @ID
    var id: UUID?
    
    @Field(key: "firstName")
    var firstName: String
    
    @Field(key: "lastName")
    var lastName: String
    
    @Field(key: "age")
    var age: Int
    
    @Field(key: "instrument")
    var instrument: String
    
    //    @Field(key: "tags")
    //    var tags: [String]?
    
    @Field(key: "program")
    var program: String
    
    @Parent(key: "cabin")
    var cabin: Cabin
    
    @Field(key: "ensemble")
    var ensemble: String
    
    //    @Children(for: \.$camper)
    //    var events: [Event]?
    
    @Siblings(through: CamperGroupPivot.self, from: \.$camper, to: \.$group)
    var groups: [Groups]
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String, age: Int, instrument: String, tags: [String]? = [], program: String, cabin: UUID, ensemble: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.instrument = instrument
        self.program = program
        self.$cabin.id = cabin
        self.ensemble = ensemble
        //        self.events = events
    }
}

extension Camper {
    static func addCamper(firstName: String, lastName: String, age: Int, instrument: String, program: String, cabin: Cabin.IDValue, ensemble: String, on req: Request) -> EventLoopFuture<Void> {
        return Camper.query(on: req.db)
            .filter(\.$lastName == lastName)
            .first()
            .flatMap { foundCamper in
                let camper = Camper(firstName: firstName, lastName: lastName, age: Int(age), instrument: instrument, program: program, cabin: cabin, ensemble: ensemble)
                return camper.save(on: req.db)
                
            }
    }
}
