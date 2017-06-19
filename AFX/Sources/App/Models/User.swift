import Vapor
import FluentProvider
import HTTP

final class User: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    static let foreignIdKey = "user_id"
    
    var name: String
    
    static let idKey = "id"
    static let nameKey = "name"
    
    
    var stockPortfolio: Children<User, Stock> {
        return children()
    }
    //TODO MANY STOCKS
    var stocks: Siblings<User, Team, Stock> {
        return siblings()
    }
    
    /// Creates a new Team
    init(name: String) {
        self.name = name
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        name = try row.get(User.nameKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        return row
    }
}

// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.nameKey)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(User.nameKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.nameKey, name)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension User: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(User.nameKey, String.self) { user, name in
                user.name = name
            }
        ]
    }
}



