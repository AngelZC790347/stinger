import NIOCore
import NIOPosix
import NIOHTTP1
import NIOWebSocket
import Foundation

class HTTPServer{
	internal init(_ serverConfiguration:(host:String,port:Int) = ("0.0.0.0",8888)) {        
		self._agroupThreads = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.configuration = serverConfiguration            
		self._nativeServer = ServerBootstrap(group: self._agroupThreads)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1).childChannelInitializer { channel in
    			let httpHandler = RouterHandler()
        		let config: NIOHTTPServerUpgradeConfiguration = (
                	upgraders: [  ],
                	completionHandler: { _ in
            		channel.pipeline.removeHandler(httpHandler, promise: nil)
                 })
		        return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config).flatMap {
                    channel.pipeline.addHandler(httpHandler)
                }
    		}.childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)    		
	}
	let _nativeServer : ServerBootstrap
    let _agroupThreads :MultiThreadedEventLoopGroup
    let configuration :(host: String,port:Int)
	func listen(){		
		// let upgrader = NIOWebSocketServerUpgrader(shouldUpgrade: { (channel: Channel, head: HTTPRequestHead) in channel.eventLoop.makeSucceededFuture(HTTPHeaders()) },
        //              upgradePipelineHandler: { (channel: Channel, _: HTTPRequestHead) in channel.pipeline.addHandler(WebSocketTimeHandler())})
  		let channel = try! { () -> Channel in                        
            return try self._nativeServer.bind(host: self.configuration.host, port: self.configuration.port).wait()        
        }()
		defer {
            try! self._agroupThreads.syncShutdownGracefully()
        }   
        guard let localAddress = channel.localAddress else {
            fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
        }
        print("Server started and listening on \(localAddress)")
        try! channel.closeFuture.wait()
        print("Closed de server. ....")
	}
}



let websocketResponse = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Swift NIO WebSocket Test Page</title>
    <script>
        var wsconnection = new WebSocket("ws://localhost:8888/websocket");
        wsconnection.onmessage = function (msg) {
            var element = document.createElement("p");
            element.innerHTML = msg.data;

            var textDiv = document.getElementById("websocket-stream");
            textDiv.insertBefore(element, null);
        };
    </script>
  </head>
  <body>
    <h1>WebSocket Stream</h1>
    <div id="websocket-stream"></div>
  </body>
</html>
"""




private final class HTTPHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart    
    private var responseBody: ByteBuffer! 
    func handlerAdded(context: ChannelHandlerContext) {
        self.responseBody = context.channel.allocator.buffer(string: websocketResponse)
    }
    
    func handlerRemoved(context: ChannelHandlerContext) {
        self.responseBody = nil
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let reqPart = self.unwrapInboundIn(data)

        // We're not interested in request bodies here: we're just serving up GET responses
        // to get the client to initiate a websocket request.
        guard case .head(let head) = reqPart else {
            return
        }

        // GETs only.
        guard case .GET = head.method else {
            self.respond405(context: context)
            return
        }
        print(reqPart)
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "text/html")
        headers.add(name: "Content-Length", value: String(self.responseBody.readableBytes))
        headers.add(name: "Connection", value: "close")
        let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1),
                                    status: .ok,
                                    headers: headers)
        context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
        context.write(self.wrapOutboundOut(.body(.byteBuffer(self.responseBody))), promise: nil)
        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
            context.close(promise: nil)
        }
        context.flush()
    }

    private func respond405(context: ChannelHandlerContext) {
        var headers = HTTPHeaders()
        headers.add(name: "Connection", value: "close")
        headers.add(name: "Content-Length", value: "0")
        let head = HTTPResponseHead(version: .http1_1,
                                    status: .methodNotAllowed,
                                    headers: headers)
        context.write(self.wrapOutboundOut(.head(head)), promise: nil)
        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
            context.close(promise: nil)
        }
        context.flush()
    }
}
