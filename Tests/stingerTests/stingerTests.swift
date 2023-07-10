import XCTest

@testable import stinger

//class MyChannel : Channel{
//
//}

final class stingerTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        var p = ChannelPipeline(channel: MyChannel())
//         let future = p.add(name: "1", handler: InboundHandlerA()).flatMap {
//           p.add(name: "2", handler: InboundHandlerB())
//         }.flatMap {
//           p.add(name: "3", handler: OutboundHandlerA())
//         }.flatMap {
//           p.add(name: "4", handler: OutboundHandlerB())
//         }.flatMap {
//           p.add(name: "5", handler: InboundOutboundHandlerX())
//         }
        XCTAssertEqual(stinger().text, "Hello, World!")
    }
}
