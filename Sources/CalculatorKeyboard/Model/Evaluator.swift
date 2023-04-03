import Foundation
import Combine

struct Evaluator {
    let outputSubject = PassthroughSubject<InputResult, Never>()
    
    func evaluate(_ expression: Expression) -> String? {
        switch expression {
        case .lhsOperatorRhs(let lhs, let opt, let rhs):
            outputSubject.send(InputResult(operand: opt, num: Decimal(string: rhs, locale: Constants.locale) ?? 0.0))
            return evaluate(lhs: lhs, rhs: rhs, opt: opt)
        default:
            return nil
        }
    }
}

private extension Evaluator {
    func evaluate(lhs: String, rhs: String, opt: Operator) -> String? {
        guard let lhsDecimal = Decimal(string: lhs, locale: Constants.locale),
              let rhsDecimal = Decimal(string: rhs, locale: Constants.locale)
        else {
            return nil
        }
        var result: Decimal?
        let scale = Constants.decimalScale
        switch opt {
        case .addition:
            result = (lhsDecimal + rhsDecimal).rounded(scale, .bankers)
        case .subtraction:
            result = (lhsDecimal - rhsDecimal).rounded(scale, .bankers)
        case .multiplication:
            result = (lhsDecimal * rhsDecimal).rounded(scale, .bankers)
        case .division:
            result = (lhsDecimal / rhsDecimal).rounded(scale, .bankers)
        }
        if let result = result, result != Decimal.nan {
            return result.description
        }
        return nil
    }
}
