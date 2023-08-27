import NIOCore
import NIOHTTP1

@available(macOS 13.0, *)
public  final class Router:RouterHandler,CustomStringConvertible{
    typealias httpAction = (Request)->Response
    var routes: [NIOHTTP1.HTTPMethod : [Route]]
    
    
    public var description: String{
        get{
            return self.routes.description
        }
    }
    public init() {
        self.routes = [:];
        for method in HTTPMethod.allCases{
            routes[method] = []
        }        
    }    
}
