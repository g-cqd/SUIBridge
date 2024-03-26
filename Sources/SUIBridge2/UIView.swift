//
//  File.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

import UIKit
import SwiftUI


public protocol SetModifiable {
    associatedtype T
    associatedtype U
    func set<Value>(_ path: ReferenceWritableKeyPath<T,Value>, to value: Value) -> U
}

extension SetModifiable where T : UIView, T == Self {

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: Value,
        at step: CycleMoment = .all
    ) -> Transients<T> {
        .init(self, [
            Bridge<T>.Configuration(step) { (view: T?) in
                view?[keyPath: path] = value
                return view
            }
        ])
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: @escaping () -> Value,
        at step: CycleMoment = .all
    ) -> Transients<T> {
        .init(self, [
            Bridge<T>.Configuration(step) { (view: T?) in
                view?[keyPath: path] = value()
                return view
            }
        ])
    }
}
