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
    public typealias Configuration = UIViewConfiguration<UIViewType>
    public typealias Coordinator = BridgeCoordinator<UIViewType>

    private(set) var configurations: [Configuration] = []
    private(set) var view: UIViewType?

    init(_ bridge: Bridge) {
        self.view = bridge.view
        self.configurations = bridge.configurations
    }

    init(_ configurations: [Configuration]) {
        self.configurations = configurations
    }

    init(_ configurations: Configuration...) {
        self.configurations = configurations
    }

    public func makeUIView(context: Context) -> UIViewType {
        context.coordinator.configure(.make, self.view)!
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.configure(.update, uiView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self.configurations)
    }
}
