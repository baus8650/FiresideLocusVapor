import Fluent
import Vapor

func routes(_ app: Application) throws {

    let cabinsController = CabinController()
    try app.register(collection: cabinsController)
    
    let counselorController = CounselorController()
    try app.register(collection: counselorController)
//    app.post("api","cabins") { req -> EventLoopFuture<Cabin> in
//        let cabin = try req.content.decode(Cabin.self)
//        print("CABIN PRINTING \(cabin.name)")
//        return cabin.save(on: req.db).map {
//            cabin
//        }
//    }
    
    try app.register(collection: WebsiteController())
    
}
