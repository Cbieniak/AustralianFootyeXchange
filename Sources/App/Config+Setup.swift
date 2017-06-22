import FluentProvider
import AuthProvider
import PostgreSQLProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
        preparations.append(Team.self)
        preparations.append(User.self)
        preparations.append(Stock.self)
        preparations.append(Transaction.self)
        preparations.append(DefaultToken.self)
    }
}

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}
