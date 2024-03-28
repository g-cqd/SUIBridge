//
//  BridgeCoordinator.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import SwiftUI
#endif

open class BridgeCoordinator<Root> where Root : Representable.Represented {

    public typealias ViewType = Root
    public typealias Configuration = ViewConfiguration<ViewType>

    var configurations: [Configuration] = []

    public init(_ configurations: [Configuration]) {
        self.configurations = configurations
    }

    public init(_ configurations: Configuration...) {
        self.configurations = configurations
    }

    public func compose(_ moment: CycleMoment) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    public func compose(_ moment: CycleMoment, configurations: Configuration...) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    public func compose(_ moment: CycleMoment, configurations: [Configuration]) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    @discardableResult
    public func configure(_ moment: CycleMoment, _ view: ViewType? = nil, frame: CGRect? = nil) -> ViewType? {
        return if let view = view {
            self.compose(moment)(view)
        } else {
            self.compose(moment)(frame != nil ? .init(frame: frame!) : .init())
        }
    }

}
