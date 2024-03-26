//
//  File.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

import Foundation
import UIKit
import SwiftUI

public final class Bridge<Root>: UIViewRepresentable where Root : UIView {

    public typealias UIViewType = Root
    public typealias Coordinator = BridgeCoordinator<Root>
    public typealias `Self` = Bridge<Root>
    public typealias Configuration = UIViewConfiguration<UIViewType>

    private(set) var configurations: [Configuration] = []

    init(_ configurations: [Configuration]) {
        self.configurations = configurations
    }

    init(_ configurations: Configuration...) {
        self.configurations = configurations
    }

    public func makeUIView(context: Context) -> UIViewType {
        context.coordinator.configure(.make)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.configure(.update, uiView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self.configurations)
    }

    static func initialize(_ bridge: `Self`? = nil, configurations: [Configuration]...) -> Self {
        if let bridge = bridge {
            return bridge
        } else {
            return `Self`(configurations.flatMap { $0 })
        }
    }


}
