//
//  Bridge.swift
//
//
//  Created by Guillaume Coquard on 26/03/24.
//

import Foundation
#if os(iOS)
import UIKit
#endif
import SwiftUI

public struct Bridge<Root>: Representable.ViewRepresentable where Root: Representable.Represented {

    #if os(macOS)
    public typealias NSViewType = Root
    public typealias ViewType =  NSViewType
    #elseif os(iOS)
    public typealias UIViewType = Root
    public typealias ViewType = UIViewType
    #endif
    public typealias Configuration = ViewConfiguration<ViewType>
    public typealias Coordinator = BridgeCoordinator<ViewType>

    private(set) var configurations: [Configuration] = []
    private(set) var view: ViewType?

    public init(_ bridge: Bridge) {
        self.view = bridge.view
        self.configurations = bridge.configurations
    }

    public init(_ view: ViewType, _ configurations: [Configuration]) {
        self.view = view
        self.configurations = configurations
    }

    public init(_ view: ViewType, _ configurations: Configuration...) {
        self.view = view
        self.configurations = configurations
    }

    public init(_ configurations: [Configuration]) {
        self.configurations = configurations
    }

    public init(_ configurations: Configuration...) {
        self.configurations = configurations
    }

    #if os(iOS)
    public func makeUIView(context: Context) -> ViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view, context).0!
    }

    public func updateUIView(_ uiView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(uiView, context)
    }
    #elseif os(macOS)
    public func makeNSView(context: Context) -> ViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view, context).0!
    }

    public func updateNSView(_ nsView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(nsView, context)
    }
    #endif

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
