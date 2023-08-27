//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 7/08/23.
//

import Foundation
import NIO
import NIOHTTP1
@available(macOS 13.0, *)
class RequestDecoder:ChannelInboundHandler{
    typealias InboundIn = HTTPServerRequestPart
    typealias InboundOut = Request
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {        
        let part = self.unwrapInboundIn(data)
        let req:Request
        guard case .head(let head) = part , head.method == .GET else {
            return
        }
        print(head.method)
        req = Request(method: head.method, uri: head.uri)
        print(req)
        context.fireChannelRead(wrapInboundOut(req))
//        context.writeAndFlush(self.wrapOutboundOut(), promise: <#T##EventLoopPromise<Void>?#>)
//        switch part{
//        case .head(let head):
//            self.req = try? Request(method: head.method, uri: head.uri)
//        case .body(let body):
//            try? self.req?.setBody(body: body)
//        case .end(_):
//            context.pipeline.close(promise: nil)
//        }
//        context.pipeline.writeAndFlush(NIOAny(req), promise: nil)
    }
}
