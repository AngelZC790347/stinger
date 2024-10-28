import NIOCore
import NIOHTTP1

public  class Router:RouterHandler,CustomStringConvertible{
    typealias httpAction = (Request)->Response
    var routes: [NIOHTTP1.HTTPMethod : [Route]]
    var routers:[PathComponent:Router]
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
        self.routers = [:]
    }
    public func use(_ uri:String,router:Router){        
        self.routers[uri.pathComponents[0]]=router
    }
}
