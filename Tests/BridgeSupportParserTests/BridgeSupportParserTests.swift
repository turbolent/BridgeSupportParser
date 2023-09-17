import XCTest
import BridgeSupportParser
import Difference

public func XCTAssertEqual<T: Equatable>(_ expected: @autoclosure () throws -> T, _ received: @autoclosure () throws -> T, file: StaticString = #filePath, line: UInt = #line) {
    do {
        let expected = try expected()
        let received = try received()
        XCTAssertTrue(expected == received, "Found difference for \n" + diff(expected, received).joined(separator: ", "), file: file, line: line)
    }
    catch {
        XCTFail("Caught error while testing: \(error)", file: file, line: line)
    }
}

class BridgeSupportParserTests: XCTestCase {

    public func testClass() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "class", ofType: "bridgesupport"))
        let parser = try XCTUnwrap(Parser(contentsOf: URL(fileURLWithPath: path)))

        let result = try parser.parse()

        XCTAssertEqual(
            result,
            File(
                definitions: [
                    .Class(Class(
                        name: "Foo",
                        methods: [
                            Method(
                                selector: "initWithBar:",
                                isClassMethod: false,
                                functionType: FunctionType(
                                    arguments: [
                                        Argument(
                                            name: "bar",
                                            index: 0,
                                            type32: .UnsignedInt
                                        )
                                    ],
                                    returnValue: ReturnValue(
                                        type32: .Int
                                    )
                                )
                            ),
                            Method(
                                selector: "fooWithBar:",
                                isClassMethod: true,
                                functionType: FunctionType(
                                    arguments: [
                                        Argument(
                                            name: "bar",
                                            index: 0,
                                            type32: .UnsignedInt
                                        )
                                    ],
                                    returnValue: ReturnValue(
                                        type32: .Int
                                    )
                                )
                            )
                        ]
                    ))
                ]
            )
        )
    }

    public func testMethodFunctionPointerArg() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "method_function_pointer_arg", ofType: "bridgesupport"))
        let parser = try XCTUnwrap(Parser(contentsOf: URL(fileURLWithPath: path)))

        let result = try parser.parse()

        XCTAssertEqual(
            result,
            File(
                definitions: [
                    .Class(Class(
                        name: "Foo",
                        methods: [
                            Method(
                                selector: "foo:bar:baz:",
                                isClassMethod: false,
                                functionType: FunctionType(
                                    arguments: [
                                        Argument(
                                            name: "foo",
                                            type32: .Int
                                        ),
                                        Argument(
                                            name: "bar",
                                            type32: .FunctionType(FunctionType(
                                                arguments: [
                                                    Argument(
                                                        name: "",
                                                        type32: .Float
                                                    ),
                                                    Argument(
                                                        name: "",
                                                        type32: .Double
                                                    )
                                                ],
                                                returnValue: ReturnValue(
                                                    type32: .Char
                                                )
                                            ))
                                        ),
                                        Argument(
                                            name: "baz",
                                            type32: .UnsignedInt
                                        )
                                    ],
                                    returnValue: ReturnValue(
                                        type32: .UnsignedChar
                                    )
                                )
                            ),
                        ]
                    ))
                ]
            )
        )
    }

    public func testMethodFunctionPointerRetval() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "method_function_pointer_retval", ofType: "bridgesupport"))
        let parser = try XCTUnwrap(Parser(contentsOf: URL(fileURLWithPath: path)))

        let result = try parser.parse()

        XCTAssertEqual(
            result,
            File(
                definitions: [
                    .Class(Class(
                        name: "Foo",
                        methods: [
                            Method(
                                selector: "foo:bar:",
                                isClassMethod: false,
                                functionType: FunctionType(
                                    arguments: [
                                        Argument(
                                            name: "foo",
                                            type32: .Int
                                        ),
                                        Argument(
                                            name: "bar",
                                            type32: .UnsignedInt
                                        )
                                    ],
                                    returnValue: ReturnValue(
                                        type32: .FunctionType(FunctionType(
                                            arguments: [
                                                Argument(
                                                    name: "",
                                                    type32: .Float
                                                ),
                                                Argument(
                                                    name: "",
                                                    type32: .Double
                                                )
                                            ],
                                            returnValue: ReturnValue(
                                                type32: .Char
                                            )
                                        ))
                                    )
                                )
                            ),
                        ]
                    ))
                ]
            )
        )
    }

    public func testFunction() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "function", ofType: "bridgesupport"))
        let parser = try XCTUnwrap(Parser(contentsOf: URL(fileURLWithPath: path)))

        let result = try parser.parse()

        XCTAssertEqual(
            result,
            File(
                definitions: [
                    .Function(Function(
                        name: "foo",
                        functionType: FunctionType(
                            arguments: [
                                Argument(
                                    name: "bar",
                                    index: 0,
                                    type32: .UnsignedInt
                                )
                            ],
                            returnValue: ReturnValue(
                                type32: .Int
                            )
                        )
                    )),
                    .Function(Function(
                        name: "baz",
                        functionType: FunctionType(
                            arguments: [
                                Argument(
                                    name: "blub",
                                    index: 0,
                                    type32: .Int
                                )
                            ],
                            returnValue: ReturnValue(
                                type32: .UnsignedInt
                            )
                        )
                    )),
                    .Function(Function(
                        name: "consts",
                        functionType: FunctionType(
                            arguments: [
                                Argument(
                                    name: "in",
                                    index: 0,
                                    type32: .Pointer(.Int),
                                    isConst: true
                                )
                            ],
                            returnValue: ReturnValue(
                                type32: .Pointer(.Int),
                                isConst: true
                            )
                        )
                    ))
                ]
            )
        )
    }

    public func testStruct() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "struct", ofType: "bridgesupport"))
        let parser = try XCTUnwrap(Parser(contentsOf: URL(fileURLWithPath: path)))

        let result = try parser.parse()

        XCTAssertEqual(
            result,
            File(
                definitions: [
                    .Struct(Struct(
                        name: "Point",
                        type: StructType(
                            name: "_Point",
                            fields: [
                                Field(name: "x", type: .Float),
                                Field(name: "y", type: .Float),
                            ]
                        )
                    ))
                ]
            )
        )
    }

    public func testCoreFoundationType() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "cftype", ofType: "bridgesupport"))
        let parser = try XCTUnwrap(Parser(contentsOf: URL(fileURLWithPath: path)))

        let result = try parser.parse()

        XCTAssertEqual(
            result,
            File(
                definitions: [
                    .CoreFoundationType(CoreFoundationType(
                        name: "FooRef",
                        type32: .Pointer(.Struct(StructType(name: "Foo")))
                    ))
                ]
            )
        )
    }

    public func testConstant() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "constant", ofType: "bridgesupport"))
        let parser = try XCTUnwrap(Parser(contentsOf: URL(fileURLWithPath: path)))

        let result = try parser.parse()

        XCTAssertEqual(
            result,
            File(
                definitions: [
                    .Constant(Constant(
                        name: "kFoo",
                        type32: .Pointer(.Int)
                    )),
                    .Constant(Constant(
                        name: "kBar",
                        type32: .Pointer(.Int),
                        isConst: true
                    ))
                ]
            )
        )
    }

    public func testEnum() throws {
        let path = try XCTUnwrap(Bundle.module.path(forResource: "enum", ofType: "bridgesupport"))
        let parser = try XCTUnwrap(Parser(contentsOf: URL(fileURLWithPath: path)))

        let result = try parser.parse()

        XCTAssertEqual(
            result,
            File(
                definitions: [
                    .Enum(Enum(
                        name: "TRUE",
                        value32: "1"
                    ))
                ]
            )
        )
    }

    public func testTypeSingle() throws {
        let tests: [String: Type] = [
            "c": .Char,
            "i": .Int,
            "s": .Short,
            "l": .Long,
            "q": .LongLong,
            "C": .UnsignedChar,
            "I": .UnsignedInt,
            "S": .UnsignedShort,
            "L": .UnsignedLong,
            "Q": .UnsignedLongLong,
            "f": .Float,
            "d": .Double,
            "B": .Bool,
            "v": .Void,
            "@": .ID,
            "#": .Class,
            ":": .Selector,
            "?": .Unknown
        ]

        for (encoded, expectedtType) in tests {
            let type = try Type(encoded: encoded)
            XCTAssertEqual(type, expectedtType)
        }
    }

    public func testTypeBitfieldNoSize() throws {
        XCTAssertThrowsError(try Type(encoded: "b"))
    }

    public func testTypeBitfieldWithSize() throws {
        let type = try Type(encoded: "b2")
        XCTAssertEqual(type, .Bitfield(size: 2))
    }

    public func testTypePointerNoInner() throws {
        XCTAssertThrowsError(try Type(encoded: "^"))
    }

    public func testTypePointerWithInner() throws {
        let type = try Type(encoded: "^i")
        XCTAssertEqual(type, .Pointer(.Int))
    }

    public func testTypeConstNoInner() throws {
        XCTAssertThrowsError(try Type(encoded: "r"))
    }

    public func testTypeConstWithInner() throws {
        let type = try Type(encoded: "ri")
        XCTAssertEqual(type, .Const(.Int))
    }

    public func testTypeArrayNoSize() throws {
        XCTAssertThrowsError(try Type(encoded: "[]"))
    }

    public func testTypeArraySizeNoElement() throws {
        XCTAssertThrowsError(try Type(encoded: "[1]"))
    }

    public func testTypeArraySizeAndElementNoEnd() throws {
        XCTAssertThrowsError(try Type(encoded: "[1i"))
    }

    public func testTypeArraySizeAndElementAndEnd() throws {
        let type = try Type(encoded: "[1i]")
        XCTAssertEqual(type, .Array(ArrayType(size: 1, type: .Int)))
    }

    public func testTypeStructNoSeparator() throws {
        let type = try Type(encoded: "{}")
        XCTAssertEqual(type, .Struct(StructType(name: "")))
    }

    public func testTypeStructOnlySeparator() throws {
        let type = try Type(encoded: "{=}")
        XCTAssertEqual(type, .Struct(StructType(name: "")))
    }

    public func testTypeStructOnlyName() throws {
        let type = try Type(encoded: "{Foo}")
        XCTAssertEqual(type, .Struct(StructType(name: "Foo")))
    }

    public func testTypeStructNameAndFields() throws {
        let type = try Type(encoded: "{Foo=iv}")
        XCTAssertEqual(
            type,
            .Struct(StructType(
                name: "Foo",
                fields: [
                    Field(name: "", type: .Int),
                    Field(name: "", type: .Void)
                ]
            ))
        )
    }

    public func testTypeStructNameAndFieldsWithNames() throws {
        let type = try Type(encoded: "{Foo=\"first\"i\"second\"v}")
        XCTAssertEqual(
            type,
            .Struct(StructType(
                name: "Foo",
                fields: [
                    Field(name: "first", type: .Int),
                    Field(name: "second", type: .Void)
                ]
            ))
        )
    }

    public func testTypeUnionOnlySeparator() throws {
        let type = try Type(encoded: "(=)")
        XCTAssertEqual(type, .Union(UnionType(name: "")))
    }

    public func testTypeUnionOnlyName() throws {
        let type = try Type(encoded: "(Foo)")
        XCTAssertEqual(type, .Union(UnionType(name: "Foo")))
    }

    public func testTypeUnionNameAndFields() throws {
        let type = try Type(encoded: "(Foo=iv)")
        XCTAssertEqual(
            type,
            .Union(UnionType(
                name: "Foo",
                fields: [
                    Field(name: "", type: .Int),
                    Field(name: "", type: .Void)
                ]
            ))
        )
    }

    public func testTypeComplexFloat() throws {
        let type = try Type(encoded: "jf")
        XCTAssertEqual(type, .ComplexFloat)
    }

    public func testTypeComplexDouble() throws {
        let type = try Type(encoded: "jd")
        XCTAssertEqual(type, .ComplexDouble)
    }

    public func testTypeComplexEmpty() throws {
        XCTAssertThrowsError(try Type(encoded: "j"))
    }

    public func testTypeComplexInvalid() throws {
        XCTAssertThrowsError(try Type(encoded: "jv"))
    }

    public func testTypeUnionNameAndFieldsWithNames() throws {
        let type = try Type(encoded: "(Foo=\"first\"i\"second\"v)")
        XCTAssertEqual(
            type,
            .Union(UnionType(
                name: "Foo",
                fields: [
                    Field(name: "first", type: .Int),
                    Field(name: "second", type: .Void)
                ]
            ))
        )
    }
}
