//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent
import Vapor

struct CounselorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let counselorRoutes = routes.grouped("api", "counselors")
        counselorRoutes.get(use: getAllHandler)
        counselorRoutes.post(use: createHandler)
        counselorRoutes.get(":counselorID", "cabin", use: getCabinHandler)
    }
    
    func getCabinHandler(_ req: Request) -> EventLoopFuture<Cabin> {
        Counselor.find(req.parameters.get("counselorID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { counselor in
                counselor.$cabin.get(on: req.db)
            }
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Counselor]> {
        Counselor.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Counselor> {
        let data = try req.content.decode(CreateCounselorData.self)
        let counselor = Counselor(name: data.name, isHead: data.isHead, cabin: data.cabin)
        return counselor.save(on: req.db).map { counselor }
    }
    
}

struct CreateCounselorData: Content {
    let name: String
    let isHead: Bool
    let cabin: UUID
}
