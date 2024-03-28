//
//  SubviewBuilder.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

@resultBuilder
public struct SubviewBuilder: Subbuildable {
    public typealias Input = Representable.Represented
    public typealias Output = Representable.Represented
}
