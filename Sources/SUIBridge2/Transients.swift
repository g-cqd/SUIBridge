//
//  Transients.swift
//
//
//  Created by Guillaume Coquard on 26/03/24.
//

import UIKit
import SwiftUI

public struct Transients<Root>: View  where Root : UIView {

    public typealias UIViewType = Root
    public typealias Configuration = UIViewConfiguration<UIViewType>
    public typealias Configurations = [Configuration]

    let view: UIViewType
    var configurations: Configurations = []

    init(_ view: UIViewType, _ configurations: Configurations) {
        self.view = view
        self.configurations = configurations
    }

    @discardableResult
    public func appending(_ configuration: Configuration) -> Self {
        var configurations = self.configurations
        configurations.append(configuration)
        return Self(self.view, configurations)
    }

    public func set<Value>(
        _ path: ReferenceWritableKeyPath<UIViewType,Value>,
        to value: @autoclosure @escaping () -> Value?,
        at step: CycleMoment = .all
    ) -> Self {
        self.appending(
            Configuration(step) { (view: UIViewType?) in
                view?[keyPath: path] = value() ?? view![keyPath: path]
                return view
            }
        )
    }

    public func containing(@UISubviewBuilder<UIViewType> subviews: () -> UIViewType) -> Self {
        self.view.addSubview( subviews() )
        return Self(self.view, self.configurations)
    }


    public var body: some View {
        Bridge<UIViewType>(self.view, self.configurations)
    }

}
