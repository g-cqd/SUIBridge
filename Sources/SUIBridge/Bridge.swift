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

    public init(_ view: ViewType, _ configurations: [Configuration] = []) {
        self.view = view
        self.configurations = configurations
    }

    public init(_ view: ViewType, _ configurations: Configuration...) {
        self.view = view
        self.configurations = configurations
    }

    public init(_ configurations: [Configuration]) {
        self.view = .init()
        self.configurations = configurations
    }

    public init(_ configurations: Configuration...) {
        self.view = .init()
        self.configurations = configurations
    }

    #if os(iOS)
    public func makeUIView(context: Context) -> ViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view, context).0!
    }

    public func updateUIView(_ uiView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(uiView, context)
    }

    public func dismantleUIView(_ uiView: ViewType, coordinator: Coordinator) {
        coordinator.compose(.dismantle, configurations: self.configurations)(uiView, nil)
    }
    #elseif os(macOS)
    public func makeNSView(context: Context) -> ViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view, context).0!
    }

    public func updateNSView(_ nsView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(nsView, context)
    }

    public func dismantleNSView(_ nsView: ViewType, coordinator: Coordinator) {
        coordinator.compose(.dismantle, configurations: self.configurations)(nsView, nil)
    }
    #endif

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension Bridge {
    @discardableResult
    public func appending(_ configuration: Configuration) -> Self {
        var configurations = self.configurations
        configurations.append(configuration)
        return Self(self.view!, configurations)
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<ViewType, Value>,
        to value: @autoclosure @escaping () -> Value?,
        during step: CycleMoment = .all
    ) -> Self {
        self.appending(
            Configuration(step) { (view: ViewType?, context: Context?) in
                view?[keyPath: path] = value() ?? view![keyPath: path]
                return (view, context)
            }
        )
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<ViewType, Value>,
        to value: @escaping (ViewType?, Context?) -> Value?,
        during step: CycleMoment = .all
    ) -> Self {
        self.appending(
            Configuration(step) { (view: ViewType?, context: Context?) in
                view?[keyPath: path] = value(view, context) ?? view![keyPath: path]
                return (view, context)
            }
        )
    }

    public func onMake(
        perform action: @escaping (ViewType?, Context?) -> Void
    ) -> Self {
        self.appending(
            Configuration(.make) { (view: ViewType?, context: Context?) in
                action(view, context)
                return (view, context)
            }
        )
    }

    public func onUpdate(
        perform action: @escaping (ViewType?, Context?) -> Void
    ) -> Self {
        self.appending(
            Configuration(.update) { (view: ViewType?, context: Context?) in
                action(view, context)
                return (view, context)
            }
        )
    }

    public func onDismantle(
        perform action: @escaping (ViewType?, Context?) -> Void
    ) -> Self {
        self.appending(
            Configuration(.dismantle) { (view: ViewType?, context: Context?) in
                action(view, context)
                return (view, context)
            }
        )
    }

    public func perform(
        _ action: @escaping (ViewType?, Context?) -> Void,
        during step: CycleMoment = .all
    ) -> Self {
        self.appending(
            Configuration(step) { (view: ViewType?, context: Context?) in
                action(view, context)
                return (view, context)
            }
        )
    }

    public func containing(@SubviewBuilder subview: () -> Representable.Represented) -> Self {
        self.view!.addSubview( subview() )
        return Self(self.view!, self.configurations)
    }
}
