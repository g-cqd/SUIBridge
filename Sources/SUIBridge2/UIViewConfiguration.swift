//
//  File 2.swift
//  
//
//  Created by Guillaume Coquard on 26/03/24.
//

import Foundation

public struct UIViewConfiguration<UIViewType> {

    public typealias ConfigurationMoment = CycleMoment
    public typealias ConfigurationTask = (UIViewType?) -> UIViewType?

    static private func Passthrough(_ view: UIViewType?) -> UIViewType? { view }

    private(set) public var moment: ConfigurationMoment = .all
    private(set) public var task: ConfigurationTask = Self.Passthrough

    init() {}

    init(_ configuration: Self) {
        self.moment = configuration.moment
        self.task = configuration.task
    }

    init(_ configurations: [Self]) {
        let configuration = configurations.reduce(self, { prev, next in prev + next })
        self.moment = configuration.moment
        self.task = configuration.task
    }

    init(_ configurations: Self...) {
        let configuration = configurations.reduce(self, { prev, next in prev + next })
        self.moment = configuration.moment
        self.task = configuration.task
    }

    init(_ moment: ConfigurationMoment = .all, _ task: @escaping ConfigurationTask = Self.Passthrough) {
        self.moment = moment
        self.task = task
    }

    init(_ moment: ConfigurationMoment = .all, tasks: [ConfigurationTask]) {
        self.moment = moment
        self.task = tasks.reduce({ (view: UIViewType?) in view }) { prev, next in
            { (view: UIViewType?) in next( prev( view )) }
        }
    }

    init(_ moment: ConfigurationMoment = .all, tasks: ConfigurationTask...) {
        self.moment = moment
        self.task = tasks.reduce({ (view: UIViewType?) in view }) { prev, next in
            { (view: UIViewType?) in next( prev( view )) }
        }
    }

    init(_ moment: ConfigurationMoment = .all, from configuration: Self) {
        self.moment = moment
        self.task = configuration.task
    }

    init(_ moment: ConfigurationMoment = .all, from configurations: [Self]) {
        self.moment = moment
        self.task = configurations.reduce(.init(), +).task
    }

    init(_ moment: ConfigurationMoment = .all, from configurations: Self...) {
        self.moment = moment
        self.task = configurations.reduce(.init(), +).task
    }

    static public func +(lhs: Self, rhs: Self) -> Self {
        let moment = lhs.moment.intersection(rhs.moment)
        return if moment.isEmpty  {
            Self()
        } else {
            Self(moment, { (view: UIViewType?) in rhs.task( lhs.task( view ) ) })
        }
    }

    static public func +(lhs: Self, rhs: @escaping ConfigurationTask) -> Self {
        Self(lhs.moment, { (view: UIViewType?) in rhs( lhs.task( view ) ) })
    }

    static public func +(lhs: @escaping ConfigurationTask, rhs: Self) -> Self {
        Self(rhs.moment, { (view: UIViewType?) in rhs.task( lhs( view ) ) })
    }

    public func precedes(_ configurations: Self...) -> Self {
        self + configurations.reduce(self, +)
    }

    public func succeeds(_ configurations: Self...) -> Self {
        configurations.reduce(.init(), +) + self
    }

    @discardableResult
    public func callAsFunction(_ view: UIViewType?) -> UIViewType? {
        self.task( view )
    }
}
