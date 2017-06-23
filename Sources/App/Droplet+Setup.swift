@_exported import Vapor
import AuthProvider
import PostgreSQLDriver

extension Droplet {
    public func setup() throws {
        try setupRoutes()
    }
}
