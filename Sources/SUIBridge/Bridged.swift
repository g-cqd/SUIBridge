//
//  Bridged.swift
//
//
//  Created by Guillaume Coquard on 26/03/24.
//

#if os(iOS)
import UIKit
#endif
import SwiftUI

public struct Bridged<Root>: View  where Root : Representable.Represented {

    #if os(macOS)
    public typealias NSViewType = Root
    public typealias ViewType =  NSViewType
    #elseif os(iOS)
    public typealias UIViewType = Root
    public typealias ViewType = UIViewType
    #endif
    public typealias Configuration = ViewConfiguration<ViewType>
    public typealias Configurations = [Configuration]

    let view: ViewType
    var configurations: Configurations = []

    init(_ view: ViewType, _ configurations: Configurations) {
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
        _ path: ReferenceWritableKeyPath<ViewType,Value>,
        to value: @autoclosure @escaping () -> Value?,
        at step: CycleMoment = .all
    ) -> Self {
        self.appending(
            Configuration(step) { (view: ViewType?) in
                view?[keyPath: path] = value() ?? view![keyPath: path]
                return view
            }
        )
    }

    public func containing(@SubviewBuilder subviews: () -> Representable.Represented) -> Self {
        self.view.addSubview( subviews() )
        return Self(self.view, self.configurations)
    }

    public var body: some View {
        Bridge<ViewType>(self.view, self.configurations)
    }

}
