import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct Class: Equatable {
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

public struct Method: Equatable {
    public let selector: String
    public let isClassMethod: Bool
    public var functionType: FunctionType

    public init(
        selector: String,
        isClassMethod: Bool,
        functionType: FunctionType = FunctionType()
    ) {
        self.selector = selector
        self.isClassMethod = isClassMethod
        self.functionType = functionType
    }
}

public struct Struct: Equatable {
    public let name: String
    public let type: StructType

    public init(
        name: String,
        type: StructType
    ) {
        self.name = name
        self.type = type
    }
}

public struct Field: Equatable {
    public let name: String
    public let type: Type

    public init(
        name: String,
        type: Type
    ) {
        self.name = name
        self.type = type
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

    public init(
        name: String,
        functionType: FunctionType = FunctionType()
    ) {
        self.name = name
        self.functionType = functionType
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

    public init(
        name: String,
        type32: Type? = nil,
        type64: Type? = nil,
        declaredType: String? = nil,
        isConst: Bool = false
    ) {
        self.name = name
        self.type32 = type32
        self.type64 = type64
        self.declaredType = declaredType
        self.isConst = isConst
    }
}

public struct Enum: Equatable {
    public let name: String
    public let value32: String?
    public let value64: String?
    public let littleEndianValue: String?
    public let bigEndianValue: String?

    public init(
        name: String,
        value32: String? = nil,
        value64: String? = nil,
        littleEndianValue: String? = nil,
        bigEndianValue: String? = nil
    ) {
        self.name = name
        self.value32 = value32
        self.value64 = value64
        self.littleEndianValue = littleEndianValue
        self.bigEndianValue = bigEndianValue
    }
}

public struct Opaque: Equatable {
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
    public let value: String
    public let isNSString: Bool

    public init(
        name: String,
        value: String,
        isNSString: Bool = false
    ) {
        self.name = name
        self.value = value
        self.isNSString = isNSString
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

public class Parser: NSObject, XMLParserDelegate {

    // see BridgeSupport.dtd
    private enum Element: String {
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

    private enum State {
        case Root
        case Signatures
        case DependsOn
        case Struct(Struct)
        case StructField(Struct)
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

    private let parser: XMLParser
    private var result = File()
    private var state: State = .Root
    private var argumentsAndReturnValues: [ArgumentOrReturnValue] = []

    private enum ArgumentOrReturnValue {
        case Argument(Argument)
        case ReturnValue(ReturnValue)
    }

    private init(parser: XMLParser) {
        self.parser = parser
        super.init()
        parser.delegate = self
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
        result = File()

        guard parser.parse() else {
            throw parser.parserError!
        }

        return result
    }

    private static func invalidElement(
        _ element: Element,
        expected: Set<Element> = [],
        container: Element? = nil
    ) -> Never {
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

        fatalError("invalid element \(containerDescription): \(expectedDescription)\(element.rawValue)")
    }

    private static func expectEndElement(_ expectedElement: Element, element: Element) {
        guard element == expectedElement else {
            Parser.invalidElement(
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
        guard let element = Element(rawValue: element) else {
            fatalError("start of unsupported element: \(element)")
        }

        switch state {
            case .Root:
                guard case .Signatures = element else {
                    Parser.invalidElement(
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
                        state = .Struct(Parser.parseStruct(attributes: attributes))

                    case .Class:
                        state = .Class(Parser.parseClass(attributes: attributes))

                    case .Function:
                        state = .Function(Parser.parseFunction(attributes: attributes))

                    case .CoreFoundationType:
                        state = .CoreFoundationType(Parser.parseCoreFoundationType(attributes: attributes))

                    case .Constant:
                        state = .Constant(Parser.parseConstant(attributes: attributes))

                    case .Enum:
                        state = .Enum(Parser.parseEnum(attributes: attributes))

                    case .Opaque:
                        state = .Opaque(Parser.parseOpaque(attributes: attributes))

                    case .InformalProtocol:
                        state = .InformalProtocol(Parser.parseInformalProtocol(attributes: attributes))

                    case .StringConstant:
                        state = .StringConstant(Parser.parseStringConstant(attributes: attributes))

                    case .FunctionAlias:
                        state = .FunctionAlias(Parser.parseFunctionAlias(attributes: attributes))

                    default:
                        Parser.invalidElement(
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
                Parser.invalidElement(
                    element,
                    container: .DependsOn
                )

            case let .Struct(`struct`):
                guard case .Field = element else {
                    Parser.invalidElement(
                        element,
                        expected: [.Field],
                        container: .Struct
                    )
                }
                // Fields are ignored - their names and types are taken from the struct type
                state = .StructField(`struct`)

            case .StructField:
                Parser.invalidElement(
                    element,
                    container: .Field
                )

            case let .Class(`class`):
                guard case .Method = element else {
                    Parser.invalidElement(
                        element,
                        expected: [.Method],
                        container: .Class
                    )
                }
                let method = Parser.parseMethod(attributes: attributes)
                state = .ClassMethod(`class`, method)

            case .CoreFoundationType:
                Parser.invalidElement(
                    element,
                    container: .CoreFoundationType
                )

            case .Constant:
                Parser.invalidElement(
                    element,
                    container: .Constant
                )

            case .Enum:
                Parser.invalidElement(
                    element,
                    container: .Enum
                )

            case .Opaque:
                Parser.invalidElement(
                    element,
                    container: .Opaque
                )

            case let .InformalProtocol(informalProtocol):
                guard case .Method = element else {
                    Parser.invalidElement(
                        element,
                        expected: [.Method],
                        container: .InformalProtocol
                    )
                }
                let method = Parser.parseMethod(attributes: attributes)
                state = .InformalProtocolMethod(informalProtocol, method)

            case .ClassMethod, .InformalProtocolMethod, .Function:
                switch element {
                case .ReturnValue:
                    let returnValue = Parser.parseReturnValue(attributes: attributes)
                    argumentsAndReturnValues.append(.ReturnValue(returnValue))

                case .Argument:
                    let argument = Parser.parseArgument(attributes: attributes)
                    argumentsAndReturnValues.append(.Argument(argument))

                default:
                    Parser.invalidElement(
                        element,
                        expected: [
                            .ReturnValue,
                            .Argument
                        ],
                        container: .Method
                    )
                }

            case .StringConstant:
                Parser.invalidElement(
                    element,
                    container: .StringConstant
                )

            case .FunctionAlias:
                Parser.invalidElement(
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
        guard let element = Element(rawValue: element) else {
            fatalError("end of unsupported element: \(element)")
        }

        switch state {
            case .Root:
                fatalError("invalid state")

            case .Signatures:
                Parser.expectEndElement(.Signatures, element: element)
                state = .Root

            case .DependsOn:
                Parser.expectEndElement(.DependsOn, element: element)
                state = .Signatures

            case let .Struct(`struct`):
                Parser.expectEndElement(.Struct, element: element)
                result.definitions.append(.Struct(`struct`))
                state = .Signatures

            case let .StructField(`struct`):
                Parser.expectEndElement(.Field, element: element)
                state = .Struct(`struct`)

            case let .Class(`class`):
                Parser.expectEndElement(.Class, element: element)
                result.definitions.append(.Class(`class`))
                state = .Signatures

            case var .ClassMethod(`class`, method):
                switch element {
                    case .Method:
                        `class`.methods.append(method)
                        state = .Class(`class`)

                    case .Argument:
                        if let argument = endArgument() {
                            method.functionType.append(argument: argument)
                            state = .ClassMethod(`class`, method)
                        }

                    case .ReturnValue:
                        if let returnValue = endReturnValue() {
                            var parentFunctionType = method.functionType
                            guard parentFunctionType.returnValue == nil else {
                                fatalError("invalid second return value for method")
                            }
                            parentFunctionType.returnValue = returnValue
                            method.functionType = parentFunctionType
                            state = .ClassMethod(`class`, method)
                        }

                    default:
                        fatalError("invalid state")
                }

            case let .InformalProtocol(informalProtocol):
                Parser.expectEndElement(.InformalProtocol, element: element)
                result.definitions.append(.InformalProtocol(informalProtocol))
                state = .Signatures

            case var .InformalProtocolMethod(informalProtocol, method):
                switch element {
                    case .Method:
                        informalProtocol.methods.append(method)
                        state = .InformalProtocol(informalProtocol)

                    case .Argument:
                        if let argument = endArgument() {
                            method.functionType.append(argument: argument)
                            state = .InformalProtocolMethod(informalProtocol, method)
                        }

                    case .ReturnValue:
                        if let returnValue = endReturnValue() {
                            var parentFunctionType = method.functionType
                            guard parentFunctionType.returnValue == nil else {
                                fatalError("invalid second return value for method")
                            }
                            parentFunctionType.returnValue = returnValue
                            method.functionType = parentFunctionType
                            state = .InformalProtocolMethod(informalProtocol, method)
                        }

                    default:
                        fatalError("invalid state")
                }

            case var .Function(function):
                switch element {
                    case .Function:
                        result.definitions.append(.Function(function))
                        state = .Signatures

                    case .Argument:
                        if let argument = endArgument() {
                            function.functionType.append(argument: argument)
                            state = .Function(function)
                        }

                    case .ReturnValue:
                        if let returnValue = endReturnValue() {
                            var parentFunctionType = function.functionType
                            guard parentFunctionType.returnValue == nil else {
                                fatalError("invalid second return value for method")
                            }
                            parentFunctionType.returnValue = returnValue
                            function.functionType = parentFunctionType
                            state = .Function(function)
                        }

                    default:
                        fatalError("invalid state")
                }

            case let .CoreFoundationType(type):
                Parser.expectEndElement(.CoreFoundationType, element: element)
                result.definitions.append(.CoreFoundationType(type))
                state = .Signatures

            case let .Constant(constant):
                Parser.expectEndElement(.Constant, element: element)
                result.definitions.append(.Constant(constant))
                state = .Signatures

            case let .Enum(`enum`):
                Parser.expectEndElement(.Enum, element: element)
                result.definitions.append(.Enum(`enum`))
                state = .Signatures

            case let .Opaque(opaque):
                Parser.expectEndElement(.Opaque, element: element)
                result.definitions.append(.Opaque(opaque))
                state = .Signatures

            case let .StringConstant(stringConstant):
                Parser.expectEndElement(.StringConstant, element: element)
                result.definitions.append(.StringConstant(stringConstant))
                state = .Signatures

            case let .FunctionAlias(functionAlias):
                Parser.expectEndElement(.FunctionAlias, element: element)
                result.definitions.append(.FunctionAlias(functionAlias))
                state = .Signatures
        }
    }

    private func endArgument() -> Argument? {
        let last = argumentsAndReturnValues.popLast()
        guard case let .Argument(argument) = last else {
            fatalError("invalid state: expected argument, got \(String(describing: last))")
        }

        switch argumentsAndReturnValues.popLast() {
            case nil:
                return argument

            case var .Argument(parentArgument):
                guard case .FunctionType(var parentFunctionType) = parentArgument.type32 else {
                    fatalError("parent argument is not a function type")
                }
                parentFunctionType.append(argument: argument)
                parentArgument.type32 = .FunctionType(parentFunctionType)
                argumentsAndReturnValues.append(.Argument(parentArgument))
                return nil

            case var .ReturnValue(parentReturnValue):
                guard case .FunctionType(var parentFunctionType) = parentReturnValue.type32 else {
                    fatalError("parent return value is not a function type")
                }
                parentFunctionType.append(argument: argument)
                parentReturnValue.type32 = .FunctionType(parentFunctionType)
                argumentsAndReturnValues.append(.ReturnValue(parentReturnValue))
                return nil
        }
    }

    private func endReturnValue() -> ReturnValue? {
        let last = argumentsAndReturnValues.popLast()
        guard case let .ReturnValue(returnValue) = last else {
            fatalError("invalid state: expected return value, got \(String(describing: last))")
        }

        switch argumentsAndReturnValues.popLast() {
            case nil:
                return returnValue

            case var .Argument(parentArgument):
                guard case .FunctionType(var parentFunctionType) = parentArgument.type32 else {
                    fatalError("parent argument is not a function type")
                }
                guard parentFunctionType.returnValue == nil else {
                    fatalError("invalid second return value for parent argument")
                }
                parentFunctionType.returnValue = returnValue
                parentArgument.type32 = .FunctionType(parentFunctionType)
                argumentsAndReturnValues.append(.Argument(parentArgument))
                return nil

            case var .ReturnValue(parentReturnValue):
                guard case .FunctionType(var parentFunctionType) = parentReturnValue.type32 else {
                    fatalError("parent return value is not a function type")
                }
                guard parentFunctionType.returnValue == nil else {
                    fatalError("invalid second return value for parent return value")
                }
                parentFunctionType.returnValue = returnValue
                parentReturnValue.type32 = .FunctionType(parentFunctionType)
                argumentsAndReturnValues.append(.ReturnValue(parentReturnValue))
                return nil
        }
    }

    public static func parseStruct(attributes: [String: String]) -> Struct {
        guard let name = attributes["name"] else {
            fatalError("missing name in struct declaration")
        }
        guard let encodedType = attributes["type"] else {
            fatalError("missing type in struct declaration")
        }
        guard case let .Struct(structType) = try! Type(encoded: encodedType) else {
            fatalError("non-struct type for struct declaration: \(encodedType)")
        }
        return Struct(
            name: name,
            type: structType
        )
    }

    public static func parseClass(attributes: [String: String]) -> Class {
        guard let name = attributes["name"] else {
            fatalError("missing name in class declaration")
        }
        return Class(name: name)
    }

    public static func parseMethod(attributes: [String: String]) -> Method {
        guard let selector = attributes["selector"] else {
            fatalError("missing selector in method declaration")
        }
        let isClassMethod = attributes["class_method"] == "true"
        // TODO: parse type and type64 method signature
        // (not the same as an encoded type, see e.g. https://gcc.gnu.org/onlinedocs/gcc/Method-signatures.html)
        return Method(
            selector: selector,
            isClassMethod: isClassMethod
        )
    }

    public static func parseFunction(attributes: [String: String]) -> Function {
        guard let name = attributes["name"] else {
            fatalError("missing name in function declaration")
        }
        return Function(name: name)
    }

    public static func parseCoreFoundationType(attributes: [String: String]) -> CoreFoundationType {
        guard let name = attributes["name"] else {
            fatalError("missing name in Core Foundation type declaration")
        }
        let result = CoreFoundationType(
            name: name,
            type32: attributes["type"].map { try! Type(encoded: $0) },
            type64: attributes["type64"].map { try! Type(encoded: $0) }
        )
        guard result.type32 != nil || result.type64 != nil else {
            fatalError("missing 32-bit or 64-bit type in Core Foundation type declaration")
        }
        return result
    }

    public static func parseConstant(attributes: [String: String]) -> Constant {
        guard let name = attributes["name"] else {
            fatalError("missing name in constant declaration")
        }
        let result = Constant(
            name: name,
            type32: attributes["type"].map { try! Type(encoded: $0) },
            type64: attributes["type64"].map { try! Type(encoded: $0) },
            declaredType: attributes["declared_type"],
            isConst: attributes["const"] == "true"
        )
        guard result.type32 != nil || result.type64 != nil else {
            fatalError("missing 32-bit or 64-bit value in constant declaration")
        }
        return result
    }

    public static func parseEnum(attributes: [String: String]) -> Enum {
        guard let name = attributes["name"] else {
            fatalError("missing name in enum declaration")
        }
        let result = Enum(
            name: name,
            value32: attributes["value"],
            value64: attributes["value64"],
            littleEndianValue: attributes["le_value"],
            bigEndianValue: attributes["be_value"]
        )
        guard
            result.value32 != nil
            || result.value64 != nil
            || result.littleEndianValue != nil
            || result.bigEndianValue != nil
        else {
            fatalError("missing 32-bit, 64-bit, little-endian, or big-endian value in enum declaration")
        }
        return result
    }

    public static func parseOpaque(attributes: [String: String]) -> Opaque {
        guard let name = attributes["name"] else {
            fatalError("missing name in opaque declaration")
        }
        let result = Opaque(
            name: name,
            type32: attributes["type"].map { try! Type(encoded: $0) },
            type64: attributes["type64"].map { try! Type(encoded: $0) }
        )
        guard result.type32 != nil || result.type64 != nil else {
            fatalError("missing 32-bit or 64-bit type in opaque declaration")
        }
        return result
    }

    public static func parseInformalProtocol(attributes: [String: String]) -> InformalProtocol {
        guard let name = attributes["name"] else {
            fatalError("missing name in informal protocol declaration")
        }
        return InformalProtocol(name: name)
    }

    private static func parseReturnValue(attributes: [String: String]) -> ReturnValue {
        let declaredType = attributes["declared_type"]

        let isConst = attributes["const"] == "true"

        let isFunctionPointer = attributes["function_pointer"] == "true"
        let typeAttribute = attributes["type"]
        if isFunctionPointer {
            if let typeAttribute {
                guard try! Type(encoded: typeAttribute) == .Pointer(.Unknown) else {
                    fatalError("invalid type for function pointer return value: \(typeAttribute)")
                }
            }
            guard attributes["type64"] == nil else {
                fatalError("invalid 64-bit type for function pointer return value")
            }
            return ReturnValue(
                type32: .FunctionType(FunctionType()),
                type64: nil,
                declaredType: declaredType,
                isConst: isConst
            )
        }
        // NOTE: return value has neither type nor type64 if method has type or type64
        return ReturnValue(
            type32: attributes["type"].map { try! Type(encoded: $0) },
            type64: attributes["type64"].map { try! Type(encoded: $0) },
            declaredType: declaredType,
            isConst: isConst
        )
    }

    private static func parseArgument(attributes: [String: String]) -> Argument {
        let name = attributes["name"] ?? ""
        let index = attributes["index"].flatMap { Int($0) }

        let declaredType = attributes["declared_type"]

        let typeModifier = attributes["type_modifier"].map {
            try! TypeModifier(encoded: $0)
        }

        let isConst = attributes["const"] == "true"

        let isFunctionPointer = attributes["function_pointer"] == "true"
        let typeAttribute = attributes["type"]
        if isFunctionPointer {
            if let typeAttribute {
                guard try! Type(encoded: typeAttribute) == .Pointer(.Unknown) else {
                    fatalError("invalid type for function pointer argument: \(typeAttribute)")
                }
            }
            guard attributes["type64"] == nil else {
                fatalError("invalid 64-bit type for function pointer argument")
            }
            return Argument(
                name: name,
                index: index,
                type32: .FunctionType(FunctionType()),
                type64: nil,
                declaredType: declaredType,
                typeModifier: typeModifier,
                isConst: isConst
            )
        }

        // NOTE: argument has neither type nor type64 if method has type or type64
        return Argument(
            name: name,
            index: index,
            type32: attributes["type"].map { try! Type(encoded: $0) },
            type64: attributes["type64"].map { try! Type(encoded: $0) },
            declaredType: declaredType,
            typeModifier: typeModifier,
            isConst: isConst
        )
    }

    private static func parseStringConstant(attributes: [String: String]) -> StringConstant {
        guard let name = attributes["name"] else {
            fatalError("missing name in string constant declaration")
        }
        let isNSString = attributes["nsstring"] == "true"
        guard let value = attributes["value"] else {
            fatalError("missing value in string constant declaration")
        }
        return StringConstant(
            name: name,
            value: value,
            isNSString: isNSString
        )
    }

    private static func parseFunctionAlias(attributes: [String: String]) -> FunctionAlias {
        guard let name = attributes["name"] else {
            fatalError("missing name in function alias declaration")
        }
        guard let original = attributes["original"] else {
            fatalError("missing name in function alias declaration")
        }
        return FunctionAlias(
            name: name,
            original: original
        )
    }
}
