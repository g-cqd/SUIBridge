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
    public typealias Storage = [AnyHashable: Any?]

    private(set) var configurations: [Configuration] = []
    private(set) var view: ViewType?
    public var storage: Storage = [:]

    public init(_ bridge: Bridge) {
        self.view = bridge.view
        self.configurations = bridge.configurations
    }

    public init(_ view: ViewType, _ configurations: [Configuration] = [], _ storage: Storage = [:]) {
        self.view = view
        self.configurations = configurations
        self.storage = storage
    }

    public init(_ view: ViewType, _ configurations: Configuration..., storage: Storage = [:]) {
        self.view = view
        self.configurations = configurations
        self.storage = storage
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
        context.coordinator.compose(.make, configurations: self.configurations)(self.view, context, self.storage).0!
    }

    public func updateUIView(_ uiView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(uiView, context, self.storage)
    }
    #elseif os(macOS)
    public func makeNSView(context: Context) -> ViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view, context, self.storage).0!
    }

    public func updateNSView(_ nsView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(nsView, context, self.storage)
    }
    #endif

    public func makeCoordinator() -> Coordinator {
        Coordinator()
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
            Configuration(step) { (view: ViewType?, context: Context?, _) in
                view?[keyPath: path] = value() ?? view![keyPath: path]
                return (view, context)
            }
        )
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<ViewType, Value>,
        to value: @escaping (ViewType?, Context?, Storage?) -> Value?,
        during step: CycleMoment = .all
    ) -> Self {
        self.appending(
            Configuration(step) { (view: ViewType?, context: Context?, storage: Storage?) in
                view?[keyPath: path] = value(view, context, storage) ?? view![keyPath: path]
                return (view, context)
            }
        )
    }

    public func onMake(
        perform action: @escaping (ViewType?, Context?, Storage?) -> Void
    ) -> Self {
        self.appending(
            Configuration(.make) { (view: ViewType?, context: Context?, storage: Storage?) in
                action(view, context, storage)
                return (view, context)
            }
        )
    }

    public func onUpdate(
        perform action: @escaping (ViewType?, Context?, Storage?) -> Void
    ) -> Self {
        self.appending(
            Configuration(.update) { (view: ViewType?, context: Context?, storage: Storage?) in
                action(view, context, storage)
                return (view, context)
            }
        )
    }

    public func perform(
        _ action: @escaping (ViewType?, Context?, Storage?) -> Void,
        during step: CycleMoment = .all
    ) -> Self {
        self.appending(
            Configuration(step) { (view: ViewType?, context: Context?, storage: Storage?) in
                action(view, context, storage)
                return (view, context)
            }
        )
    }

    public func containing(@SubviewBuilder subview: () -> Representable.Represented) -> Self {
        self.view!.addSubview( subview() )
        return Self(self.view!, self.configurations)
    }
}
