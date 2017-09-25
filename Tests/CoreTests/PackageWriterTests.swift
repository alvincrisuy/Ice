//
//  PackageWriterTests.swift
//  TransformersTests
//
//  Created by Jake Heiser on 9/24/17.
//

import XCTest
import SwiftCLI
@testable import Core

class PackageWriterTests: XCTestCase {
    
    func testProducts() {
        let products: [Package.Product] = [
            .init(name: "exec", product_type: "executable", targets: ["MyLib"], type: nil),
            .init(name: "Lib", product_type: "library", targets: ["Core"], type: nil),
            .init(name: "Static", product_type: "library", targets: ["MyLib"], type: "static"),
            .init(name: "Dynamic", product_type: "library", targets: ["Core"], type: "dynamic")
        ]
        
        let capture = CaptureStream()
        let writer = try! PackageWriter(stream: capture)
        writer.writeProducts(products)
        XCTAssertEqual(capture.content, """
            products: [
                .executable(name: "exec", targets: ["MyLib"]),
                .library(name: "Lib", targets: ["Core"]),
                .library(name: "Static", type: .static, targets: ["MyLib"]),
                .library(name: "Dynamic", type: .dynamic, targets: ["Core"]),
            ],

        """)
    }
    
    func testDependencies() {
        let dependencies: [Package.Dependency] = [
            .init(
                url: "https://github.com/jakeheis/SwiftCLI",
                requirement: .init(
                    type: "branch",
                    lowerBound: nil,
                    upperBound: nil,
                    identifier: "swift4"
                )
            ),
            .init(
                url: "https://github.com/jakeheis/Spawn",
                requirement: .init(
                    type: "exact",
                    lowerBound: nil,
                    upperBound: nil,
                    identifier: "0.0.4"
                )
            ),
            .init(
                url: "https://github.com/jakeheis/Flock",
                requirement: .init(
                    type: "revision",
                    lowerBound: nil,
                    upperBound: nil,
                    identifier: "c57454ce053821d2fef8ad25d8918ae83506810c"
                )
            ),
            .init(
                url: "https://github.com/jakeheis/FlockCLI",
                requirement: .init(
                    type: "range",
                    lowerBound: "4.1.0",
                    upperBound: "5.0.0",
                    identifier: nil
                )
            ),
            .init(
                url: "https://github.com/jakeheis/FileKit",
                requirement: .init(
                    type: "range",
                    lowerBound: "2.1.3",
                    upperBound: "2.2.0",
                    identifier: nil
                )
            ),
            .init(
                url: "https://github.com/jakeheis/Shout",
                requirement: .init(
                    type: "range",
                    lowerBound: "0.6.4",
                    upperBound: "0.6.8",
                    identifier: nil
                )
            )
        ]
        
        let capture = CaptureStream()
        let writer = try! PackageWriter(stream: capture)
        writer.writeDependencies(dependencies)
        XCTAssertEqual(capture.content, """
            dependencies: [
                .package(url: "https://github.com/jakeheis/SwiftCLI", .branchItem("swift4")),
                .package(url: "https://github.com/jakeheis/Spawn", .exact("0.0.4")),
                .package(url: "https://github.com/jakeheis/Flock", .revision("c57454ce053821d2fef8ad25d8918ae83506810c")),
                .package(url: "https://github.com/jakeheis/FlockCLI", from: "4.1.0"),
                .package(url: "https://github.com/jakeheis/FileKit", .upToNextMinor(from: "2.1.3")),
                .package(url: "https://github.com/jakeheis/Shout", "0.6.4"..<"0.6.8"),
            ],

        """)
    }
    
    func testTargets() {
        let targets: [Package.Target] = [
            .init(name: "CLI", isTest: false, dependencies: [
                .init(name: "Core")
            ], path: nil, exclude: [], sources: nil, publicHeadersPath: nil),
            .init(name: "CLITests", isTest: true, dependencies: [
                .init(name: "CLI"),
                .init(name: "Core")
            ], path: nil, exclude: [], sources: nil, publicHeadersPath: nil),
            .init(name: "Other", isTest: false, dependencies: [
                .init(name: "Core")
                ], path: "Sources/Diff", exclude: ["ignore.swift"], sources: nil, publicHeadersPath: nil),
            .init(name: "Exclusive", isTest: false, dependencies: [
                .init(name: "Other")
            ], path: nil, exclude: [], sources: ["only.swift"], publicHeadersPath: "headers.h")
        ]
        let capture = CaptureStream()
        let writer = try! PackageWriter(stream: capture)
        writer.writeTargets(targets)
        XCTAssertEqual(capture.content, """
            targets: [
                .target(name: "CLI", dependencies: ["Core"]),
                .testTarget(name: "CLITests", dependencies: ["CLI", "Core"]),
                .target(name: "Other", dependencies: ["Core"], path: "Sources/Diff", exclude: ["ignore.swift"]),
                .target(name: "Exclusive", dependencies: ["Other"], sources: ["only.swift"], publicHeadersPath: "headers.h"),
            ]

        """)
    }
    
}
