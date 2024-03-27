//
//  BridgeCoordinator.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

import UIKit

open class BridgeCoordinator<Root> where Root : UIView {

    typealias UIViewType = Root
    typealias UIViewRepresentable = Bridge<UIViewType>
    typealias Configuration = UIViewConfiguration<UIViewType>

    var configurations: [Configuration] = []

    init(_ configurations: [Configuration]) {
        self.configurations = configurations
    }

    init(_ configurations: Configuration...) {
        self.configurations = configurations
    }

    func compose(_ moment: CycleMoment) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    func compose(_ moment: CycleMoment, configurations: Configuration...) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    func compose(_ moment: CycleMoment, configurations: [Configuration]) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    @discardableResult
    func configure(_ moment: CycleMoment, _ view: UIViewType? = nil, frame: CGRect? = nil) -> UIViewType? {
        return if let view = view {
            self.compose(moment)(view)
        } else {
            self.compose(moment)(frame != nil ? .init(frame: frame!) : .init())
        }
    }

}
