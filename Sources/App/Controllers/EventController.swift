//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent
import Vapor
import Foundation

struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let eventRoutes = routes.grouped("api", "events")
        eventRoutes.get(use: getAllHandler)

        eventRoutes.post(":eventID","groups",":groupID", use: addGroupsHandler)
        eventRoutes.get(":eventID","groups", use: getGroupsHandler)
        eventRoutes.delete(":eventID","groups",":groupID", use: removeGroupsHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Events]> {
        Events.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Events> {
        let data = try req.content.decode(CreateEventData.self)
        let event = Events(name: data.name, location: data.location, startTime: data.startTime, duration: data.duration, day: data.day, week: data.week, group: data.group)
        return event.save(on: req.db).map { event }
    }
    
    func addGroupsHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        // 2
        let camperQuery =
          Camper.find(req.parameters.get("camperID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let groupQuery =
          Groups.find(req.parameters.get("groupID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        // 3
        return camperQuery.and(groupQuery)
          .flatMap { camper, group in
            camper
                  .$groups
              // 4
              .attach(group, on: req.db)
              .transform(to: .created)
          }
      }
    
    func getGroupsHandler(_ req: Request) -> EventLoopFuture<[Groups]> {
        Camper.find(req.parameters.get("camperID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { camper in
                camper.$groups.query(on: req.db).all()
            }
    }
    
    func removeGroupsHandler(_ req: Request)
      -> EventLoopFuture<HTTPStatus> {
      // 2
      let camperQuery =
        Camper.find(req.parameters.get("camperID"), on: req.db)
          .unwrap(or: Abort(.notFound))
      let groupQuery =
        Groups.find(req.parameters.get("groupID"), on: req.db)
          .unwrap(or: Abort(.notFound))
      // 3
      return camperQuery.and(groupQuery)
        .flatMap { camper, group in
          // 4
          camper
            .$groups
            .detach(group, on: req.db)
            .transform(to: .noContent)
        }
    }
    
}

struct CreateEventData: Content {
    let name: String
    let location: String
    let startTime: String
    let duration: Int
    let day: String
    let week: Int
    let group: UUID
}
