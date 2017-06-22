@_exported import Vapor
import AuthProvider
import PostgreSQLDriver

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
        /// use this route group for protected routes
        let authed = self.grouped(tokenMiddleware)
        authed.get("me") { req in
            // return the authenticated user's name
            return try req.user().name
        }
    }
}
