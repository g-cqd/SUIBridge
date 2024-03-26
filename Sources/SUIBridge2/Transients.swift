//
//  Transients.swift
//
//
//  Created by Guillaume Coquard on 26/03/24.
//

import UIKit
import SwiftUI

public struct Transients<Root>: View where Root : UIView {

    public typealias UIViewType = Root
    public typealias Configuration = UIViewConfiguration<UIViewType>
    public typealias Configurations = [Configuration]

    let view: UIViewType
    let configurations: Configurations

    init(_ view: UIViewType, _ configurations: Configurations) {
        self.view = view
        self.configurations = configurations
    }

    @discardableResult
    public func appending(_ configuration: Configuration) -> Self {
        
        var configurations = self.configurations
        configurations.append(configuration)

        return Self(view, configurations)
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<NSObject,Value>,
        to value: Value,
        at step: CycleMoment
    ) -> Self {
        self.appending(
            Configuration(step) { (view: UIViewType?) in
                view?[keyPath: path] = value
                return view
            }
        )
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<UIViewType,Value>,
        to value: @escaping () -> Value,
        at step: CycleMoment
    ) -> Self {
        self.appending(
            Configuration(step) { (view: UIViewType?) in
                view?[keyPath: path] = value()
                return view
            }
        )
    }


    public var body: some View {
        Bridge<UIViewType>(configurations)
    }

}
