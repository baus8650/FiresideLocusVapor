import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "fireside_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "fireside_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)
    
    
        
    
    app.middleware.use(CORSMiddleware(configuration: .init(
        allowedOrigin: .originBased,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )))

    app.migrations.add(CreateCabin())
    app.migrations.add(GenerateCabins())
    app.migrations.add(CreateCounselor())
    app.migrations.add(CreateCamper())
    app.migrations.add(CreateGroup())
    app.migrations.add(CreateEvent())
    app.migrations.add(CreateCamperGroupPivot())
    app.logger.logLevel = .debug
    try app.autoMigrate().wait()
    
    app.views.use(.leaf)

    

    // register routes
    try routes(app)
}
