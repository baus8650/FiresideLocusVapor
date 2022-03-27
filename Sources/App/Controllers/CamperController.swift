//
//  File.swift
//  
//
//  Created by Tim Bausch on 3/19/22.
//

import Fluent
import Vapor
import Foundation

struct CamperController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let camperRoutes = routes.grouped("api", "campers")
        camperRoutes.get(use: getAllHandler)
        camperRoutes.get(":camperID", "cabin", use: getCabinHandler)
        camperRoutes.post(":camperID","groups",":groupID", use: addGroupsHandler)
        camperRoutes.get(":camperID","groups", use: getGroupsHandler)
        camperRoutes.delete(":camperID","groups",":groupID", use: removeGroupsHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Camper]> {
        Camper.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Camper> {
        let data = try req.content.decode(CreateCamperData.self)
        let camper = Camper(firstName: data.firstName, lastName: data.lastName, age: data.age, instrument: data.instrument, program: data.program, cabin: data.cabin, ensemble: data.ensemble)
        return camper.save(on: req.db).map { camper }
    }
    
    func getCabinHandler(_ req: Request) -> EventLoopFuture<Cabin> {
        Camper.find(req.parameters.get("camperID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { camper in
                camper.$cabin.get(on: req.db)
            }
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

struct CreateCamperData: Content {
    let firstName: String
    let lastName: String
    let age: Int
    let instrument: String
//    let tags: [String]
    let program: String
    let cabin: UUID
    let ensemble: String
}
