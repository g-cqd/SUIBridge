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
