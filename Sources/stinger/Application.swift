//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 18/08/23.
//

import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1


public struct ApplicationConfiguration{
    enum Addr{
        case Bind(host:String,port:Int)
        case Port(Int)
        case unixDomain
    }
    let addr:Addr
}

class Application:Router{
      
    var config:ApplicationConfiguration?
    override init() {
        super.init()
    }
    func listen(config: ApplicationConfiguration) throws{
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let boostrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value:1)
            .childChannelInitializer { channel in
                let config: NIOHTTPServerUpgradeConfiguration = (
                                        upgraders: [ ],
                                        completionHandler: { _ in
                                            
                                        }
                                    )
                        return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config).flatMap {
                            channel.pipeline.addHandlers([RequestDecoder(),RoutingHandler(app: self),ResponseEncoder()])
                        }
                
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value:  16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
        guard case .Bind(host: let host, port: let port) = config.addr else{
            return
        }
        let channel = try! boostrap.bind(host: host, port: port).wait()
        print("Listenning on port \(port)")
        try! channel.closeFuture.wait()
        print("Server Closed")
    }
        
}

enum ApplicationError:Error{
    case ApplicationInitializacionError
}
