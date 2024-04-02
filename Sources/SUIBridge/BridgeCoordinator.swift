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

open class BridgeCoordinator<Root>: NSObject where Root: Representable.Represented {

    public typealias ViewType = Root
    public typealias Configuration = ViewConfiguration<ViewType>

    public var root: Bridge<ViewType>

    public init(_ root: Bridge<ViewType>) {
        self.root = root
        super.init()
    }

    public func compose(_ moment: CycleMoment, configurations: Configuration...) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    public func compose(_ moment: CycleMoment, configurations: [Configuration]) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

}
