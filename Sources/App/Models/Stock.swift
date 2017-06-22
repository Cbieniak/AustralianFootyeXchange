import Vapor
import FluentProvider
import HTTP

final class Stock: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    static let foreignIdKey = "stock_id"
    
    var ownerId: Identifier
    
    var owner: Parent<Stock, User> {
        return parent(id: ownerId)
    }
    
    var teamId: Identifier
    
    var team: Parent<Stock, Team> {
        return parent(id: teamId)
    }
    
    static let idKey = "id"
    static let ownerIdKey = "ownerId"
    static let teamIdKey = "teamId"
    
    /// Creates a new Team
    init(ownerId: Identifier, teamId: Identifier) {
        self.ownerId = ownerId
        self.teamId = teamId
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        ownerId = try row.get(Stock.ownerIdKey)
        teamId  = try row.get(Stock.teamIdKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Stock.ownerIdKey, ownerId)
        try row.set(Stock.teamIdKey, teamId)
        return row
    }
}

// MARK: Fluent Preparation

extension Stock: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Stock.ownerIdKey)
            builder.string(Stock.teamIdKey)
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
extension Stock: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            ownerId: json.get(Stock.ownerIdKey),
            teamId: json.get(Stock.teamIdKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Stock.idKey, id)
        try json.set(Stock.ownerIdKey, ownerId)
        try json.set(Stock.teamIdKey, teamId)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Stock: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Stock: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Stock>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Stock.ownerIdKey, Identifier.self) { stock, ownerId in
                stock.ownerId = ownerId
            },
            UpdateableKey(Stock.teamIdKey, Identifier.self) { stock, teamId in
                stock.teamId = teamId
            }
        ]
    }
}


