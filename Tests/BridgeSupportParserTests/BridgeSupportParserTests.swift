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
                            ),
                            Method(
                                selector: "objs",
                                functionType: FunctionType(
                                    arguments: [
                                        Argument(
                                            name: "first",
                                            index: 0,
                                            type32: .ID
                                        )
                                    ]
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
                    )),
                    .Function(Function(
                        name: "objs",
                        functionType: FunctionType(
                            arguments: [
                                Argument(
                                    name: "first",
                                    index: 0,
                                    type32: .ID
                                )
                            ]
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
                        fields: [
                            Field(name: "x"),
                            Field(name: "y")
                        ],
                        type32: StructType(
                            name: "_Point",
                            fields: [
                                Field(name: "x", type32: .Float),
                                Field(name: "y", type32: .Float),
                            ]
                        )
                    )),
                    .Struct(Struct(
                        name: "Foo",
                        fields: [
                            Field(name: "retain", type32: .Pointer(.Unknown))
                        ],
                        type32: StructType(
                            name: "_Foo",
                            fields: [
                                Field(name: "retain", type32: .Pointer(.Unknown))
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
            let type = try Type(encoded: encoded, bitness: .Bit32)
            XCTAssertEqual(type, expectedtType)
        }
    }

    public func testTypeBitfieldNoSize() throws {
        XCTAssertThrowsError(try Type(encoded: "b", bitness: .Bit32))
    }

    public func testTypeBitfieldWithSize() throws {
        let type = try Type(encoded: "b2", bitness: .Bit32)
        XCTAssertEqual(type, .Bitfield(size: 2))
    }

    public func testTypePointerNoInner() throws {
        XCTAssertThrowsError(try Type(encoded: "^", bitness: .Bit32))
    }

    public func testTypePointerWithInner() throws {
        let type = try Type(encoded: "^i", bitness: .Bit32)
        XCTAssertEqual(type, .Pointer(.Int))
    }

    public func testTypeConstNoInner() throws {
        XCTAssertThrowsError(try Type(encoded: "r", bitness: .Bit32))
    }

    public func testTypeConstWithInner() throws {
        let type = try Type(encoded: "ri", bitness: .Bit32)
        XCTAssertEqual(type, .Const(.Int))
    }

    public func testTypeArrayNoSize() throws {
        XCTAssertThrowsError(try Type(encoded: "[]", bitness: .Bit32))
    }

    public func testTypeArraySizeNoElement() throws {
        XCTAssertThrowsError(try Type(encoded: "[1]", bitness: .Bit32))
    }

    public func testTypeArraySizeAndElementNoEnd() throws {
        XCTAssertThrowsError(try Type(encoded: "[1i", bitness: .Bit32))
    }

    public func testTypeArraySizeAndElementAndEnd() throws {
        let type = try Type(encoded: "[1i]", bitness: .Bit32)
        XCTAssertEqual(type, .Array(ArrayType(size: 1, type: .Int)))
    }

    public func testTypeArraySizeAndElementAndNameAndEnd() throws {
        let type = try Type(encoded: "[1@\"Protocol\"]", bitness: .Bit32)
        XCTAssertEqual(type, .Array(ArrayType(size: 1, type: .ID)))
    }

    public func testTypeStructNoSeparator() throws {
        let type = try Type(encoded: "{}", bitness: .Bit32)
        XCTAssertEqual(type, .Struct(StructType(name: "")))
    }

    public func testTypeStructOnlySeparator() throws {
        let type = try Type(encoded: "{=}", bitness: .Bit32)
        XCTAssertEqual(type, .Struct(StructType(name: "")))
    }

    public func testTypeStructOnlyName() throws {
        let type = try Type(encoded: "{Foo}", bitness: .Bit32)
        XCTAssertEqual(type, .Struct(StructType(name: "Foo")))
    }

    public func testTypeStructNameAndFields32Bit() throws {
        let type = try Type(encoded: "{Foo=iv}", bitness: .Bit32)
        XCTAssertEqual(
            type,
            .Struct(StructType(
                name: "Foo",
                fields: [
                    Field(name: "", type32: .Int),
                    Field(name: "", type32: .Void)
                ]
            ))
        )
    }

    public func testTypeStructNameAndFields64Bit() throws {
        let type = try Type(encoded: "{Foo=iv}", bitness: .Bit64)
        XCTAssertEqual(
            type,
            .Struct(StructType(
                name: "Foo",
                fields: [
                    Field(name: "", type64: .Int),
                    Field(name: "", type64: .Void)
                ]
            ))
        )
    }

    public func testTypeStructNameAndFieldsWithNames() throws {
        let type = try Type(encoded: "{Foo=\"first\"i\"second\"v}", bitness: .Bit32)
        XCTAssertEqual(
            type,
            .Struct(StructType(
                name: "Foo",
                fields: [
                    Field(name: "first", type32: .Int),
                    Field(name: "second", type32: .Void)
                ]
            ))
        )
    }

    public func testTypeUnionOnlySeparator() throws {
        let type = try Type(encoded: "(=)", bitness: .Bit32)
        XCTAssertEqual(type, .Union(UnionType(name: "")))
    }

    public func testTypeUnionOnlyName() throws {
        let type = try Type(encoded: "(Foo)", bitness: .Bit32)
        XCTAssertEqual(type, .Union(UnionType(name: "Foo")))
    }

    public func testTypeUnionNameAndFields32Bit() throws {
        let type = try Type(encoded: "(Foo=iv)", bitness: .Bit32)
        XCTAssertEqual(
            type,
            .Union(UnionType(
                name: "Foo",
                fields: [
                    Field(name: "", type32: .Int),
                    Field(name: "", type32: .Void)
                ]
            ))
        )
    }

    public func testTypeUnionNameAndFields64Bit() throws {
        let type = try Type(encoded: "(Foo=iv)", bitness: .Bit64)
        XCTAssertEqual(
            type,
            .Union(UnionType(
                name: "Foo",
                fields: [
                    Field(name: "", type64: .Int),
                    Field(name: "", type64: .Void)
                ]
            ))
        )
    }

    public func testTypeComplexFloat() throws {
        let type = try Type(encoded: "jf", bitness: .Bit32)
        XCTAssertEqual(type, .ComplexFloat)
    }

    public func testTypeComplexDouble() throws {
        let type = try Type(encoded: "jd", bitness: .Bit32)
        XCTAssertEqual(type, .ComplexDouble)
    }

    public func testTypeComplexEmpty() throws {
        XCTAssertThrowsError(try Type(encoded: "j", bitness: .Bit32))
    }

    public func testTypeComplexInvalid() throws {
        XCTAssertThrowsError(try Type(encoded: "jv", bitness: .Bit32))
    }

    public func testTypeUnionNameAndFieldsWithNames() throws {
        let type = try Type(encoded: "(Foo=\"first\"i\"second\"v)", bitness: .Bit32)
        XCTAssertEqual(
            type,
            .Union(UnionType(
                name: "Foo",
                fields: [
                    Field(name: "first", type32: .Int),
                    Field(name: "second", type32: .Void)
                ]
            ))
        )
    }

    public func testTypeBlock() throws {
        let type = try Type(encoded: "@?", bitness: .Bit32)
        XCTAssertEqual(type, .ID)
    }
}
