
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

public enum Bitness: Equatable {
    case Bit32
    case Bit64
}

// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
public indirect enum Type: Equatable {

    private static let quote: Character = "\""

    public struct EncodingError: Error {
        public let encoded: Substring
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

    // Complex
    case ComplexFloat
    case ComplexDouble

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

    private static func readQuotedString(encoded: inout Substring) throws -> String? {

        guard let next = encoded.first, next == quote else {
            return nil
        }

        encoded.removeFirst()

        let string = String(encoded.prefix { $0 != quote })
        encoded.removeFirst(string.count)

        // Field name end
        guard let end = encoded.first else {
            // TODO: provide more detailed error
            throw EncodingError(encoded: encoded)
        }
        guard end == quote else {
            // TODO: provide more detailed error
            throw EncodingError(encoded: encoded)
        }
        encoded.removeFirst()

        return string
    }

    private static func decodeField(
        encoded: inout Substring,
        bitness: Bitness
    ) throws -> Field? {

        func newField(name: String, type: Type) -> Field {
            switch bitness {
                case .Bit32:
                    return Field(name: name, type32: type)
                case .Bit64:
                    return Field(name: name, type64: type)
            }
        }

        // With field name
        if let fieldName = try readQuotedString(encoded: &encoded) {

            // Field type
            guard let fieldType = try decode(
                encoded: &encoded,
                bitness: bitness
            ) else {
                // TODO: provide more detailed error
                throw EncodingError(encoded: encoded)
            }

            return newField(name: fieldName, type: fieldType)

        } else if let fieldType = try decode(
            encoded: &encoded,
            bitness: bitness
        ) {
            return newField(name: "", type: fieldType)

        } else {
            return nil
        }
    }

    private static func decodeNameAndFields(
        encoded: inout Substring,
        expectedEnd: Character,
        bitness: Bitness
    ) throws -> (
        name: String,
        fields: [Field]
    ) {
        encoded.removeFirst()

        var fields: [Field] = []

        let separator: Character = "="

        // Name
        let name = encoded.prefix { $0 != separator && $0 != expectedEnd }
        encoded.removeFirst(name.count)

        // Separator
        if let next = encoded.first, next == separator {
            encoded.removeFirst()

            // Fields
            while let field = try decodeField(
                encoded: &encoded,
                bitness: bitness
            ) {
                fields.append(field)
            }
        }

        // End
        if let end = encoded.first {
            guard end == expectedEnd else {
                // TODO: provide more detailed error
                throw EncodingError(encoded: encoded)
            }
            encoded.removeFirst()
        }
        return (
            name: String(name),
            fields: fields
        )
    }

    public static func decode(
        encoded: inout Substring,
        bitness: Bitness
    ) throws -> Type? {

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

            // Complex
            case "j":
                encoded.removeFirst()
                if encoded.isEmpty {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                switch encoded.removeFirst() {
                    case "f":
                        return .ComplexFloat

                    case "d":
                        return .ComplexDouble

                    default:
                        return nil
                }

            // Other

            case "B":
                return singleResult(.Bool)

            case "v":
                return singleResult(.Void)

            case "*":
                return singleResult(.Pointer(.Char))

            case "@":
                encoded.removeFirst()

                // Special cases
                if let next = encoded.first {

                    switch next {
                        case "?":
                            // Blocks are encoded as '@?' for some reason
                            encoded.removeFirst()

                        case "\"":
                            // Class name
                            //
                            // From LLVM's AppleObjCTypeEncodingParser.cpp:
                            //
                            //   We have to be careful here.  We're used to seeing
                            //     @"NSString"
                            //   but in records it is possible that the string following an @ is the name
                            //   of the next field and @ means "id". This is the case if anything
                            //   unquoted except for "}", the end of the type, or another name follows
                            //   the quoted string.
                            //
                            //   E.g.
                            //   - @"NSString"@ means "id, followed by a field named NSString of type id"
                            //   - @"NSString"} means "a pointer to NSString and the end of the struct" -
                            //   @"NSString""nextField" means "a pointer to NSString and a field named
                            //   nextField" - @"NSString" followed by the end of the string means "a
                            //   pointer to NSString"
                            //
                            //   As a result, the rule is: If we see @ followed by a quoted string, we
                            //   peek. - If we see }, ), ], the end of the string, or a quote ("), the
                            //   quoted string is a class name. - If we see anything else, the quoted
                            //   string is a field name and we push it back onto type.

                            guard let name = try readQuotedString(encoded: &encoded) else {
                                // TODO: provide more detailed error
                                throw EncodingError(encoded: encoded)
                            }

                            if let next = encoded.first {
                                switch next {
                                    case "}", ")", "]", quote:
                                        // The quoted string is a class name – see the rule
                                        break

                                    default:
                                        // Roll back the consumption of the quoted string
                                        let oldEncoded = encoded
                                        encoded = ""
                                        encoded.append(quote)
                                        encoded.append(contentsOf: name)
                                        encoded.append(quote)
                                        encoded.append(contentsOf: oldEncoded)
                                }
                            } else {
                                // The quoted string is a class name – see the rule
                            }

                        default:
                            break
                    }
                }

                return .ID

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
                guard let element = try decode(
                    encoded: &encoded,
                    bitness: bitness
                ) else {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }

                // Name (optional, ignored)
                _ = try readQuotedString(encoded: &encoded)

                // End
                if let end = encoded.first {
                    guard end == "]" else {
                        // TODO: provide more detailed error
                        throw EncodingError(encoded: encoded)
                    }
                    encoded.removeFirst()
                }

                return .Array(ArrayType(size: size, type: element))

             case "{":
                let (name, fields) = try decodeNameAndFields(
                    encoded: &encoded,
                    expectedEnd: "}",
                    bitness: bitness
                )
                return .Struct(StructType(
                    name: name,
                    fields: fields
                ))

            case "(":
                let (name, fields) = try decodeNameAndFields(
                    encoded: &encoded,
                    expectedEnd: ")",
                    bitness: bitness
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
                guard let inner = try decode(
                    encoded: &encoded,
                    bitness: bitness
                ) else {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                return .Pointer(inner)

            case "?":
                return singleResult(.Unknown)

            case "r":
                encoded.removeFirst()
                guard let inner = try decode(
                    encoded: &encoded,
                    bitness: bitness
                ) else {
                    // TODO: provide more detailed error
                    throw EncodingError(encoded: encoded)
                }
                return .Const(inner)

            default:
                return nil
        }
    }

    public init(encoded: some StringProtocol, bitness: Bitness) throws {
        var encoded = Substring(encoded)
        guard let type = try Self.decode(
            encoded: &encoded,
            bitness: bitness
        ) else {
            // TODO: provide more detailed error
            throw EncodingError(encoded: encoded)
        }
        if !encoded.isEmpty {
            // TODO: provide more detailed error
            throw EncodingError(encoded: encoded)
        }
        self = type
    }

    public var isPointerKinded: Bool {
        switch self {
        case .Pointer, .FunctionType, .ID, .Class, .Selector:
            return true
        default:
            return false
        }
    }

    public var isPointer: Bool {
        switch self {
            case .Pointer:
                return true
            default:
                return false
        }
    }

    public var isValidFunctionPointerType: Bool {
        return self == .Pointer(.Unknown)
            || self == .ID
    }
}
