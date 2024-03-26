//
//  File.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

import UIKit
import SwiftUI

extension UIView {

    public func set<T,Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: Value,
        at step: CycleMoment = .all
    ) -> TransientConfigurations<T> where T : UIView {
        .init(T.self, [
            UIViewConfiguration<T>(step) { (view: T?) in
                view?[keyPath: path] = value
                return view
            }
        ])
    }

    public func set<T,Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: @escaping () -> Value,
        at step: CycleMoment = .all
    ) -> TransientConfigurations<T> where T : UIView {
        .init(T.self, [
            UIViewConfiguration<T>(step) { (view: T?) in
                view?[keyPath: path] = value()
                return view
            }
        ])
    }

    public func set<T,Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: Value,
        at step: CycleMoment = .all
    ) -> Bridge<T> where T : UIView {
        .init(
            UIViewConfiguration<T>(step) { (view: T?) in
                view?[keyPath: path] = value
                return view
            }
        )
    }

    public func set<T,Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: @escaping () -> Value,
        at step: CycleMoment = .all
    ) -> Bridge<T> where T : UIView {
        .init(
            UIViewConfiguration<T>(step) { (view: T?) in
                view?[keyPath: path] = value()
                return view
            }
        )
    }
}
