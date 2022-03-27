import Fluent
import Vapor

func routes(_ app: Application) throws {

    let cabinsController = CabinController()
    try app.register(collection: cabinsController)
    
    let counselorController = CounselorController()
    try app.register(collection: counselorController)
    
    let groupsController = GroupsController()
    try app.register(collection: groupsController)
    
    let campersController = CamperController()
    try app.register(collection: campersController)
    
//    app.post("upload") { req -> EventLoopFuture<View> in
//            struct Input: Content {
//                var file: File
//            }
//            let input = try req.content.decode(Input.self)
//
//            guard input.file.data.readableBytes > 0 else {
//                throw Abort(.badRequest)
//            }
//
//            let formatter = DateFormatter()
//            formatter.dateFormat = "y-m-d-HH-MM-SS-"
//            let prefix = formatter.string(from: .init())
//            let fileName = prefix + input.file.filename
//            let path = app.directory.publicDirectory + fileName
//            let isImage = ["png", "jpeg", "jpg", "gif"].contains(input.file.extension?.lowercased())
//
//            return req.application.fileio.openFile(path: path,
//                                                   mode: .write,
//                                                   flags: .allowFileCreation(posixMode: 0x744),
//                                                   eventLoop: req.eventLoop)
//                .flatMap { handle in
//                    req.fileio.writeFile(buffer: input.file.data,
//                                                 eventLoop: req.eventLoop)
//                        .flatMapThrowing { _ in
//                            try handle.close()
//                        }
//                        .flatMap {
//                            req.view.render("result", [
//                                "fileUrl": String(fileName),
//                                "isImage": Bool(isImage),
//                            ])
//                        }
//                }
//        }
    
    try app.register(collection: WebsiteController())
    
}
