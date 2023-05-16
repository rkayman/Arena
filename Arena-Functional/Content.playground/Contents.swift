// Playground generated with 🏟 Arena (https://github.com/rkayman/arena)
//      which was forked, with gratitude, from (https://github.com/finestructure/arena)
// ℹ️ If running the playground fails with an error "No such module"
//    go to Product -> Build to re-trigger building the SPM package.
// ℹ️ Please restart Xcode if autocomplete is not working.

import Foundation
import NonEmpty

public enum Validated<E, A> {
    case valid(A)
    case invalid(NonEmptyArray<E>)
    
    public var isValid: Bool {
        guard case .valid = self else { return false }
        return true
    }
    
    public var value: A? {
        guard case .valid(let a) = self else { return .none }
        return .some(a)
    }
    
    public var errors: NonEmptyArray<E>? {
        guard case .invalid(let e) = self else { return .none }
        return .some(e)
    }
}

extension Validated {
    func apply<B>(_ f: Validated<E, ((A) -> B)>) -> Validated<E, B> {
        switch (self, f) {
        case (.invalid(let e), _):
            return .invalid(e)
        case (_, .invalid(let e)):
            return .invalid(e)
        case (.valid(let a), .valid(let f)):
            return .valid(f(a))
        }
    }
    
    func bind<B>(_ f: (A) -> Validated<E,B>) -> Validated<E,B> {
        switch self {
        case .invalid(let e):
            return .invalid(e)
        case .valid(let a):
            return f(a)
        }
    }
    
    func map<B>(_ f: (A) -> B) -> Validated<E,B> {
        switch self {
        case .invalid(let e):
            return .invalid(e)
        case .valid(let a):
            return .valid(f(a))
        }
    }
    
    func zip<B>(_ b: Validated<E,B>) -> Validated<E, (A, B)> {
        switch (self, b) {
        case (.invalid(let e1), .invalid(let e2)):
            return .invalid(e1 + e2)
        case (.valid(let a), .valid(let b)):
            return .valid((a,b))
        case (.invalid(let e), _), (_, .invalid(let e)):
            return .invalid(e)
        }
    }
}

public func pure<A,E>(_ a: A) -> Validated<E,A> { .valid(a) }

public func compose<A,B,C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

public func apply<A,B,E>(_ a: Validated<E,A>, _ f: Validated<E,(A) -> B>) -> Validated<E,B> {
    a.apply(f)
}

public func bind<A,B,E>(_ a: Validated<E,A>, _ f: @escaping (A) -> Validated<E,B>) -> Validated<E,B> {
    a.bind(f)
}

public func kleisli<A,B,C,E>(_ f: @escaping (A) -> Validated<E,B>, _ g: @escaping (B) -> Validated<E,C>) -> (A) -> Validated<E,C> {
    return { a in a.bind(f).bind(g) }
}

public func map<A,B,E>(_ a: Validated<E,A>, _ f: @escaping (A) -> B) -> Validated<E,B> {
    a.map(f)
}

public func zip<A,B,E>(_ a: Validated<E,A>, _ b: Validated<E,B>) -> Validated<E,(A,B)> {
    a.zip(b)
}

// MARK:- Pipe operator
precedencegroup Pipe {
    associativity: left
}
infix operator |>: Pipe

public func |> <A,B>(_ value: A, _ f: @escaping (A) -> B) -> B {
    f(value)
}

// MARK:- Compose operator
precedencegroup Compose {
    associativity: left
    higherThan: Pipe
}
infix operator >>>: Compose

public func >>> <A,B,C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    compose(f, g)
}

// MARK:- Apply operator
precedencegroup Apply {
    associativity: left
}
infix operator <*>: Apply

public func <*> <A,B,E>(_ a: Validated<E,A>, _ f: Validated<E,(A) -> B>) -> Validated<E,B> {
    a.apply(f)
}

public func <*> <A,B,E>(_ f: Validated<E,(A) -> B>, _ a: Validated<E,A>) -> Validated<E,B> {
    a.apply(f)
}

// MARK:- Bind operator
precedencegroup Bind {
    associativity: left
    higherThan: Pipe, Kleisli
}
infix operator >>-: Bind

public func >>- <A,B,E>(_ a: Validated<E,A>, _ f: (A) -> Validated<E,B>) -> Validated<E,B> {
    a.bind(f)
}

public func >>- <A,B,E>(_ f: (A) -> Validated<E,B>, _ a: Validated<E,A>) -> Validated<E,B> {
    a.bind(f)
}

// MARK:- Map
precedencegroup Map {
    associativity: left
    higherThan: Pipe
}
infix operator <!>: Map

public func <!> <A,B,E>(_ a: Validated<E,A>, _ f: @escaping (A) -> B) -> Validated<E,B> {
    a.map(f)
}

public func <!> <A,B,E>(_ f: @escaping (A) -> B, _ a: Validated<E,A>) -> Validated<E,B> {
    a.map(f)
}

// MARK:- Zip
precedencegroup Zip {
    associativity: left
}
infix operator <%>: Zip

public func <%> <A,B,E>(_ a: Validated<E,A>, _ b: Validated<E,B>) -> Validated<E,(A,B)> {
    a.zip(b)
}


func trimString(with set: CharacterSet) -> (String) -> String {
    return { $0.trimmingCharacters(in: set) }
}

let trimWhitespaceAndNewlines = trimString(with: .whitespacesAndNewlines)

func foo<Field, Attribute>(_ attribute: KeyPath<Field, Attribute>,
                           using validate: @escaping (Attribute) -> Either<[String], String>)
-> (Field) -> Either<[String], Field> {
    return { field in
        debugPrint(attribute, "\(field[keyPath: attribute])", separator: "\n")
        return validate(field[keyPath: attribute])
            .map { _ in field }
    }
}

func hasLength(for property: String, exactly: Int) -> (any Collection) -> Either<[String], any Collection> {
    return {
        return exactly == $0.count
        ? .right($0)
        : .left(["[ERROR] \(property) has length (count) of \($0.count) BUT must be equal to \(exactly)"])
    }
}

func hasLength(for property: String, between range: some RangeExpression<Int>) -> (any Collection) -> Either<[String], any Collection> {
    return {
        return range ~= $0.count
        ? .right($0)
        : .left(["[ERROR] \(property) has length (count) of \($0.count) BUT must be between \(range)"])
    }
}


public struct Learner {
    let name: Name
    let birthday: Birthday?
    let schoolName: SchoolName?
    
    var age: Int? {
        get {
            guard let bday = birthday else { return nil }
            return Int(bday.rawValue.getInterval(toDate: Date.now, component: .month)) / 12
        }
    }
    
    typealias Name = Tagged<(Learner, name: ()), String>
    typealias SchoolName = Tagged<(Learner, schoolName: ()), String>
    typealias Birthday = Tagged<(Learner, birthday: ()), Date>
    typealias Age = Tagged<(Learner, age: ()), Int64>
}

extension Learner {
    static private let make = {
        (name: Name) in {
            (birthday: Birthday?) in {
                (schoolName: SchoolName?) in Learner.init
            }
        }
    }
}

let bday = Date("04/01/2017", region: .current)
let jl = Learner(name: "James Li",
                birthday: bday.map { Learner.Birthday($0) },
                schoolName: "Blossom Hill Elementary")
jl.age

let kr = Learner(name: "Krista Ramamurthy", birthday: nil, schoolName: nil)

extension Learner {
    var nameHasLength: (String) -> Either<[String], any Collection> {
        hasLength(for: "name", between: (3...100))
    }
}

let f = hasLength(for: "item", between: (3...100))
let x = ["yes", "no", "maybe"]
let y = "no"
print(f(x))
print(f(y))

let rule1 = foo(\String.count) {
    if (3...100) ~= $0 {
        let field = \String.count
        return .right(field.debugDescription)
    } else {
        return .left(["String"])
    }
}

zip([1,2,3], ["A","B","C"]).forEach { print($0,$1) }
