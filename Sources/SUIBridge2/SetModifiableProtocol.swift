//
//  File.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

import UIKit
import SwiftUI


public protocol SetModifiableProtocol {
    associatedtype R
    associatedtype S
    associatedtype T
    func set<Value>(_ path: ReferenceWritableKeyPath<R,Value>, to value: Value) -> S
    func set<Value>(_ path: ReferenceWritableKeyPath<R,Value>, to value: Value) -> T
}

extension SetModifiableProtocol {
    public func set<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value>, to value: Value) -> Self {
        self[keyPath: keyPath] = value
        return self
    }
}

extension SetModifiableProtocol where R : UIView {

    public typealias T = Transients<R>

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self,Value>,
        to value: Value,
        at step: CycleMoment = .all
    ) -> Transients<Self> {
        .init(self, [
            Transients<Self>.Configuration(step) { (view: Self?) in
                view?[keyPath: path] = value
                return view
            }
        ])
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self,Value>,
        to value: @escaping () -> Value,
        at step: CycleMoment = .all
    ) -> Transients<Self> {
        .init(self, [
            Transients<Self>.Configuration(step) { (view: Self?) in
                view?[keyPath: path] = value()
                return view
            }
        ])
    }
}
