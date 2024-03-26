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

    private func composeConfigurations(_ moment: CycleMoment) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    var makeConfiguration: Configuration {
        composeConfigurations(.make)
    }

    var updateConfiguration: Configuration {
        composeConfigurations(.update)
    }

    @discardableResult
    func configure(_ moment: CycleMoment, _ view: UIViewType? = nil, frame: CGRect? = nil) -> UIViewType? {
        return if let view = view {
            composeConfigurations(moment)(view)
        } else {
            composeConfigurations(moment)(frame != nil ? .init(frame: frame!) : .init())
        }
    }

}
