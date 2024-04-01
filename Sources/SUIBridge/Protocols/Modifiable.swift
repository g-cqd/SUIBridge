//
//  ModifiableObject.swift
//
//
//  Created by Guillaume Coquard on 26/03/24.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

public protocol Modifiable where R: Representable.Represented, S == R, C == Bridge<R>.Context, T == Bridged<R> {

    associatedtype R
    associatedtype T
    associatedtype C
    associatedtype S
    associatedtype G

    func set<Value>(_ path: ReferenceWritableKeyPath<R, Value>, to value: @autoclosure @escaping () -> Value, during step: CycleMoment) -> S

    func set<Value>(_ path: ReferenceWritableKeyPath<R, Value>, to value: @autoclosure @escaping () -> Value, during step: CycleMoment) -> T
    func set<Value>(_ path: ReferenceWritableKeyPath<R, Value>, to value: @escaping (R?, C?, G?) -> Value, during step: CycleMoment) -> T
    func onMake(perform action: @escaping (R?, C?, G?) -> Void) -> T
    func onUpdate(perform action: @escaping (R?, C?, G?) -> Void) -> T
    func perform(_ action: @escaping (R?, C?, G?) -> Void, during step: CycleMoment) -> T
}

extension Modifiable {
    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self, Value>,
        to value: @autoclosure @escaping () -> Value,
        during step: CycleMoment
    ) -> Self {
        self[keyPath: path] = value()
        return self
    }
}

extension Modifiable where R: Representable.Represented {
    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self, Value>,
        to value: @autoclosure @escaping () -> Value,
        during step: CycleMoment = .all
    ) -> Bridged<Self> {
        .init(self, [
            .init(step) { (view: Self?, context: Bridge<Self>.Context?, _) in
                view?[keyPath: path] = value()
                return (view, context)
            }
        ])
    }
    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self, Value>,
        to value: @escaping (Self?, Bridge<Self>.Context?, Bridge<Self>.Storage?) -> Value,
        during step: CycleMoment = .all
    ) -> Bridged<Self> {
        .init(self, [
            .init(step) { (view: Self?, context: Bridge<Self>.Context?, storage: Bridge<Self>.Storage?) in
                view?[keyPath: path] = value(view, context, storage)
                return (view, context)
            }
        ])
    }
}

extension Modifiable where Self: Representable.Represented {
    public func onMake(
        perform action: @escaping (Self?, Bridge<Self>.Context?, Bridge<Self>.Storage?) -> Void
    ) -> Bridged<Self> {
        .init(self, [
            .init(.make) { (view: Self?, context: Bridge<Self>.Context?, storage: Bridge<Self>.Storage?) in
                action(view, context, storage)
                return (view, context)
            }
        ])
    }
    public func onUpdate(
        perform action: @escaping (Self?, Bridge<Self>.Context?, Bridge<Self>.Storage?) -> Void
    ) -> Bridged<Self> {
        .init(self, [
            .init(.update) { (view: Self?, context: Bridge<Self>.Context?, storage: Bridge<Self>.Storage?) in
                action(view, context, storage)
                return (view, context)
            }
        ])
    }
    public func perform(
        _ action: @escaping (Self?, Bridge<Self>.Context?, Bridge<Self>.Storage?) -> Void,
        during step: CycleMoment = .all
    ) -> Bridged<Self> {
        .init(self, [
            .init(step) { (view: Self?, context: Bridge<Self>.Context?, storage: Bridge<Self>.Storage?) in
                action(view, context, storage)
                return (view, context)
            }
        ])
    }
}
