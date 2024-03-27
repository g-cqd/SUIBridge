//
//  File.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

import Foundation
import UIKit
import SwiftUI

public struct Bridge<Root>: UIViewRepresentable where Root : UIView {

    public typealias UIViewType = Root
    public typealias Configuration = UIViewConfiguration<UIViewType>
    public typealias Coordinator = BridgeCoordinator<UIViewType>

    private(set) var configurations: [Configuration] = []
    private(set) var view: UIViewType?

    init(_ bridge: Bridge) {
        self.view = bridge.view
        self.configurations = bridge.configurations
    }

    init(_ view: UIViewType, _ configurations: [Configuration]) {
        self.view = view
        self.configurations = configurations
    }

    init(_ view: UIViewType, _ configurations: Configuration...) {
        self.view = view
        self.configurations = configurations
    }

    init(_ configurations: [Configuration]) {
        self.configurations = configurations
    }

    init(_ configurations: Configuration...) {
        self.configurations = configurations
    }

    public func makeUIView(context: Context) -> UIViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view)!
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(uiView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self.configurations)
    }
}
