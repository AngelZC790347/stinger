////
////  File.swift
////  
////
////  Created by Angel Zuñiga on 29/07/23.
////
import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1

extension String {
    func chopPrefix(_ prefix: String) -> String? {
        if self.unicodeScalars.starts(with: prefix.unicodeScalars) {
            return String(self[self.index(self.startIndex, offsetBy: prefix.count)...])
        } else {
            return nil
        }
    }

    func containsDotDot() -> Bool {
        for idx in self.indices {
            if self[idx] == "." && idx < self.index(before: self.endIndex) && self[self.index(after: idx)] == "." {
                return true
            }
        }
        return false
    }
}

private func httpResponseHead(request: HTTPRequestHead, status: HTTPResponseStatus, headers: HTTPHeaders = HTTPHeaders()) -> HTTPResponseHead {
    var head = HTTPResponseHead(version: request.version, status: status, headers: headers)
    let connectionHeaders: [String] = head.headers[canonicalForm: "connection"].map { $0.lowercased() }

    if !connectionHeaders.contains("keep-alive") && !connectionHeaders.contains("close") {
        // the user hasn't pre-set either 'keep-alive' or 'close', so we might need to add headers

        switch (request.isKeepAlive, request.version.major, request.version.minor) {
        case (true, 1, 0):
            // HTTP/1.0 and the request has 'Connection: keep-alive', we should mirror that
            head.headers.add(name: "Connection", value: "keep-alive")
        case (false, 1, let n) where n >= 1:
            // HTTP/1.1 (or treated as such) and the request has 'Connection: close', we should mirror that
            head.headers.add(name: "Connection", value: "close")
        default:
            // we should match the default or are dealing with some HTTP that we don't support, let's leave as is
            ()
        }
    }
    return head
}


final class RoutingHandler: ChannelInboundHandler {
    public typealias InboundIn = Request
    public typealias InboundOut = Response
    
    let app:Application
    init(app: Application) {
        self.app = app
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let req = self.unwrapInboundIn(data)        
        let route = app.getRouteByRequest(req)
        guard let action = route?._action else {
            context.fireChannelRead(self.wrapInboundOut(Response(resposeType:.empty,body: .init(string: "Not Found") )))
            return
        }
        context.fireChannelRead(self.wrapInboundOut(action(req)))
    }
}


extension Router {
    func getRouteByRequest(_ req: Request) -> Route? {
        let route =  self.routes[req.method]?.first(where: { route in
//            print("seq: \(req.uri) \(route.path.string)")
            return route.path.match(path: req.uri.pathComponents)
        })
        if (route != nil){
            for p in route!.path {
                switch p{
                case.parameter(let param):
                    req.parameter[param] = req.uri.pathComponents[(route?.path.firstIndex(of: p))!].description
                default:
                    break
                }
            }
            return route
        }
        let nextUri = req.uri.pathComponents[0]
        guard let router = self.routers[nextUri] else{
            return nil
        }
        let newUri = "/"+Array(req.uri.pathComponents[1..<req.uri.pathComponents.count]).string
        let newReq = Request(method: req.method, uri: newUri, body: req.body.data)
        return router.getRouteByRequest(newReq)
    }
}
