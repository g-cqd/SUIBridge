//
//  View.swift
//
//
//  Created by Guillaume Coquard on 27/03/24.
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

#if os(iOS)
extension UIView: ModifiableObject {}
#elseif os(macOS)
extension NSView: ModifiableObject {}
#endif
