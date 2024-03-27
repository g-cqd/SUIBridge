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
    func set<Value>(_ path: ReferenceWritableKeyPath<R,Value>, to value: @autoclosure @escaping () -> Value, at step: CycleMoment) -> S
    func set<Value>(_ path: ReferenceWritableKeyPath<R,Value>, to value: @autoclosure @escaping () -> Value, at step: CycleMoment) -> T
}

extension SetModifiableProtocol {
    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self,Value>,
        to value: @autoclosure @escaping () -> Value,
        at step: CycleMoment
    ) -> Self {
        self[keyPath: path] = value()
        return self
    }
}

extension SetModifiableProtocol where R : UIView {

    public typealias T = Transients<R>

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<Self,Value>,
        to value: @autoclosure @escaping () -> Value,
        at step: CycleMoment = .all
    ) -> Transients<Self> {
        .init(self, [
            .init(step) { (view: Self?) in
                view?[keyPath: path] = value()
                return view
            }
        ])
    }
}
