import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct Class: Equatable {
    public let name: String
    public var methods: [Method]
    public let ignore: Bool
    public let suggestion: String?

    public init(
        name: String,
        methods: [Method] = [],
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.name = name
        self.methods = methods
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public struct Method: Equatable {
    public let selector: String
    public let isClassMethod: Bool
    public var functionType: FunctionType
    public let isVariadic: Bool
    public let ignore: Bool
    public let suggestion: String?

    public init(
        selector: String,
        isClassMethod: Bool = false,
        functionType: FunctionType = FunctionType(),
        isVariadic: Bool = false,
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.selector = selector
        self.isClassMethod = isClassMethod
        self.functionType = functionType
        self.isVariadic = isVariadic
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public struct Struct: Equatable {
    public let name: String
    public let type32: StructType?
    public let type64: StructType?
    public var fields: [Field]
    public let ignore: Bool
    public let suggestion: String?

    public init(
        name: String,
        fields: [Field] = [],
        type32: StructType? = nil,
        type64: StructType? = nil,
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.name = name
        self.fields = fields
        self.type32 = type32
        self.type64 = type64
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public struct Field: Equatable {
    public let name: String
    public let type32: Type?
    public let type64: Type?
    public let ignore: Bool
    public let suggestion: String?

    public init(
        name: String,
        type32: Type? = nil,
        type64: Type? = nil,
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.name = name
        self.type32 = type32
        self.type64 = type64
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public enum Definition: Equatable {
    case Class(Class)
    case Struct(Struct)
    case Function(Function)
    case CoreFoundationType(CoreFoundationType)
    case Constant(Constant)
    case Enum(Enum)
    case Opaque(Opaque)
    case InformalProtocol(InformalProtocol)
    case StringConstant(StringConstant)
    case FunctionAlias(FunctionAlias)
}

public struct File: Equatable {
    public var definitions: [Definition]

    public init(
        definitions: [Definition] = []
    ) {
        self.definitions = definitions
    }
}

public enum TypeModifier: Equatable {

    public struct EncodingError<String: StringProtocol>: Error {
        public let encoded: String
        public var localizedDescription: String {
            "Invalid type encoding: \(encoded)"
        }
    }

    case In
    case Out
    case InOut

    public init(encoded: String) throws {
        switch encoded {
            case "n":
                self = .In

            case "o":
                self = .Out

            case "N":
                self = .InOut

            default:
                throw EncodingError(encoded: encoded)
        }
    }
}

public struct Argument: Equatable {
    public let name: String
    public let index: Int?
    public var type32: Type?
    public var type64: Type?
    public let declaredType: String?
    public let typeModifier: TypeModifier?
    public let isConst: Bool

    public init(
        name: String,
        index: Int? = nil,
        type32: Type? = nil,
        type64: Type? = nil,
        declaredType: String? = nil,
        typeModifier: TypeModifier? = nil,
        isConst: Bool = false
    ) {
        self.name = name
        self.index = index
        self.type32 = type32
        self.type64 = type64
        self.declaredType = declaredType
        self.typeModifier = typeModifier
        self.isConst = isConst
    }
}

public struct ReturnValue: Equatable {
    public var type32: Type?
    public var type64: Type?
    public let declaredType: String?
    public let isConst: Bool

    public init(
        type32: Type? = nil,
        type64: Type? = nil,
        declaredType: String? = nil,
        isConst: Bool = false
    ) {
        self.type32 = type32
        self.type64 = type64
        self.declaredType = declaredType
        self.isConst = isConst
    }
}

public struct Function: Equatable {
    public let name: String
    public var functionType: FunctionType
    public let isVariadic: Bool
    public let ignore: Bool
    public let suggestion: String?

    public init(
        name: String,
        functionType: FunctionType = FunctionType(),
        isVariadic: Bool = false,
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.name = name
        self.functionType = functionType
        self.isVariadic = isVariadic
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public struct CoreFoundationType: Equatable {
    public let name: String
    public let type32: Type?
    public let type64: Type?

    public init(
        name: String,
        type32: Type? = nil,
        type64: Type? = nil
    ) {
        self.name = name
        self.type32 = type32
        self.type64 = type64
    }
}

public struct Constant: Equatable {
    public let name: String
    public let type32: Type?
    public let type64: Type?
    public let declaredType: String?
    public let isConst: Bool
    public let ignore: Bool
    public let suggestion: String?

    public init(
        name: String,
        type32: Type? = nil,
        type64: Type? = nil,
        declaredType: String? = nil,
        isConst: Bool = false,
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.name = name
        self.type32 = type32
        self.type64 = type64
        self.declaredType = declaredType
        self.isConst = isConst
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public struct Enum: Equatable {
    public let name: String
    public let value32: String?
    public let value64: String?
    public let littleEndianValue: String?
    public let bigEndianValue: String?
    public let ignore: Bool
    public let suggestion: String?

    public init(
        name: String,
        value32: String? = nil,
        value64: String? = nil,
        littleEndianValue: String? = nil,
        bigEndianValue: String? = nil,
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.name = name
        self.value32 = value32
        self.value64 = value64
        self.littleEndianValue = littleEndianValue
        self.bigEndianValue = bigEndianValue
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public struct Opaque: Equatable {
    public let name: String
    public let type32: Type?
    public let type64: Type?
    public let ignore: Bool
    public let suggestion: String?

    public init(
        name: String,
        type32: Type? = nil,
        type64: Type? = nil,
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.name = name
        self.type32 = type32
        self.type64 = type64
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public struct InformalProtocol: Equatable {
    public let name: String
    public var methods: [Method]

    public init(
        name: String,
        methods: [Method] = []
    ) {
        self.name = name
        self.methods = methods
    }
}

public struct StringConstant: Equatable {
    public let name: String
    public let value: String?
    public let isNSString: Bool
    public let ignore: Bool
    public let suggestion: String?

    public init(
        name: String,
        value: String? = nil,
        isNSString: Bool = false,
        ignore: Bool = false,
        suggestion: String? = nil
    ) {
        self.name = name
        self.value = value
        self.isNSString = isNSString
        self.ignore = ignore
        self.suggestion = suggestion
    }
}

public struct FunctionAlias: Equatable {
    public let name: String
    public let original: String

    public init(
        name: String,
        original: String
    ) {
        self.name = name
        self.original = original
    }
}

public class Parser {

    public struct Position {
        public let lineNumber: Int
        public let columnNumber: Int
    }

    public enum Error: Swift.Error {
        case InvalidElement(
            element: Element,
            expected: Set<Element>,
            description: String,
            position: Position
        )
        case InvalidStartElement(
            tag: String,
            position: Position
        )
        case InvalidEndElement(
            tag: String,
            position: Position
        )
        case InvalidState(
            position: Position
        )
        case SecondReturnValue(
            position: Position
        )
        case ParentNotFunctionType(
            position: Position
        )
        case MissingName(
            position: Position
        )
        case MissingMethodSelector(
            position: Position
        )
        case InvalidType(
            decodedType: Type,
            bitness: Bitness
        )
        case MissingType(
            position: Position
        )
        case MissingValue(
            position: Position
        )
        case MissingOriginal(
            position: Position
        )
        case InvalidTypeEncoding(
            Type.EncodingError,
            position: Position
        )
    }

    // see BridgeSupport.dtd
    public enum Element: String {
        case Signatures = "signatures"

        case DependsOn = "depends_on"
        case Struct = "struct"
        case CoreFoundationType = "cftype"
        case Opaque = "opaque"
        case Constant = "constant"
        case StringConstant = "string_constant"
        case Enum = "enum"
        case Function = "function"
        case FunctionAlias = "function_alias"
        case InformalProtocol = "informal_protocol"
        case Class = "class"

        case Method = "method"
        case Argument = "arg"
        case ReturnValue = "retval"

        case Field = "field"
    }

    private let delegate: Delegate

    private init(parser: XMLParser) {
        self.delegate = Delegate(xmlParser: parser)
    }

    public convenience init(data: Data) {
        self.init(parser: XMLParser(data: data))
    }

    public convenience init(stream: InputStream) {
        self.init(parser: XMLParser(stream: stream))
    }

    public convenience init?(contentsOf url: URL) {
        guard let parser = XMLParser(contentsOf: url) else {
            return nil
        }
        self.init(parser: parser)
    }

    public func parse() throws -> File {
        return try delegate.parse()
    }

    private class Delegate: NSObject, XMLParserDelegate {

        private enum State {
            case Root
            case Signatures
            case DependsOn
            case Struct(Struct)
            case StructField(Struct, Field)
            case Class(Class)
            case ClassMethod(Class, Method)
            case Function(Function)
            case CoreFoundationType(CoreFoundationType)
            case Constant(Constant)
            case Enum(Enum)
            case Opaque(Opaque)
            case InformalProtocol(InformalProtocol)
            case InformalProtocolMethod(InformalProtocol, Method)
            case StringConstant(StringConstant)
            case FunctionAlias(FunctionAlias)
        }

        private var result = File()
        private let xmlParser: XMLParser

        private var state: State = .Root
        private var argumentsAndReturnValues: [ArgumentOrReturnValue] = []
        private var error: (any Swift.Error)? = nil

        private enum ArgumentOrReturnValue {
            case Argument(Argument)
            case ReturnValue(ReturnValue)
        }

        internal init(xmlParser: XMLParser) {
            self.xmlParser = xmlParser
            super.init()
            xmlParser.delegate = self
        }

        private var position: Position {
            Position(
                lineNumber: xmlParser.lineNumber,
                columnNumber: xmlParser.columnNumber
            )
        }

        internal func parse() throws -> File {
            result = File()
            error = nil

            guard xmlParser.parse() else {
                if let error {
                    throw error
                }
                throw xmlParser.parserError!
            }

            if let error {
                throw error
            }

            return result
        }

        private func invalidElement(
            _ element: Element,
            expected: Set<Element> = [],
            container: Element? = nil
        ) throws -> Never {
            let containerDescription: String
            if let container {
                containerDescription = "in \(container.rawValue)"
            } else {
                containerDescription = "at root"
            }

            let expectedDescription: String
            switch expected.count {
                case 0:
                    expectedDescription = ""
                case 1:
                    expectedDescription = "expected \(expected.first!.rawValue), got "
                default:
                    let expectedElementNames = expected.map { $0.rawValue }
                    expectedDescription =
                        "expected one of \(expectedElementNames.joined(separator: ", ")); got "
            }

            throw Error.InvalidElement(
                element: element,
                expected: expected,
                description: "invalid element \(containerDescription): \(expectedDescription)\(element.rawValue)",
                position: position
            )
        }

        private func expectEndElement(_ expectedElement: Element, element: Element) throws {
            guard element == expectedElement else {
                try invalidElement(
                    element,
                    expected: [expectedElement],
                    container: expectedElement
                )
            }
        }

        public func parser(
            _ parser: XMLParser,
            didStartElement element: String,
            namespaceURI: String?,
            qualifiedName: String?,
            attributes: [String: String]
        ) {
            do {
                try start(element: element, attributes: attributes)
            } catch let error{
                self.error = error
                xmlParser.abortParsing()
            }
        }

        private func start(element: String, attributes: [String: String]) throws {
            guard let element = Element(rawValue: element) else {
                throw Error.InvalidStartElement(
                    tag: element,
                    position: position
                )
            }

            switch state {
                case .Root:
                    guard case .Signatures = element else {
                        try invalidElement(
                            element,
                            expected: [.Signatures]
                        )
                    }
                    state = .Signatures

                case .Signatures:
                    switch element {
                        case .DependsOn:
                            state = .DependsOn

                        case .Struct:
                            state = .Struct(try Self.parseStruct(attributes: attributes, position: position))

                        case .Class:
                            state = .Class(try Self.parseClass(attributes: attributes, position: position))

                        case .Function:
                            state = .Function(try Self.parseFunction(attributes: attributes, position: position))

                        case .CoreFoundationType:
                            state = .CoreFoundationType(try Self.parseCoreFoundationType(attributes: attributes, position: position))

                        case .Constant:
                            state = .Constant(try Self.parseConstant(attributes: attributes, position: position))

                        case .Enum:
                            state = .Enum(try Self.parseEnum(attributes: attributes, position: position))

                        case .Opaque:
                            state = .Opaque(try Self.parseOpaque(attributes: attributes, position: position))

                        case .InformalProtocol:
                            state = .InformalProtocol(try Self.parseInformalProtocol(attributes: attributes, position: position))

                        case .StringConstant:
                            state = .StringConstant(try Self.parseStringConstant(attributes: attributes, position: position))

                        case .FunctionAlias:
                            state = .FunctionAlias(try Self.parseFunctionAlias(attributes: attributes, position: position))

                        default:
                            try invalidElement(
                                element,
                                expected: [
                                    .DependsOn,
                                    .Struct,
                                    .Class
                                ],
                                container: .Signatures
                            )
                    }

                case .DependsOn:
                    try invalidElement(
                        element,
                        container: .DependsOn
                    )

                case let .Struct(`struct`):
                    guard case .Field = element else {
                        try invalidElement(
                            element,
                            expected: [.Field],
                            container: .Struct
                        )
                    }
                    let field = try Self.parseField(attributes: attributes, position: position)
                    state = .StructField(`struct`, field)

                case let .Class(`class`):
                    guard case .Method = element else {
                        try invalidElement(
                            element,
                            expected: [.Method],
                            container: .Class
                        )
                    }
                    let method = try Self.parseMethod(attributes: attributes, position: position)
                    state = .ClassMethod(`class`, method)

                case .CoreFoundationType:
                    try invalidElement(
                        element,
                        container: .CoreFoundationType
                    )

                case .Constant:
                    try invalidElement(
                        element,
                        container: .Constant
                    )

                case .Enum:
                    try invalidElement(
                        element,
                        container: .Enum
                    )

                case .Opaque:
                    try invalidElement(
                        element,
                        container: .Opaque
                    )

                case let .InformalProtocol(informalProtocol):
                    guard case .Method = element else {
                        try invalidElement(
                            element,
                            expected: [.Method],
                            container: .InformalProtocol
                        )
                    }
                    let method = try Self.parseMethod(attributes: attributes, position: position)
                    state = .InformalProtocolMethod(informalProtocol, method)

                case .ClassMethod, .InformalProtocolMethod, .Function, .StructField:
                    switch element {
                    case .ReturnValue:
                        let returnValue = try Self.parseReturnValue(attributes: attributes, position: position)
                        argumentsAndReturnValues.append(.ReturnValue(returnValue))

                    case .Argument:
                        let argument = try Self.parseArgument(attributes: attributes, position: position)
                        argumentsAndReturnValues.append(.Argument(argument))

                    default:
                        try invalidElement(
                            element,
                            expected: [
                                .ReturnValue,
                                .Argument
                            ]
                        )
                    }

                case .StringConstant:
                    try invalidElement(
                        element,
                        container: .StringConstant
                    )

                case .FunctionAlias:
                    try invalidElement(
                        element,
                        container: .FunctionAlias
                    )
            }
        }

        public func parser(
            _ parser: XMLParser,
            didEndElement element: String,
            namespaceURI: String?,
            qualifiedName: String?
        ) {
            do {
                try end(element: element)
            } catch let error{
                self.error = error
                xmlParser.abortParsing()
            }
        }

        private func end(element: String) throws {
            guard let element = Element(rawValue: element) else {
                throw Error.InvalidEndElement(
                    tag: element,
                    position: position
                )
            }

            switch state {
                case .Root:
                    throw Error.InvalidState(position: position)

                case .Signatures:
                    try expectEndElement(.Signatures, element: element)
                    state = .Root

                case .DependsOn:
                    try expectEndElement(.DependsOn, element: element)
                    state = .Signatures

                case let .Struct(`struct`):
                    try expectEndElement(.Struct, element: element)
                    result.definitions.append(.Struct(`struct`))
                    state = .Signatures

                case var .StructField(`struct`, field):
                    switch element {
                        case .Field:
                            `struct`.fields.append(field)
                            state = .Struct(`struct`)

                        case .Argument:
                            if let _ = try endArgument() {
                                // TODO:
                                // field.functionType.append(argument: argument)
                                state = .StructField(`struct`, field)
                            }

                        case .ReturnValue:
                            if let _ = try endReturnValue() {
                                // TODO:
                                // var parentFunctionType = field.functionType
                                // guard parentFunctionType.returnValue == nil else {
                                //     throw Error.SecondReturnValue(position: position)
                                // }
                                // parentFunctionType.returnValue = returnValue
                                // field.functionType = parentFunctionType
                                state = .StructField(`struct`, field)
                            }

                        default:
                            throw Error.InvalidState(position: position)
                    }

                case let .Class(`class`):
                    try expectEndElement(.Class, element: element)
                    result.definitions.append(.Class(`class`))
                    state = .Signatures

                case var .ClassMethod(`class`, method):
                    switch element {
                        case .Method:
                            `class`.methods.append(method)
                            state = .Class(`class`)

                        case .Argument:
                            if let argument = try endArgument() {
                                method.functionType.append(argument: argument)
                                state = .ClassMethod(`class`, method)
                            }

                        case .ReturnValue:
                            if let returnValue = try endReturnValue() {
                                var parentFunctionType = method.functionType
                                guard parentFunctionType.returnValue == nil else {
                                    throw Error.SecondReturnValue(position: position)
                                }
                                parentFunctionType.returnValue = returnValue
                                method.functionType = parentFunctionType
                                state = .ClassMethod(`class`, method)
                            }

                        default:
                            throw Error.InvalidState(position: position)
                    }

                case let .InformalProtocol(informalProtocol):
                    try expectEndElement(.InformalProtocol, element: element)
                    result.definitions.append(.InformalProtocol(informalProtocol))
                    state = .Signatures

                case var .InformalProtocolMethod(informalProtocol, method):
                    switch element {
                        case .Method:
                            informalProtocol.methods.append(method)
                            state = .InformalProtocol(informalProtocol)

                        case .Argument:
                            if let argument = try endArgument() {
                                method.functionType.append(argument: argument)
                                state = .InformalProtocolMethod(informalProtocol, method)
                            }

                        case .ReturnValue:
                            if let returnValue = try endReturnValue() {
                                var parentFunctionType = method.functionType
                                guard parentFunctionType.returnValue == nil else {
                                    throw Error.SecondReturnValue(position: position)
                                }
                                parentFunctionType.returnValue = returnValue
                                method.functionType = parentFunctionType
                                state = .InformalProtocolMethod(informalProtocol, method)
                            }

                        default:
                            throw Error.InvalidState(position: position)
                    }

                case var .Function(function):
                    switch element {
                        case .Function:
                            result.definitions.append(.Function(function))
                            state = .Signatures

                        case .Argument:
                            if let argument = try endArgument() {
                                function.functionType.append(argument: argument)
                                state = .Function(function)
                            }

                        case .ReturnValue:
                            if let returnValue = try endReturnValue() {
                                var parentFunctionType = function.functionType
                                guard parentFunctionType.returnValue == nil else {
                                    throw Error.SecondReturnValue(position: position)
                                }
                                parentFunctionType.returnValue = returnValue
                                function.functionType = parentFunctionType
                                state = .Function(function)
                            }

                        default:
                            throw Error.InvalidState(position: position)
                    }

                case let .CoreFoundationType(type):
                    try expectEndElement(.CoreFoundationType, element: element)
                    result.definitions.append(.CoreFoundationType(type))
                    state = .Signatures

                case let .Constant(constant):
                    try expectEndElement(.Constant, element: element)
                    result.definitions.append(.Constant(constant))
                    state = .Signatures

                case let .Enum(`enum`):
                    try expectEndElement(.Enum, element: element)
                    result.definitions.append(.Enum(`enum`))
                    state = .Signatures

                case let .Opaque(opaque):
                    try expectEndElement(.Opaque, element: element)
                    result.definitions.append(.Opaque(opaque))
                    state = .Signatures

                case let .StringConstant(stringConstant):
                    try expectEndElement(.StringConstant, element: element)
                    result.definitions.append(.StringConstant(stringConstant))
                    state = .Signatures

                case let .FunctionAlias(functionAlias):
                    try expectEndElement(.FunctionAlias, element: element)
                    result.definitions.append(.FunctionAlias(functionAlias))
                    state = .Signatures
            }
        }

        private func endArgument() throws -> Argument? {
            let last = argumentsAndReturnValues.popLast()
            guard case let .Argument(argument) = last else {
                throw Error.InvalidState(position: position)
            }

            // TODO: add 64-bit support

            switch argumentsAndReturnValues.popLast() {
                case nil:
                    return argument

                case var .Argument(parentArgument):
                    guard case .FunctionType(var parentFunctionType) = parentArgument.type32 else {
                        throw Error.ParentNotFunctionType(position: position)
                    }
                    parentFunctionType.append(argument: argument)
                    parentArgument.type32 = .FunctionType(parentFunctionType)
                    argumentsAndReturnValues.append(.Argument(parentArgument))
                    return nil

                case var .ReturnValue(parentReturnValue):
                    guard case .FunctionType(var parentFunctionType) = parentReturnValue.type32 else {
                        throw Error.ParentNotFunctionType(position: position)
                    }
                    parentFunctionType.append(argument: argument)
                    parentReturnValue.type32 = .FunctionType(parentFunctionType)
                    argumentsAndReturnValues.append(.ReturnValue(parentReturnValue))
                    return nil
            }
        }

        private func endReturnValue() throws -> ReturnValue? {
            let last = argumentsAndReturnValues.popLast()
            guard case let .ReturnValue(returnValue) = last else {
                throw Error.InvalidState(position: position)
            }

            // TODO: add 64-bit support

            switch argumentsAndReturnValues.popLast() {
                case nil:
                    return returnValue

                case var .Argument(parentArgument):
                    guard case .FunctionType(var parentFunctionType) = parentArgument.type32 else {
                        throw Error.ParentNotFunctionType(position: position)
                    }
                    guard parentFunctionType.returnValue == nil else {
                        throw Error.SecondReturnValue(position: position)
                    }
                    parentFunctionType.returnValue = returnValue
                    parentArgument.type32 = .FunctionType(parentFunctionType)
                    argumentsAndReturnValues.append(.Argument(parentArgument))
                    return nil

                case var .ReturnValue(parentReturnValue):
                    guard case .FunctionType(var parentFunctionType) = parentReturnValue.type32 else {
                        throw Error.ParentNotFunctionType(position: position)
                    }
                    guard parentFunctionType.returnValue == nil else {
                        throw Error.SecondReturnValue(position: position)
                    }
                    parentFunctionType.returnValue = returnValue
                    parentReturnValue.type32 = .FunctionType(parentFunctionType)
                    argumentsAndReturnValues.append(.ReturnValue(parentReturnValue))
                    return nil
            }
        }

        public static func decodeType(encoded: String, bitness: Bitness, position: Position) throws -> Type {
             do {
                return try Type(encoded: encoded, bitness: bitness)
            } catch let error as Type.EncodingError {
                throw Error.InvalidTypeEncoding(
                    error,
                    position: position
                )
            }
        }

        public static func parseStruct(attributes: [String: String], position: Position) throws -> Struct {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            let structType32 = try attributes["type"].map { encodedType in
                let decodedType = try decodeType(encoded: encodedType, bitness: .Bit32, position: position)
                guard case let .Struct(structType) = decodedType else {
                    throw Error.InvalidType(
                        decodedType: decodedType,
                        bitness: .Bit32
                    )
                }
                return structType
            }
            let structType64 = try attributes["type64"].map { encodedType in
                let decodedType = try decodeType(encoded: encodedType, bitness: .Bit64, position: position)
                guard case let .Struct(structType) = decodedType else {
                    throw Error.InvalidType(
                        decodedType: decodedType,
                        bitness: .Bit64
                    )
                }
                return structType
            }
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            return Struct(
                name: name,
                type32: structType32,
                type64: structType64,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseField(attributes: [String: String], position: Position) throws -> Field {
            let name = attributes["name"] ?? ""
            let type32 = try attributes["type"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit32,
                    position: position
                )
            }
            let type64 = try attributes["type64"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit64,
                    position: position
                )
            }
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            return Field(
                name: name,
                type32: type32,
                type64: type64,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseClass(attributes: [String: String], position: Position) throws -> Class {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            return Class(
                name: name,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseMethod(attributes: [String: String], position: Position) throws -> Method {
            guard let selector = attributes["selector"] else {
                throw Error.MissingMethodSelector(position: position)
            }
            let isClassMethod = attributes["class_method"] == "true"
            let isVariadic = attributes["variadic"] == "true"
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            // TODO: parse type and type64 method signature
            // (not the same as an encoded type, see e.g. https://gcc.gnu.org/onlinedocs/gcc/Method-signatures.html)
            return Method(
                selector: selector,
                isClassMethod: isClassMethod,
                isVariadic: isVariadic,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseFunction(attributes: [String: String], position: Position) throws -> Function {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            let isVariadic = attributes["variadic"] == "true"
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            return Function(
                name: name,
                isVariadic: isVariadic,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseCoreFoundationType(attributes: [String: String], position: Position) throws -> CoreFoundationType {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            let type32 = try attributes["type"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit32,
                    position: position
                )
            }
            let type64 = try attributes["type64"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit64,
                    position: position
                )

            }
            guard type32 != nil || type64 != nil else {
                throw Error.MissingType(position: position)
            }

            return CoreFoundationType(
                name: name,
                type32: type32,
                type64: type64
            )
        }

        public static func parseConstant(attributes: [String: String], position: Position) throws -> Constant {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            let type32 = try attributes["type"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit32,
                    position: position
                )
            }
            let type64 = try attributes["type64"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit64,
                    position: position
                )
            }
            let declaredType = attributes["declared_type"]
            let isConst = attributes["const"] == "true"
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            guard ignore || type32 != nil || type64 != nil else {
                throw Error.MissingType(position: position)
            }

            return Constant(
                name: name,
                type32: type32,
                type64: type64,
                declaredType: declaredType,
                isConst: isConst,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseEnum(attributes: [String: String], position: Position) throws -> Enum {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            let value32 = attributes["value"]
            let value64 = attributes["value64"]
            let littleEndianValue = attributes["le_value"]
            let bigEndianValue = attributes["be_value"]
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            guard ignore
                || value32 != nil
                || value64 != nil
                || littleEndianValue != nil
                || bigEndianValue != nil
            else {
                throw Error.MissingValue(position: position)
            }
            return Enum(
                name: name,
                value32: value32,
                value64: value64,
                littleEndianValue: littleEndianValue,
                bigEndianValue: bigEndianValue,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseOpaque(attributes: [String: String], position: Position) throws -> Opaque {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            let type32 = try attributes["type"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit32,
                    position: position
                )
            }
            let type64 = try attributes["type64"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit64,
                    position: position
                )
            }
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            guard ignore || type32 != nil || type64 != nil else {
                throw Error.MissingType(position: position)
            }

            return Opaque(
                name: name,
                type32: type32,
                type64: type64,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseInformalProtocol(attributes: [String: String], position: Position) throws -> InformalProtocol {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            return InformalProtocol(name: name)
        }

        public static func parseReturnValue(attributes: [String: String], position: Position) throws -> ReturnValue {
            let declaredType = attributes["declared_type"]
            let isConst = attributes["const"] == "true"
            let isFunctionPointer = attributes["function_pointer"] == "true"

            func decodeType(encoded: String, bitness: Bitness) throws -> Type {
                let decoded = try Self.decodeType(encoded: encoded, bitness: bitness, position: position)
                if isFunctionPointer {
                    guard decoded.isValidFunctionPointerType else {
                        throw Error.InvalidType(
                            decodedType: decoded,
                            bitness: bitness
                        )
                    }
                    return Type.FunctionType(FunctionType())
                }
                return decoded
            }

            let type32 = try attributes["type"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit32
                )
            }
            let type64 = try attributes["type64"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit64
                )
            }

            return ReturnValue(
                type32: type32,
                type64: type64,
                declaredType: declaredType,
                isConst: isConst
            )
        }

        public static func parseArgument(attributes: [String: String], position: Position) throws -> Argument {
            let name = attributes["name"] ?? ""
            let index = attributes["index"].flatMap { Int($0) }
            let declaredType = attributes["declared_type"]
            let typeModifier = try attributes["type_modifier"].map { encoded in
                try TypeModifier(encoded: encoded)
            }
            let isConst = attributes["const"] == "true"
            let isFunctionPointer = attributes["function_pointer"] == "true"

            func decodeType(encoded: String, bitness: Bitness) throws -> Type {
                let decoded = try Self.decodeType(encoded: encoded, bitness: bitness, position: position)
                if isFunctionPointer {
                    guard decoded.isValidFunctionPointerType else {
                        throw Error.InvalidType(
                            decodedType: decoded,
                            bitness: bitness
                        )
                    }
                    return Type.FunctionType(FunctionType())
                }
                return decoded
            }

            let type32 = try attributes["type"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit32
                )
            }
            let type64 = try attributes["type64"].map { encodedType in
                try decodeType(
                    encoded: encodedType,
                    bitness: .Bit64
                )
            }

            return Argument(
                name: name,
                index: index,
                type32: type32,
                type64: type64,
                declaredType: declaredType,
                typeModifier: typeModifier,
                isConst: isConst
            )
        }

        public static func parseStringConstant(attributes: [String: String], position: Position) throws -> StringConstant {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            let value = attributes["value"]
            let isNSString = attributes["nsstring"] == "true"
            let ignore = attributes["ignore"] == "true"
            let suggestion = attributes["suggestion"]

            guard ignore || value != nil else {
                throw Error.MissingValue(position: position)
            }
            return StringConstant(
                name: name,
                value: value,
                isNSString: isNSString,
                ignore: ignore,
                suggestion: suggestion
            )
        }

        public static func parseFunctionAlias(attributes: [String: String], position: Position) throws -> FunctionAlias {
            guard let name = attributes["name"] else {
                throw Error.MissingName(position: position)
            }
            guard let original = attributes["original"] else {
                throw Error.MissingOriginal(position: position)
            }
            return FunctionAlias(
                name: name,
                original: original
            )
        }
    }
}
