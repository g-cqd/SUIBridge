//
//  TransientConfigurations.swift
//
//
//  Created by Guillaume Coquard on 26/03/24.
//

import UIKit
import SwiftUI

public struct TransientConfigurations<T> {

    public typealias Configuration = UIViewConfiguration<T>
    public typealias Configurations = [Configuration]

    let viewType: T.Type
    let configurations: Configurations

    init(_ viewType: T.Type, _ configurations: Configurations) {
        self.viewType = viewType
        self.configurations = configurations
    }

    @discardableResult
    public func appending(_ configuration: Configuration) -> Self {
        
        var configurations = self.configurations
        configurations.append(configuration)

        return Self(viewType, configurations)
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: Value,
        at step: CycleMoment
    ) -> Self {
        self.appending(
            Configuration(step) { (view: T?) in
                view?[keyPath: path] = value
                return view
            }
        )
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: @escaping () -> Value,
        at step: CycleMoment
    ) -> Self {
        self.appending(
            Configuration(step) { (view: T?) in
                view?[keyPath: path] = value()
                return view
            }
        )
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: Value,
        at step: CycleMoment
    ) -> Bridge<T> {
        var configurations = self.configurations
        configurations.append(
            Configuration(step) { (view: T?) in
                view?[keyPath: path] = value
                return view
            }
        )
        return Bridge<T>(configurations)
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<T,Value>,
        to value: @escaping () -> Value,
        at step: CycleMoment
    ) -> Bridge<T> {
        var configurations = self.configurations
        configurations.append(
            Configuration(step) { (view: T?) in
                view?[keyPath: path] = value()
                return view
            }
        )
        return Bridge<T>(configurations)
    }

}
