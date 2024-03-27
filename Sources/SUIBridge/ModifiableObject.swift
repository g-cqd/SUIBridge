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


public protocol ModifiableObject {
    associatedtype R
    associatedtype S
    associatedtype T
    func set<Value>(_ path: ReferenceWritableKeyPath<R,Value>, to value: @autoclosure @escaping () -> Value, at step: CycleMoment) -> S
    func set<Value>(_ path: ReferenceWritableKeyPath<R,Value>, to value: @autoclosure @escaping () -> Value, at step: CycleMoment) -> T
}

extension ModifiableObject {
    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self,Value>,
        to value: @autoclosure @escaping () -> Value,
        at step: CycleMoment
    ) -> Self {
        self[keyPath: path] = value()
        return self
    }
}

extension ModifiableObject where R : Representable.Represented {

    public typealias T = Bridged<R>

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self,Value>,
        to value: @autoclosure @escaping () -> Value,
        at step: CycleMoment = .all
    ) -> Bridged<Self> {
        .init(self, [
            .init(step) { (view: Self?) in
                view?[keyPath: path] = value()
                return view
            }
        ])
    }
}
