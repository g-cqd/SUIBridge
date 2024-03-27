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


public struct Bridge<Root>: Representable.ViewRepresentable where Root : Representable.Represented {

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

    init(_ bridge: Bridge) {
        self.view = bridge.view
        self.configurations = bridge.configurations
    }

    init(_ view: ViewType, _ configurations: [Configuration]) {
        self.view = view
        self.configurations = configurations
    }

    init(_ view: ViewType, _ configurations: Configuration...) {
        self.view = view
        self.configurations = configurations
    }

    init(_ configurations: [Configuration]) {
        self.configurations = configurations
    }

    init(_ configurations: Configuration...) {
        self.configurations = configurations
    }

    #if os(iOS)
    public func makeUIView(context: Context) -> ViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view)!
    }

    public func updateUIView(_ uiView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(uiView)
    }
    #elseif os(macOS)
    public func makeNSView(context: Context) -> ViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view)!
    }

    public func updateNSView(_ nsView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(nsView)
    }
    #endif

    public func makeCoordinator() -> Coordinator {
        Coordinator(self.configurations)
    }
}
