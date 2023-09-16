
public struct FunctionType: Equatable {
    public private(set) var arguments: [Argument]
    public var returnValue: ReturnValue?

    public init(
        arguments: [Argument] = [],
        returnValue: ReturnValue? = nil
    ) {
        self.arguments = arguments
        self.returnValue = returnValue
    }

    public mutating func append(argument: Argument) {
        if let index = argument.index {
            guard index == arguments.count else {
                fatalError("invalid index for argument")
            }
        }
        arguments.append(argument)
    }
}

public struct ArrayType: Equatable {
    public let size: Int
    public let type: Type

    public init(
        size: Int,
        type: Type
    ) {
        self.size = size
        self.type = type
    }
}

public struct StructType: Equatable {
    public let name: String
    public let fields: [Field]

    public init(
        name: String,
        fields: [Field] = []
    ) {
        self.name = name
        self.fields = fields
    }
}

public struct UnionType: Equatable {
    public let name: String
    public let fields: [Field]

    public init(
        name: String,
        fields: [Field] = []
    ) {
        self.name = name
        self.fields = fields
    }
}

// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
public indirect enum Type: Equatable {

    public struct EncodingError<String: StringProtocol>: Error {
        public let encoded: String
        public var localizedDescription: String {
            "Invalid type encoding: \(encoded)"
        }
    }

    // Signed
    case Char
    case Int
    case Short
    case Long
    case LongLong

    // Unsigned
    case UnsignedChar
    case UnsignedInt
    case UnsignedShort
    case UnsignedLong
    case UnsignedLongLong

    // Floating point
    case Float
    case Double

    // Other
    case Bool
    case Void
    case ID
    case Class
    case Selector
    case Array(ArrayType)
    case Struct(StructType)
    case Union(UnionType)
    case Bitfield(size: Swift.Int)
    case Pointer(Type)
    case Unknown
    case Const(Type)

    // Encoded as unknown (?)
    case FunctionType(FunctionType)

    private static func decodeNameAndFields(
        encoded: inout Substring,
        expectedEnd: Character
    ) throws -> (
        name: String,
        fields: [Field]
    ) {
        encoded.removeFirst()

        var fields: [Field] = []

        let separator: Character = "="
        let quote: Character = "\""

        // Name
        let name = encoded.prefix { $0 != separator && $0 != expectedEnd }
        encoded.removeFirst(name.count)

        // Separator
        if let next = encoded.first, next == separator {
            encoded.removeFirst()

            // Fields
            while true {
                // With field name
                if let next = encoded.first, next == quote {
                    encoded.removeFirst()

                    let fieldName = String(encoded.prefix { $0 != quote })
                    encoded.removeFirst(fieldName.count)

                    // Field name end
                    guard let end = encoded.first else {
                        // TODO: provide more detailed error
                        throw EncodingError(encoded: encoded)
                    }
                    if end != quote {
                        // TODO: provide more detailed error
                        throw EncodingError(encoded: encoded)
                    }
                    encoded.removeFirst()


                    // Field type
                    guard let fieldType = try decode(encoded: &encoded) else {
                        // TODO: provide more detailed error
                        throw EncodingError(encoded: encoded)
                    }

                    fields.append(Field(name: fieldName, type: fieldType))
                } else if let fieldType = try decode(encoded: &encoded) {
                    fields.append(Field(name: "", type: fieldType))
                } else {
                    break
                }
            }
        }

        // End
        guard let end = encoded.first else {
            // TODO: provide more detailed error
            throw EncodingError(encoded: encoded)
        }
        if end != expectedEnd {
            // TODO: provide more detailed error
            throw EncodingError(encoded: encoded)
        }
        encoded.removeFirst()

        return (
            name: String(name),
            fields: fields
        )
    }

    public static func decode(encoded: inout Substring) throws -> Type? {
        guard let first = encoded.first else {
            return nil
        }

        func singleResult(_ type: Type) -> Type {
            encoded.removeFirst()
            return type
        }

        switch first {

            // Signed
            case "c":
                return singleResult(.Char)

            case "i":
                return singleResult(.Int)

            case "s":
                return singleResult(.Short)

            case "l":
                return singleResult(.Long)

            case "q":
                return singleResult(.LongLong)

            // Unsigned
            case "C":
                return singleResult(.UnsignedChar)

            case "I":
                return singleResult(.UnsignedInt)

            case "S":
                return singleResult(.UnsignedShort)

            case "L":
                return singleResult(.UnsignedLong)

            case "Q":
                return singleResult(.UnsignedLongLong)

            // Floating point
            case "f":
                return singleResult(.Float)

            case "d":
                return singleResult(.Double)

            // Other

            case "B":
                return singleResult(.Bool)

            case "v":
                return singleResult(.Void)

            case "*":
                return singleResult(.Pointer(.Char))

            case "@":
                return singleResult(.ID)

            case "#":
                return singleResult(.Class)

            case ":":
                return singleResult(.Selector)

            case "[":
                encoded.removeFirst()

                // Size
                let sizePrefix = encoded.prefix { "0"..."9" ~= $0 }
                if sizePrefix.isEmpty {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                let size = Swift.Int(sizePrefix)!
                encoded.removeFirst(sizePrefix.count)

                // Element type
                guard let element = try decode(encoded: &encoded) else {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }

                // End
                guard let end = encoded.first else {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                if end != "]" {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                encoded.removeFirst()

                return .Array(ArrayType(size: size, type: element))

             case "{":
                let (name, fields) = try decodeNameAndFields(
                    encoded: &encoded,
                    expectedEnd: "}"
                )
                return .Struct(StructType(
                    name: name,
                    fields: fields
                ))

            case "(":
                let (name, fields) = try decodeNameAndFields(
                    encoded: &encoded,
                    expectedEnd: ")"
                )
                return .Union(UnionType(
                    name: name,
                    fields: fields
                ))

            case "b":
                encoded.removeFirst()

                // Size
                let sizePrefix = encoded.prefix { "0"..."9" ~= $0 }
                if sizePrefix.isEmpty {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                let size = Swift.Int(sizePrefix)!
                encoded.removeFirst(sizePrefix.count)

                return .Bitfield(size: size)

            case "^":
                encoded.removeFirst()
                guard let inner = try decode(encoded: &encoded) else {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                return .Pointer(inner)

            case "?":
                return singleResult(.Unknown)

            case "r":
                encoded.removeFirst()
                guard let inner = try decode(encoded: &encoded) else {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                return .Const(inner)

            default:
                return nil
        }
    }

    public init(encoded: some StringProtocol) throws {
        var encoded = Substring(encoded)
        guard let type = try Self.decode(encoded: &encoded) else {
            // TODO: provide more detailed error
            throw EncodingError(encoded: encoded)
        }
        if !encoded.isEmpty {
            // TODO: provide more detailed error
            throw EncodingError(encoded: encoded)
        }
        self = type
    }
}
