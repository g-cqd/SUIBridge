//
//  File.swift
//  
//
//  Created by Guillaume Coquard on 27/03/24.
//

import SwiftUI

@resultBuilder
public protocol Subbuildable {
    associatedtype Input
    associatedtype Output

    static func buildOptional(_ component: Input?) -> Output
    static func buildBlock(_ components: Input...) -> Output
    static func buildPartialBlock(first: Input) -> Output
    static func buildPartialBlock(accumulated: Input, next: Input) -> Output
    static func buildFinalResult(_ component: Input) -> Output
}

extension Subbuildable where Input : Representable.Represented, Output == Representable.Represented {

    public static func buildOptional(_ component: Input?) -> Output {
        if let component = component {
            let view = Output()
            view.addSubview(component)
            return view
        } else {
            return Output()
        }
    }

    public static func buildBlock(_ components: Input...) -> Output {
        let view = Output()
        for component in components {
            view.addSubview(component)
        }
        return view
    }

    public static func buildPartialBlock(first: Input) -> Output {
        let view = Output()
        view.addSubview(first)
        return view
    }

    public static func buildPartialBlock(accumulated: Input, next: Input) -> Output {
        let view = Output()
        accumulated.addSubview(next)
        view.addSubview(accumulated)
        return view
    }

    public static func buildFinalResult(_ component: Input) -> Output {
        let view = Output()
        view.addSubview(component)
        return view
    }
}
