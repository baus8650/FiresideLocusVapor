//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/21/22.
//

import Vapor

struct GroupsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groupsRoute = routes.grouped("api", "groups")
        
        groupsRoute.post(use: createHandler)
        groupsRoute.get(use: getAllHandler)
        groupsRoute.get(":groupID", use: getHandler)
        groupsRoute.get("campers", use: getAllCampersWithGroupsAndEvents)
//        groupsRoute.get(":groupID","campers", use: getCampersHandler)
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Groups> {
        let group = try req.content.decode(Groups.self)
        return group.save(on: req.db).map { group }
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Groups]> {
        Groups.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<Groups> {
        Groups.find(req.parameters.get("groupID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getCampersHandler(_ req: Request) -> EventLoopFuture<[Camper]> {
        Groups.find(req.parameters.get("groupID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { group in
                group.$campers.get(on: req.db)
            }
    }
    
    func getAllCampersWithGroupsAndEvents(_ req: Request) -> EventLoopFuture<[CamperWithGroups]> {
        Camper.query(on: req.db)
            .with(\.$groups) { groups in
                groups.with(\.$events)
            }.all().map { campers in
                campers.map { camper in
                    let camperGroups = camper.groups.map {
                        GroupsWithEvents(
                            id: $0.id,
                            name: $0.name,
                            event: $0.events
                        )
                    }
                    return CamperWithGroups(
                        id: camper.id,
                        name: camper.firstName,
                        groups: camperGroups
                    )
                }
            }
            
    }
}
struct GroupsWithEvents: Content {
    let id: UUID?
    let name: String
    let event: [Events]
}

struct CamperWithGroups: Content {
    let id: UUID?
    let name: String
    let groups: [GroupsWithEvents]
}
    

