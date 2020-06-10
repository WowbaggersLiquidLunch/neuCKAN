//
//  Operators.swift
//  neuCKAN
//
//  Created by 冀卓疌 on 20-05-29.
//  Copyright © 2020 Wowbagger & His Liquid Lunch. All rights reserved.
//

import Foundation

//	MARK: Multiplicative

infix operator ×: MultiplicationPrecedence
infix operator &×: MultiplicationPrecedence
infix operator ÷: MultiplicationPrecedence
infix operator &÷: MultiplicationPrecedence

//	MARK: Additive

infix operator ∩: AdditionPrecedence
infix operator ∪: AdditionPrecedence
infix operator ∖: AdditionPrecedence

//	MARK: Comparative

infix operator ∈: ComparisonPrecedence
infix operator ∉: ComparisonPrecedence

infix operator ∋: ComparisonPrecedence
infix operator ∌: ComparisonPrecedence

infix operator ⊂: ComparisonPrecedence
infix operator ⊄: ComparisonPrecedence
infix operator ⊆: ComparisonPrecedence
infix operator ⊈: ComparisonPrecedence
infix operator ⊊: ComparisonPrecedence

infix operator ⊃: ComparisonPrecedence
infix operator ⊅: ComparisonPrecedence
infix operator ⊇: ComparisonPrecedence
infix operator ⊉: ComparisonPrecedence
infix operator ⊋: ComparisonPrecedence

//	MARK: Compound

infix operator ×=: AssignmentPrecedence
infix operator &×=: AssignmentPrecedence
infix operator ÷=: AssignmentPrecedence
infix operator &÷=: AssignmentPrecedence

infix operator ∩=: AssignmentPrecedence
infix operator ∪=: AssignmentPrecedence
infix operator ∖=: AssignmentPrecedence
