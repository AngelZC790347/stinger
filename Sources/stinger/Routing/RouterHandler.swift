//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 31/07/23.
//
import Foundation
import NIOCore
import NIOHTTP1
@available(macOS 13.0, *)


@available(macOS 13.0, *)
internal enum SomeRouter{
    case route(Route)
    case routerHandler(RouterHandler)
}
@available(macOS 13.0, *)
internal protocol RouterHandler{
    typealias httpAction = (Request)->Response
    var routes :[HTTPMethod:[Route]] { get set }
    mutating func add(route:Route)
    mutating func get(_ path:String,_ action:@escaping httpAction)
    mutating func post(_ path:String,_ action:@escaping httpAction)
}
@available(macOS 13.0, *)
extension RouterHandler{
    mutating func add(route:Route){
        routes[route.method]?.append(route)
    }
    mutating func get(_ path:String,_ action:@escaping httpAction){
        add(route: Route(method: .GET, path: path.pathComponents, action: action))
    }
    mutating func post(_ path:String,_ action:@escaping httpAction){
        add(route: Route(method: .POST, path: path.pathComponents,action:action))
    }
}
@available(macOS 13.0, *)
public class Controller:RouterHandler{
    var routes: [NIOHTTP1.HTTPMethod : [Route]]
    init() {
        self.routes = [:]
        for method in HTTPMethod.allCases{
            self.routes[method] = []
        }
    }
}
