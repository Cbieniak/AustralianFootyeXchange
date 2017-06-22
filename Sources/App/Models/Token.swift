//
//  Token.swift
//  Bits
//
//  Created by ChristianBieniak on 20/6/17.
//

import Vapor
import FluentProvider

final class DefaultToken: Model {
    let storage = Storage()
    
    static let foreignIdKey = "defaultTokenId"
    
    let token: String
    let userId: Identifier
    
    static let tokenKey = "token"
    static let userIdKey = "userId"
    
    var user: Parent<DefaultToken, User> {
        return parent(id: userId)
    }
    
    
    init(token: String, userId: Identifier) {
        self.token = token
        self.userId = userId
    }
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        token = try row.get(DefaultToken.tokenKey)
        userId = try row.get(DefaultToken.userIdKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(DefaultToken.tokenKey, token)
        try row.set(DefaultToken.userIdKey, userId)
        return row
    }
}

extension DefaultToken: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(DefaultToken.tokenKey)
            builder.foreignId(for: User.self)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
