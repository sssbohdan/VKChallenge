//
//  Functions.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import Foundation

func id<T>(_ value: T) -> T {
    return value
}

func cast<From, To>(_ value: From) -> To? {
    return value as? To
}

func toClosure<T>(_ value: T) -> (() -> T) {
    return { value }
}

func printObject(_ object: Any) {
    print(object)
}

precedencegroup CompositionPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator •: CompositionPrecedence

func compose<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

func •<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return compose(f, g)
}

