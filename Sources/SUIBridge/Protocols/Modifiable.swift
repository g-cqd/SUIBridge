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

public protocol Modifiable where R: Representable.Represented, S == R, C == Bridge<R>.Context, T == Bridge<R> {

    associatedtype R
    associatedtype T
    associatedtype C
    associatedtype S

    func set<Value>(_ path: ReferenceWritableKeyPath<R, Value>, to value: @autoclosure @escaping () -> Value, during step: CycleMoment) -> S

    func set<Value>(_ path: ReferenceWritableKeyPath<R, Value>, to value: @autoclosure @escaping () -> Value, during step: CycleMoment) -> T
    func set<Value>(_ path: ReferenceWritableKeyPath<R, Value>, to value: @escaping (R?, C?) -> Value, during step: CycleMoment) -> T
    func onMake(perform action: @escaping (R?, C?) -> Void) -> T
    func onUpdate(perform action: @escaping (R?, C?) -> Void) -> T
    func onDismantle(perform action: @escaping (R?, C?) -> Void) -> T
    func perform(_ action: @escaping (R?, C?) -> Void, during step: CycleMoment) -> T
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
    ) -> Bridge<Self> {
        .init(self, [
            .init(step) { (view: Self?, context: Bridge<Self>.Context?) in
                view?[keyPath: path] = value()
                return (view, context)
            }
        ])
    }
    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self, Value>,
        to value: @escaping (Self?, Bridge<Self>.Context?) -> Value,
        during step: CycleMoment = .all
    ) -> Bridge<Self> {
        .init(self, [
            .init(step) { (view: Self?, context: Bridge<Self>.Context?) in
                view?[keyPath: path] = value(view, context)
                return (view, context)
            }
        ])
    }
}

extension Modifiable where Self: Representable.Represented {
    public func onMake(
        perform action: @escaping (Self?, Bridge<Self>.Context?) -> Void
    ) -> Bridge<Self> {
        .init(self, [
            .init(.make) { (view: Self?, context: Bridge<Self>.Context?) in
                action(view, context)
                return (view, context)
            }
        ])
    }
    public func onUpdate(
        perform action: @escaping (Self?, Bridge<Self>.Context?) -> Void
    ) -> Bridge<Self> {
        .init(self, [
            .init(.update) { (view: Self?, context: Bridge<Self>.Context?) in
                action(view, context)
                return (view, context)
            }
        ])
    }
    public func onDismantle(
        perform action: @escaping (Self?, Bridge<Self>.Context?) -> Void
    ) -> Bridge<Self> {
        .init(self, [
            .init(.dismantle) { (view: Self?, context: Bridge<Self>.Context?) in
                action(view, context)
                return (view, context)
            }
        ])
    }

    public func perform(
        _ action: @escaping (Self?, Bridge<Self>.Context?) -> Void,
        during step: CycleMoment = .all
    ) -> Bridge<Self> {
        .init(self, [
            .init(step) { (view: Self?, context: Bridge<Self>.Context?) in
                action(view, context)
                return (view, context)
            }
        ])
    }
}
