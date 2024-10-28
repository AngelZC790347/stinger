//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 20/08/23.
//

import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1
class ResponseEncoder:ChannelInboundHandler,RemovableChannelHandler{
    public typealias InboundIn = Response
    typealias OutboundOut = HTTPServerResponsePart
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let res = self.unwrapInboundIn(data)             
        var headers = HTTPHeaders()
                headers.add(name: "Content-Type", value: "text/html")
        headers.add(name: "Content-Length", value: String(res.body.readableBytes))
                headers.add(name: "Connection", value: "close")
        var responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1),
                                    status: .ok,
                                    headers: headers)
        guard  .empty !=  res.resposeType else {
            responseHead.status = .notFound
            context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
            context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
                       context.close(promise: nil)
                   }
                   context.flush()
            return
        }
        context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
        context.write(wrapOutboundOut(.body(.byteBuffer(res.body))), promise: nil)
        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
                   context.close(promise: nil)
               }
               context.flush()
    }
}
