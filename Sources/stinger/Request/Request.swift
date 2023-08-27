//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 24/07/23.
//
import NIOCore
import NIOHTTP1
import Foundation
@available(macOS 13.0, *)
class Request:CustomStringConvertible{
    var description: String{
        return "\(method.rawValue)->"+uri
    }
    internal enum BodyType:Equatable{
        static func == (lhs: Request.BodyType, rhs: Request.BodyType) -> Bool {
            switch lhs{
            case .json(let body):
                guard case .json(let otherBody) = rhs else{
                    return false
                }
                return body == otherBody
            case .none:
                guard case .none = rhs else{
                    return false
                }
            case .textplain(let body):
                guard case .textplain(let otherBody) = rhs else{
                    return false
                }
                return body == otherBody
            case .formData(let body):
                guard case .formData(let otherBody) = rhs else{
                    return false
                }
                return body == otherBody
            case .media(_):
                guard case .media(_) = rhs else{
                    return false
                }
            }
            return true
        }
        
        case none
        case json(ByteBuffer),textplain(ByteBuffer),formData(ByteBuffer)
        case media(ByteBufferAllocator)
    }
    public var bodyType:BodyType = .none
    public var method:HTTPMethod
    public var uri:String
    public var parameter :[String:String] = [:]
    private var body:Body{
        return Body(self)
    }
    func setBody(body:ByteBuffer){
        let jsonRegex = try! Regex("(\\[|\\{).*(]|\\})")
        let formRegex = try! Regex("[\\s*=\\s*&?]+")
        switch String(buffer:body){
        case let b where b.contains(jsonRegex):
            self.bodyType = .json(body)
        case let b where b.contains(formRegex):
            self.bodyType = .formData(body)
        default:
            self.bodyType = .textplain(body)
        }
    }
    init(method: HTTPMethod, uri: String , body: ByteBuffer? = nil) {
        self.method = method
        self.uri = uri
        if let body = body{
           setBody(body: body)
        }else{
            self.bodyType = .none
        }
    }
    
}

@available(macOS 13.0, *)
extension Request{
    internal class Body:CustomStringConvertible{
        public var data:ByteBuffer?{
            switch self.request.bodyType{
            case .formData(let buffer) , .json(let buffer) , .textplain(let buffer):return buffer
            case .none, .media(_): return nil
            }
            
        }
        var description: String{
            if let data = self.data{
                return String(buffer: data)
            }
            return ""
        }
        var request:Request
        init(_ request: Request) {
            self.request = request
        }
    }
}
