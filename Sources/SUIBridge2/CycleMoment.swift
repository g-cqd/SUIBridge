//
//  CycleMoment.swift
//
//
//  Created by Guillaume Coquard on 26/03/24.
//

import Foundation

public struct CycleMoment: OptionSet {

    public typealias RawValue = Int

    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static public let make: Self =     .init(rawValue: 1 << 1)
    static public let update: Self =   .init(rawValue: 1 << 2)

    static public let all: Self = [.make,.update]
    static public let none: Self = []

}
