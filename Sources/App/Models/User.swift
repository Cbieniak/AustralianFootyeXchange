import Vapor
import FluentProvider
import HTTP
import AuthProvider

final class User: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    static let foreignIdKey = "userId"
    
    var name: String
    
    /// The user's email
    var email: String
    
    /// The user's _hashed_ password
    var password: String?
    
    var token: String?
    
    static let idKey = "id"
    static let nameKey = "name"
    static let emailKey = "email"
    static let passwordKey = "password"
    static let tokenKey = "token"
    
    var stockPortfolio: Children<User, Stock> {
        return children()
    }
    
    var stocks: Siblings<User, Team, Stock> {
        return siblings()
    }
    
    
    
    func didCreate() {
        let defaultToken = DefaultToken(token: UUID().uuidString, userId: self.id!)
        self.token = defaultToken.token
        try? defaultToken.save()
    }
    
    /// Creates a new Team
    init(name: String, email: String, password: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        name = try row.get(User.nameKey)
        email = try row.get(User.emailKey)
        password = try row.get(User.passwordKey)
        token = try row.get(User.tokenKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        try row.set(User.emailKey, email)
        try row.set(User.passwordKey, password)
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
            builder.string(User.emailKey)
            builder.string(User.passwordKey)
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
            name: json.get(User.nameKey),
            email: json.get(User.emailKey),
            password: json.get(User.passwordKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.nameKey, name)
        try json.set(User.emailKey, email)
        try json.set(User.passwordKey, password)
        try json.set(User.tokenKey, token)
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

// MARK: Password
// This allows the User to be authenticated
// with a password. We will use this to initially
// login the user so that we can generate a token.
extension User: PasswordAuthenticatable {
    var hashedPassword: String? {
        return password
    }
    
    public static var passwordVerifier: PasswordVerifier? {
        get { return _userPasswordVerifier }
        set { _userPasswordVerifier = newValue }
    }
}

// store private variable since storage in extensions
// is not yet allowed in Swift
private var _userPasswordVerifier: PasswordVerifier? = nil

extension User: TokenAuthenticatable {
    // the token model that should be queried
    // to authenticate this user
    public typealias TokenType = DefaultToken
}



