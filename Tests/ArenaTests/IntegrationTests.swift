//
//  IntegrationTests.swift
//  ArenaTests
//
//  Created by Sven A. Schmidt on 02/03/2020.
//

@testable import ArenaCore
import XCTest


class IntegrationTests: XCTestCase {
    
    #if swift(>=5.2)
    func test_ArenaTest() throws {
        try XCTSkipUnless(ProcessInfo().hostName == "luna.local", "fails on CI, only run locally")

        let output = OutputListener()
        output.openConsolePipe()
        
        let arena = try Arena.parse([
            "https://github.com/finestructure/ArenaTest@0.0.3",
            "--name=ArenaIntegrationTest",
            "--force",
            "--skip-open"])
        try arena.run()
        
        let expectation = """
                🔧  resolving package dependencies
                📔  libraries found: ArenaTest
                🔨  building package dependencies
                ✅  created project in folder '../../tmp/ArenaIntegrationTest'
                Run
                  open ../../tmp/ArenaIntegrationTest/ArenaIntegrationTest.xcworkspace
                to open the project in Xcode

                """
        let predicate = NSPredicate { _,_  in
            output.contents == expectation
        }
        let exp = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        wait(for: [exp], timeout: 10)
        XCTAssertEqual(output.contents, expectation)
        
        output.closeConsolePipe()
    }
    #endif
    
}

