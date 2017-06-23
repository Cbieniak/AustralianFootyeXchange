import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
        
        post("users") { req in
            // require that the request body be json
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            // initialize the name and email from
            // the request json
            let user = try User(json: json)
            print("user \(user)")
            // ensure no user with this email already exists
            guard try User.makeQuery().filter("email", user.email).first() == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists.")
            }
            
            // require a plaintext password is supplied
            guard let password = json["password"]?.string else {
                throw Abort(.badRequest)
            }
            
            // hash the password and set it on the user
            user.password = try self.hash.make(password.makeBytes()).makeString()
            
            // save and return the new user
            try user.save()
            return user
        }
        
        let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
        /// use this route group for protected routes
        let authed = self.grouped(tokenMiddleware)
        authed.get("me") { req in
            // return the authenticated user's name
            return try req.user().name
        }
        
    }
}
