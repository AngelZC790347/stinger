import NIOCore
import NIOHTTP1
class RouterHandler:ChannelInboundHandler, RemovableChannelHandler{
    init() {
        self.routes = Dictionary(uniqueKeysWithValues: HTTPMethod.allCases.map{($0,[:])})
    }
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    typealias RouterCallback = ()->HTTPServerResponsePart
    var routes :[HTTPMethod:[String:RouterCallback]] = [:]
    private var buffer :ByteBuffer!
    func handlerAdded(context: ChannelHandlerContext) {
        self.routes = Dictionary(uniqueKeysWithValues: HTTPMethod.allCases.map{($0,[:])})
    }
    func handlerRemoved(context: ChannelHandlerContext) {
        self.buffer = nil
        self.routes = [:]
    }

    internal func regiterRoute(_ method:HTTPMethod,_ endpoint:String,viewFunc:@escaping RouterCallback){
        if self.routes[method] != nil{
            self.routes[method]?[endpoint] = viewFunc
        }
    }
    internal func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let uData =  self.unwrapInboundIn(data)
        guard case .body(.byteBuffer(let buffer)) = self.proccesRequest(uData) else{
            return
        }
        self.buffer = buffer
        context.write(self.wrapOutboundOut(.body(.byteBuffer(self.buffer))), promise: nil)
        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
            context.close(promise: nil)
        }
        context.flush()
    }
    internal func proccesRequest(_ data:InboundIn) -> HTTPServerResponsePart{
        // proccess de peticion
        guard case .head(let head) = data else{
            // procces from registered routes
            return .head(.init(version: .http1_1, status: .badRequest))
        }
        guard  let route = self.routes[head.method] else{
            return .head(.init(version: .http1_1, status: .methodNotAllowed))            
        }
        return HTTPServerResponsePart.body(.byteBuffer(ByteBuffer(string: "No method")))
    }
}
