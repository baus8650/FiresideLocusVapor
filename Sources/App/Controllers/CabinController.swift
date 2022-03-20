//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent
import Vapor

struct CabinController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let cabinRoutes = routes.grouped("api", "cabins")
        cabinRoutes.get(use: getAllHandler)
        cabinRoutes.post(use: createCabinHandler)
        cabinRoutes.get(":cabinID","counselor", use: getCounselorHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Cabin]> {
        Cabin.query(on: req.db).all()
    }
    
    func createCabinHandler(_ req: Request) throws
        -> EventLoopFuture<Cabin> {
            print("HERE'S THE STUFF \(req)")
      let data = try req.content.decode(CabinData.self)
            let cabin = try Cabin(name: data.name)
      return cabin.save(on: req.db).map { cabin }
    }
    
    func getCounselorHandler(_ req: Request) -> EventLoopFuture<[Counselor]> {
        Cabin.find(req.parameters.get("cabinID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { cabin in
                cabin.$counselor.get(on: req.db)
            }
    }
    
}

struct CabinData: Content {
    let name: String
}
