//
//  WebsiteController.swift
//  
//
//  Created by Tim Bausch on 3/18/22.
//

import Leaf
import Vapor

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use:indexHandler)
        routes.get("cabins", use: cabinHandler)
        routes.get("cabins", "create", use: createCabinHandler)
        routes.post("cabins", "create", use: createCabinPostHandler)
        routes.get("counselors", "create", use: createCounselorHandler)
        routes.post("counselors", "create", use: createCounselorPostHandler)
        routes.get("counselors", use: counselorHandler)
    }
    
    func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("home")
    }
    
    func cabinHandler(_ req: Request) -> EventLoopFuture<View> {
        Cabin.query(on: req.db)
            .with(\.$counselor)
            .all()
            .flatMap { cabin in
                let context = CabinContext(
                    cabins: cabin
                )
                return req.view.render("cabins", context)
            }
    }
    
    
    
    func createCabinHandler(_ req: Request) -> EventLoopFuture<View> {
        let context = CreateCabinContext()
        return req.view.render("createCabin", context)
    }
    
    func createCabinPostHandler(_ req: Request) throws
      -> EventLoopFuture<Response> {
      // 2
      let data = try req.content.decode(CreateCabinData.self)
          let cabin = Cabin(name: data.name)
      // 3
      return cabin.save(on: req.db).flatMapThrowing {
          // 4
          guard let id = cabin.id else {
            throw Abort(.internalServerError)
          }
          // 5
          return req.redirect(to: "/cabins/")
      }
    }
    
    func createCounselorHandler(_ req: Request) -> EventLoopFuture<View> {
        Cabin.query(on: req.db)
            .all()
            .flatMap { cabin in
                let context = CreateCounselorContext(
                    cabins: cabin
                )
                return req.view.render("createCounselor", context)
            }
//        let context = CreateCounselorContext()
//        return req.view.render("createCounselor", context)
    }
    
    func createCounselorPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateCounselorData.self)
        let counselor = Counselor(name: data.name, isHead: data.isHead, cabin: data.cabin)
        return counselor.save(on: req.db).flatMapThrowing {
            guard let id = counselor.id else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/")
        }
    }
    
    func counselorHandler(_ req: Request) -> EventLoopFuture<View> {
        Counselor.query(on: req.db)
            .all()
            .flatMap { counselor in
                let context = CounselorContext(
                    counselors: counselor
                )
                return req.view.render("counselors", context)
            }
    }
    
}

struct CabinContext: Codable {
    let title = "Cabins"
    let cabins: [Cabin]
}

struct CounselorContext: Codable {
    let title = "Counselors"
    let counselors: [Counselor]
}

struct CreateCabinData: Codable {
    let name: String
}

struct CreateCabinContext: Codable {
    let title = "Add a Cabin"
}

struct CreateCounselorContext: Codable {
    let title = "Add a Counselor"
    let cabins: [Cabin]
}

struct createCounselorData: Codable {
    let name: String
    let isHead: Bool
    let cabin: UUID
}

