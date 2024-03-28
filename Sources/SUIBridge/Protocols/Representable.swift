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
    func callAsFunction<Subview>(@SubviewBuilder subview: () -> Subview) -> Self where Subview : Representable.Represented {
        self.addSubview(subview())
        return self
    }
}
