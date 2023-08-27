//import NIOCore
//import NIOPosix
//import NIOHTTP1
//import NIOWebSocket
//import Foundation
//
//class CommonServer{
//    private var backlog:Int?
//    enum BindAddress {
//        case hostname(_ hostname:String?,_ port:Int?)
//        case unixDomainSocket(path:String)
//    }
//}
//
//class HTTPServer:CommonServer{
//    private static let defaultHostname:String = "127.0.0.1"
//    private static let defaultPort:Int = 5000
//    private let uri:String?
//    private var address:BindAddress
//    private var backlog:Int?    
//    public var hostname:String{
//        get{
//            switch address{
//            case .hostname(let host, _):
//                return host ?? Self.defaultHostname
//            default:
//                return Self.defaultHostname
//            }
//        }
//    }
//    public var port:Int{
//        get{
//            switch address{
//            case.hostname(_,let port):
//                return port ?? Self.defaultPort
//            default:
//                return Self.defaultPort
//            }
//        }
//    }
//    
//}
