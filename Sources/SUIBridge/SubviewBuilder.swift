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
struct SubviewBuilder<R> where R : Representable.Represented {

    static func buildOptional(_ component: R?) -> R {
        return if let component = component {
            component
        } else {
            R()
        }
    }
    
    static func buildBlock(_ components: R...) -> R {
        let view = R()
        for component in components {
            view.addSubview(component)
        }
        return view
    }
    
    static func buildPartialBlock(first: R) -> R {
        first
    }
    
    static func buildPartialBlock(accumulated: R, next: R) -> R {
        accumulated.addSubview(next)
        return accumulated
    }
    
    static func buildFinalResult(_ component: R) -> R {
        component
    }
}
