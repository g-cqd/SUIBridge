//
//  BridgeCoordinator.swift
//
//
//  Created by Guillaume Coquard on 26/03/24.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

open class BridgeCoordinator<Root> where Root: Representable.Represented {

    public typealias ViewType = Root
    public typealias Configuration = ViewConfiguration<ViewType>

    public init() {}

    public func compose(_ moment: CycleMoment, configurations: Configuration...) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    public func compose(_ moment: CycleMoment, configurations: [Configuration]) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

}
