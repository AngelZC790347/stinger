//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 31/07/23.
//

import Foundation
import NIOHTTP1

public final class Route:Hashable{
    public static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.path.string == rhs.path.string
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path.string)
    }
    internal init(method: HTTPMethod, path: [PathComponent], routerHandler: RouterHandler? = nil) {
        self.method = method
        self.path = path
        for p in path{
            switch p{
            case .parameter(let param):
                print("paraneter ",param)            
            default:
                print(p.self)
            }
        }
        self.routerHandler = routerHandler
    }
    internal convenience init(method: HTTPMethod, path: [PathComponent], action:@escaping httpAction) {
        self.init(method: method, path: path)
        self._action = action
//        self.response = action(self.request)
    }
    let method:HTTPMethod
//    var request:Request? = nil
//    var response:Response? = nil
    let path:[PathComponent]
    typealias httpAction = (Request)->Response
    internal let routerHandler:RouterHandler?
    internal var _action:httpAction?
}
