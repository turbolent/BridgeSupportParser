import Foundation
import BridgeSupportParser

guard CommandLine.arguments.count > 1 else {
    fatalError("missing path to bridgesupport file")
}

let bridgesupportFile = CommandLine.arguments[1]

guard let parser = Parser(contentsOf: URL(fileURLWithPath: bridgesupportFile)) else {
    fatalError("failed to create parser for \(bridgesupportFile)")
}

let file = try parser.parse()

debugPrint(file)