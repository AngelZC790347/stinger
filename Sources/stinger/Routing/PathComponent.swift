//
//  File.swift
//  
//
//  Created by Angel Zuñiga on 31/07/23.
//

import Foundation
@available(macOS 13.0, *)
extension String {
    /// Converts a string into `[PathComponent]`.
    public var pathComponents: [PathComponent] {
        return self.split(separator: "/").map { .init(stringLiteral: .init($0)) }
    }
}
@available(macOS 13.0, *)
public enum PathComponent:ExpressibleByStringInterpolation,CustomStringConvertible{
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

@available(macOS 13.0, *)
extension Sequence where Element == PathComponent {
    /// Converts an array of `PathComponent` into a readable path string.
    ///
    ///     galaxies/:galaxyID/planets
    ///
    public var string: String {
        return self.map(\.description).joined(separator: "/")
    }
}

