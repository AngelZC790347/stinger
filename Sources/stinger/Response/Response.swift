//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 7/08/23.
//

import Foundation
import NIOCore
class Response{
    internal init(resposeType: Response.ResponseType, body: ByteBuffer) {
        self.resposeType = resposeType
        self.body = body
    }
        
    public enum ResponseType{
        case text
        case json
        case file
        case stream
        case empty
    }
    var resposeType:ResponseType
    var body:ByteBuffer
}
