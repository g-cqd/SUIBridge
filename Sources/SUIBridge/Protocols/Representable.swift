//
//  Representable.swift
//
//
//  Created by Guillaume Coquard on 27/03/24.
//

import SwiftUI

public protocol Representable {
    #if os(macOS)
    typealias ViewRepresentable = NSViewRepresentable
    typealias Represented = NSView
    #elseif os(iOS)
    typealias ViewRepresentable = UIViewRepresentable
    typealias Represented = UIView
    #endif
}

extension Representable.Represented: Modifiable {}
extension Representable.Represented {
    public func callAsFunction(@SubviewBuilder subview: () -> Representable.Represented? = { nil }) -> Self {
        if let subview = subview() {
            self.addSubview(subview)
        }
        return self
    }

    public func callAsFunction<Root>(@SubviewBuilder subview: () -> Representable.Represented? = { nil }) -> Bridge<Root> where Root : Representable.Represented {
        if let subview = subview() {
            self.addSubview(subview)
        }
        return Bridge<Root>(self as! Root)
    }

    public func asView<Root>() -> Bridge<Root> {
        .init(self as! Root)
    }
}
