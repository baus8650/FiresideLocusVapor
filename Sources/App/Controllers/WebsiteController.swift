//
//  WebsiteController.swift
//  
//
//  Created by Tim Bausch on 3/18/22.
//

import Leaf
import Vapor
import CSV
import SwiftCSV
import Foundation

var cabinList = [String: UUID]()

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use:indexHandler)
        routes.get("cabins", use: cabinHandler)
        routes.get("cabins", "create", use: createCabinHandler)
        routes.post("cabins", "create", use: createCabinPostHandler)
        routes.get("counselors", "create", use: createCounselorHandler)
        routes.post("counselors", "create", use: createCounselorPostHandler)
        routes.get("counselors", use: counselorHandler)
        routes.get("campers", "create", use: createCamperHandler)
        routes.post("campers", "create", use: createCamperPostHandler)
        routes.get("campers", use: camperHandler)
        routes.get("groups", use: allGroupsHandler)
        routes.get("groups", ":groupID", use: groupHandler)
        routes.get("events", use: allEventsHandler)
        routes.post("events","create", use: createEventPostHandler)
        routes.get("events","create", use: createEventHandler)
        routes.get("upload", use: uploadHandler)
        routes.get("uploaded-campers", use: uploadCamperHandler)
        routes.post("uploaded-campers", use: uploadCamperCSV)
//        routes.post("upload") { req -> EventLoopFuture<String> in
//            struct Input: Content {
//                var file: File
//            }
//            let input = try req.content.decode(Input.self)
//
//            let path = routes.directory.publicDirectory + input.file.filename
//
//            return req.application.fileio.openFile(path: path,
//                                                   mode: .write,
//                                                   flags: .allowFileCreation(posixMode: 0x744),
//                                                   eventLoop: req.eventLoop)
//                .flatMap { handle in
//                    req.application.fileio.write(fileHandle: handle,
//                                                 buffer: input.file.data,
//                                                 eventLoop: req.eventLoop)
//                        .flatMapThrowing { _ in
//                            try handle.close()
//                            return input.file.filename
//                        }
//                }
//        }
    }
    
    func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("home")
    }
    
    func uploadHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("upload")
    }
    
    func cabinHandler(_ req: Request) -> EventLoopFuture<View> {
        Cabin.query(on: req.db)
            .with(\.$counselor)
            .with(\.$campers)
            .all()
            .flatMap { cabin in
                let context = CabinContext(
                    cabins: cabin
                )
                for i in cabin {
                    cabinList[i.name] = i.id
                }
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
    
    // MARK: - Camper methods
    
    func createCamperHandler(_ req: Request) -> EventLoopFuture<View> {
        Cabin.query(on: req.db)
            .all()
            .flatMap { cabin in
                let context = CreateCamperContext(
                    cabins: cabin
                )
                return req.view.render("createCamper", context)
            }
    }
    
    func uploadCamperHandler(_ req: Request) -> EventLoopFuture<View> {
        Cabin.query(on: req.db)
            .all()
            .flatMap { cabin in
                let context = CreateCamperContext(
                    cabins: cabin
                )
                for i in cabin {
                    cabinList[i.name] = i.id
                }
                return req.view.render("eventUpload", context)
            }
    }
    
    func createEventHandler(_ req: Request) -> EventLoopFuture<View> {
        Groups.query(on: req.db)
            .all()
            .flatMap { group in
                let context = CreateEventContext(groups: group)
            
                return req.view.render("createEvent", context)
            }
    }
    
//    func createCamperPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
//        let data = try req.content.decode(CreateCamperData.self)
//        let camper = Camper(firstName: data.firstName, lastName: data.lastName, age: data.age, instrument: data.instrument, program: data.program, cabin: data.cabin, ensemble: data.ensemble)
//        return camper.save(on: req.db).flatMapThrowing {
//            guard let id = camper.id else {
//                throw Abort(.internalServerError)
//            }
//            return req.redirect(to: "/")
//        }
//    }
    
    func createCamperPostHandler(_ req: Request) throws
    -> EventLoopFuture<Response> {
        // 2
        let data = try req.content.decode(CreateCamperFormData.self)
        let camper = Camper(firstName: data.firstName, lastName: data.lastName, age: data.age, instrument: data.instrument, program: data.program, cabin: data.cabin, ensemble: data.ensemble)
        // 3
        
        return camper.save(on: req.db).flatMap {
            guard let id = camper.id else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            
            var groupSaves: [EventLoopFuture<Void>] = []
            
            for group in data.groups ?? [] {
                groupSaves.append(Groups.addGroup(group, to: camper, on: req))
            }
            let redirect = req.redirect(to: "/campers/\(id)")
            return groupSaves.flatten(on: req.eventLoop).transform(to: redirect)
        }
    }
    
    func createEventPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateEventFormData.self)
        print("HERE'S THE DATA: \(data)")
        let event = Events(name: data.name, location: data.location, startTime: data.day, duration: data.duration, day: data.day, week: data.week, group: data.group)
        
        return event.save(on: req.db).flatMapThrowing {
            guard let id = event.id else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/events/")
        }
    }
    
    func camperHandler(_ req: Request) -> EventLoopFuture<View> {
        Camper.query(on: req.db)
            .with(\.$groups) { groups in
                groups.with(\.$events)
            }
            .all()
            .flatMap { camper in
                let context = CamperContext(
                    campers: camper
                )
                return req.view.render("campers", context)
            }
    }
    
//    func camperHandler(_ req: Request) -> EventLoopFuture<View> {
//        Camper.query(on: req.db).with(\.$groups).all().flatMap { camper in
//            let groupsFuture = camper.$groups.query(on: req.db).all()
//            return groupsFuture.flatMap { group in
//                let context = CamperContext(campers: camper, groups: group)
//                return req.view.render("campers", context)
//            }
//
//        }
//    }
    
    func allGroupsHandler(_ req: Request) -> EventLoopFuture<View> {
        Groups.query(on: req.db).all().flatMap {
            groups in
            let context = AllGroupsContext(groups: groups)
            return req.view.render("allGroups", context)
        }
    }
    
    func allEventsHandler(_ req: Request) -> EventLoopFuture<View> {
        Events.query(on: req.db).all().flatMap { events in
            let context = AllEventsContext(events: events)
            return req.view.render("events", context)
        }
    }
    
    func groupHandler(_ req: Request) -> EventLoopFuture<View> {
        Groups.find(req.parameters.get("groupID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { group in
                group.$campers.get(on: req.db).flatMap {
                    campers in
                    let context = GroupContext(title: group.name, group: group, campers: campers)
                    return req.view.render("group", context)
                }
            }
    }
    

    

    func uploadCamperCSV(_ req: Request) async throws -> Response {
        let data = try req.content.decode(UploadCamperCSVData.self)
        let decoder = CSVDecoder().sync
        let csvFile = try decoder.decode([String: String].self, from: data.file)
        for i in csvFile {
            let updated = camperUploadCleanup(for: i)
            print("HERE'S UPDATED: ",updated)
            let cabin = cabinList[updated["cabin"]!]!
            let splitGroups = updated["groups"]!.components(separatedBy: ",")
            if updated["id"]! == "" {
                let camper = Camper(firstName: updated["firstName"] ?? "error", lastName: updated["lastName"] ?? "error", age: Int(updated["age"] ?? "0")!, instrument: updated["instrument"] ?? "error", program: updated["program"] ?? "error", cabin: cabin, ensemble: updated["ensemble"] ?? "error")

                try await camper.create(on: req.db)
                var groupSaves: [EventLoopFuture<Void>] = []

                for group in splitGroups ?? [] {
                    groupSaves.append(Groups.addGroup(group, to: camper, on: req))
                }
            } else {
                guard let camper = try await Camper.find(UUID(uuidString: updated["id"]!), on: req.db) else {
                    throw Abort(.notFound)
                }
                camper.firstName = updated["firstName"] ?? "error"
                camper.lastName = updated["lastName"] ?? "error"
                camper.age = Int(updated["age"] ?? "0")!
                camper.instrument = updated["instrument"] ?? "error"
                camper.program = updated["program"] ?? "error"
                camper.$cabin.id = cabin
                camper.ensemble = updated["ensemble"] ?? "error"
                camper.$groups.detachAll(on: req.db)

                try await camper.update(on: req.db)
                var groupSaves: [EventLoopFuture<Void>] = []

                for group in splitGroups ?? [] {
                    groupSaves.append(Groups.addGroup(group, to: camper, on: req))
                }
            }
        }
        return req.redirect(to: "/campers/")
        
    }

    
    func camperUploadCleanup(for data: [String: String]) -> [String: String] {
        var updatedData: [String : String] = [:]
        var weeks = ""
        let program = data["program"]!
        if program.contains("Session A") {
            weeks = "Week 1,Week 2"
        } else if program.contains("Session B") {
            weeks = "Week 3,Week 4"
        } else if program.contains("Junior Session - ") {
            weeks = "Week 1,Week 2,Week 3,Week 4"
        } else if program.contains("6 Week Session") {
            weeks = "Week 3,Week 4,Week 5,Week 6,Week 7,Week 8"
        } else if program.contains("3 Week Session") {
            weeks = "Week 2,Week 3,Week 4"
        } else if program.contains("Senior Session") {
            weeks = "Week 5,Week 6,Week 7,Week 8"
        } else {
            weeks = "Week 1,Week 2,Week 3,Week 4,Week 5,Week 6,Week 7,Week 8"
        }
        
        if data["instrument"] == "Piano" {
            var groups = "All,Piano,Piano Class,\(data["firstName"]! + " " + data["lastName"]! + " "  + "Lesson")"
            groups += ",\(weeks)"
            updatedData["groups"] = groups
        } else {
            var family = ""
            var generalFamily = ""
            if data["instrument"]! == "Violin" || data["instrument"]! == "Viola" || data["instrument"]! == "Cello" || data["instrument"]! == "Bass" {
                family = "String"
            } else if data["instrument"]! == "Percussion" {
                family = "Percussion"
            } else if data["instrument"]! == "Flute" || data["instrument"]! == "Clarinet" || data["instrument"]! == "Oboe" || data["instrument"]! == "Bassoon" {
                family = "Woodwind"
            } else if data["instrument"]! == "French Horn" || data["instrument"]! == "Trumpet" || data["instrument"]! == "Tuba" || data["instrument"]! == "Trombone" {
                family = "Brass"
            }
            
            if data["instrument"]! == "Flute" || data["instrument"]! == "Clarinet" || data["instrument"]! == "Oboe" || data["instrument"]! == "Bassoon" || data["instrument"]! == "French Horn" || data["instrument"]! == "Trumpet" || data["instrument"]! == "Tuba" || data["instrument"]! == "Trombone" {
                generalFamily = "Winds"
            }
            
            if generalFamily == "" {
                var groups = "All,\(data["instrument"]!),Orchestra,\(data["firstName"]! + " " + data["lastName"]! + " "  + "Lesson"),\(family)"
                groups += ",\(weeks)"
                updatedData["groups"] = groups
            } else {
                var groups = "All,\(data["instrument"]!),Orchestra,\(data["firstName"]! + " " + data["lastName"]! + " "  + "Lesson"),\(family),\(generalFamily)"
                groups += ",\(weeks)"
                updatedData["groups"] = groups
            }
        }
        updatedData["firstName"] = data["firstName"]!
        updatedData["lastName"] = data["lastName"]!
        updatedData["cabin"] = data["cabin"]!
        updatedData["instrument"] = data["instrument"]!
        updatedData["program"] = data["program"]!
        updatedData["age"] = data["age"]!
        updatedData["ensemble"] = data["ensemble"]!
        updatedData["id"] = data["id"] ?? ""
        return updatedData
    }
                                           
}

struct UploadCamperCSVData: Content {
    let file: Data
}

struct CabinContext: Codable {
    let title = "Cabins"
    let cabins: [Cabin]
}

struct CounselorContext: Codable {
    let title = "Counselors"
    let counselors: [Counselor]
}

struct CamperContext: Codable {
    let title = "Campers"
    let campers: [Camper]
}

struct CreateCabinData: Codable {
    let name: String
}

struct CreateCabinContext: Codable {
    let title = "Add a Cabin"
}

struct CreateEventContext: Codable {
    let title = "Add an Event"
    let groups: [Groups]
}

struct CreateCounselorContext: Codable {
    let title = "Add a Counselor"
    let cabins: [Cabin]
}

struct AllGroupsContext: Codable {
    let title = "All Groups"
    let groups: [Groups]
}

struct AllEventsContext: Codable {
    let title = "All Events"
    let events: [Events]
}

//struct CreateCounselorData: Codable {
//    let name: String
//    let isHead: Bool
//    let cabin: UUID
//}

struct CreateCamperFormData: Content {
    let firstName: String
    let lastName: String
    let age: Int
    let instrument: String
    let groups: [String]?
    let program: String
    let cabin: UUID
    let ensemble: String
}

struct UploadCamperPostFormData: Content {
//    let id: UUID?
    let firstName: [String]
    let lastName: [String]
    let age: [Int]
    let instrument: [String]
    let program: [String]
    let cabin: [Cabin.IDValue]
    let ensemble: [String]
    let groups: [[String]]?
}

struct CreateEventFormData: Content {
    let name: String
    let location: String
    let startTime: String
    let duration: Int
    let day: String
    let week: Int
    let group: UUID
}

struct CreateCamperContext: Codable {
    let title = "Add a Camper"
    let cabins: [Cabin]
}

struct GroupContext: Codable {
    let title: String
    let group: Groups
    let campers: [Camper]
}

struct UploadCamperFormData: Content {
    let upload: [UploadCamperPostFormData]
}


