import XCTest

@testable import stinger

//class MyChannel : Channel{
//
//}

@available(macOS 13.0, *)
final class stingerTests: XCTestCase {
    func testExample() throws {
                    
        if #available(macOS 13.0, *) {
//            XCTAssertEqual(stinger().text, "Hello, World!")
        } else {
            // Fallback on earlier versions
        }
    }
    func testReuestBodyConverter() throws{
        let request = try! Request(method: .POST, uri: "/users")
        try? request.setBody(body: .init(string: """
{
"username":"Angel790347",
"email":"angel1200z@hotmail.com",
"password":"angel7903"
}
"""))
        print(request.bodyType)
        XCTAssertEqual(request.bodyType,Request.BodyType.formData(.init(string:"""
{
"username":"Angel790347",
"email":"angel1200z@hotmail.com",
"password":"angel7903"
}
""" )))
    }
}
