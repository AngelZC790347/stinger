//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 31/07/23.
//

import Foundation

extension String {
    /// Converts a string into `[PathComponent]`.
    public var pathComponents: [PathComponent] {
        return self.split(separator: "/").map { .init(stringLiteral: .init($0)) }
    }
}

public enum PathComponent:ExpressibleByStringInterpolation,CustomStringConvertible,Hashable{
    case constant(String)
    case parameter(String)
    case anything
    case getAll
    public var description: String{
        get{
            switch self{
            case .constant(let constant):
                return constant
            case .parameter(let parameter):
                return "{\(parameter)}"
            case .anything:
                return "*"
            case .getAll:
                return "**"
            }
        }
    }
    public init(stringLiteral value: StringLiteralType) {
        if value.contains(#/\{.+\}/#){
            self = .parameter(String(value.dropFirst().dropLast()))
        }else if value == "*"{
            self = .anything
        }else if value == "**"{
            self = .getAll
        }else{
            self = .constant(value)
        }
    }
    
}


extension Sequence where Element == PathComponent {
    /// Converts an array of `PathComponent` into a readable path string.
    ///
    ///     galaxies/:galaxyID/planets
    ///
    ///
    public func match(path:[PathComponent]) -> Bool{
        let components = Array(self)
        if path.count != components.count{
            return false
        }
        for (p,c) in zip(path, components) {
            switch c {
            case .constant(let constant):
                if p.description != constant {
                    return false
                }
            default:
                break
            }            
        }
        return true
    }
    public var string: String {
        return self.map(\.description).joined(separator: "/")
    }
}

