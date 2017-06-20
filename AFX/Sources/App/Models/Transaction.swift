//Transaction
//Stock
//Seller
//Buyer
//Expiry Time

import Vapor
import FluentProvider
import HTTP

final class Transaction: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    static let foreignIdKey = "transaction_id"
    
    var sellerId: Identifier
    
    var seller: Parent<Transaction, User> {
        return parent(id: sellerId)
    }
    
    var buyerId: Identifier
    
    var buyer: Parent<Transaction, User> {
        return parent(id: buyerId)
    }
    
    var stocks: Children<Transaction, Stock> {
        return children()
    }
    
    var cost: Int
    
    var expiry: Date?
    
    
    static let idKey = "id"
    static let buyerIdKey = "buyerId"
    static let sellerIdKey = "sellerId"
    static let costKey = "cost"
    static let expiryKey = "expiry"
    
    
    
    /// Creates a new Team
    init(sellerId: Identifier, buyerId: Identifier, cost: Int, expiry: Date? = nil) {
        self.sellerId = sellerId
        self.buyerId = buyerId
        self.cost = cost
        self.expiry = expiry
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        sellerId = try row.get(Transaction.sellerIdKey)
        buyerId = try row.get(Transaction.buyerIdKey)
        cost = try row.get(Transaction.costKey)
        expiry = try row.get(Transaction.expiryKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Transaction.sellerIdKey, sellerId)
        try row.set(Transaction.buyerIdKey, buyerId)
        try row.set(Transaction.costKey, cost)
        try row.set(Transaction.expiryKey, expiry)
        return row
    }
}

// MARK: Fluent Preparation

extension Transaction: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Transaction.buyerIdKey)
            builder.string(Transaction.sellerIdKey)
            builder.string(Transaction.costKey)
            builder.string(Transaction.expiryKey)
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
extension Transaction: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            sellerId: json.get(Transaction.sellerIdKey),
            buyerId: json.get(Transaction.buyerIdKey),
            cost: json.get(Transaction.costKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Transaction.idKey, id)
        try json.set(Transaction.buyerIdKey, buyerId)
        try json.set(Transaction.sellerIdKey, sellerId)
        try json.set(Transaction.costKey, cost)
        try json.set(Transaction.expiryKey, expiry)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Transaction: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Transaction: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Transaction>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Transaction.buyerIdKey, Identifier.self) { transaction, buyerId in
                transaction.buyerId = buyerId
            },
            UpdateableKey(Transaction.sellerIdKey, Identifier.self) { transaction, sellerId in
                transaction.sellerId = sellerId
            },
            UpdateableKey(Transaction.costKey, Int.self) { transaction, cost in
                transaction.cost = cost
            },
            UpdateableKey(Transaction.expiryKey, Date.self) { transaction, expiry in
                transaction.expiry = expiry
            }
            
            
        ]
    }
}
