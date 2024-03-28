//
//  ViewConfiguration.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import SwiftUI
#endif

public struct ViewConfiguration<Root> where Root : Representable.Represented {

    public typealias ViewType = Root
    public typealias ConfigurationMoment = CycleMoment
    public typealias ConfigurationTask = (ViewType?) -> ViewType?

    static public func Passthrough(_ object: ViewType?) -> ViewType? { object }

    private(set) public var moment: ConfigurationMoment = .all
    private(set) public var task: ConfigurationTask = Self.Passthrough

    public init() {}

    public init(_ configuration: Self) {
        self.moment = configuration.moment
        self.task = configuration.task
    }

    public init(_ configurations: [Self]) {
        let configuration = configurations.reduce(self, { prev, next in prev + next })
        self.moment = configuration.moment
        self.task = configuration.task
    }

    public init(_ configurations: Self...) {
        let configuration = configurations.reduce(self, { prev, next in prev + next })
        self.moment = configuration.moment
        self.task = configuration.task
    }

    public init(_ moment: ConfigurationMoment = .all, _ task: @escaping ConfigurationTask = Self.Passthrough) {
        self.moment = moment
        self.task = task
    }

    public init(_ moment: ConfigurationMoment = .all, tasks: [ConfigurationTask]) {
        self.moment = moment
        self.task = tasks.reduce({ (view: ViewType?) in view }) { prev, next in
            { (view: ViewType?) in next( prev( view )) }
        }
    }

    public init(_ moment: ConfigurationMoment = .all, tasks: ConfigurationTask...) {
        self.moment = moment
        self.task = tasks.reduce({ (view: ViewType?) in view }) { prev, next in
            { (view: ViewType?) in next( prev( view )) }
        }
    }

    public init(_ moment: ConfigurationMoment = .all, from configuration: Self) {
        self.moment = moment
        self.task = configuration.task
    }

    public init(_ moment: ConfigurationMoment = .all, from configurations: [Self]) {
        self.moment = moment
        self.task = configurations.reduce(.init(), +).task
    }

    public init(_ moment: ConfigurationMoment = .all, from configurations: Self...) {
        self.moment = moment
        self.task = configurations.reduce(.init(), +).task
    }

    static public func +(lhs: Self, rhs: Self) -> Self {
        let moment = lhs.moment.intersection(rhs.moment)
        return if moment.isEmpty  {
            Self()
        } else {
            Self(moment, { (view: ViewType?) in rhs.task( lhs.task( view ) ) })
        }
    }

    static public func +(lhs: Self, rhs: @escaping ConfigurationTask) -> Self {
        Self(lhs.moment, { (view: ViewType?) in rhs( lhs.task( view ) ) })
    }

    static public func +(lhs: @escaping ConfigurationTask, rhs: Self) -> Self {
        Self(rhs.moment, { (view: ViewType?) in rhs.task( lhs( view ) ) })
    }

    public func precedes(_ configurations: Self...) -> Self {
        self + configurations.reduce(self, +)
    }

    public func succeeds(_ configurations: Self...) -> Self {
        configurations.reduce(.init(), +) + self
    }

    @discardableResult
    public func callAsFunction(_ view: ViewType?) -> ViewType? {
        self.task( view )
    }
}
