import Foundation

struct Formatter {
    private let validator: Validator
    private let formatter: NumberFormatter

    init(validator: Validator, locale: Locale = Locale.autoupdatingCurrent) {
        self.validator = validator
        self.formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.usesGroupingSeparator = true
        formatter.alwaysShowsDecimalSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = Constants.decimalScale
        formatter.currencySymbol = Locale.current.currencySymbol
    }

    func string(from expression: Expression) -> String {
        let text: String
        switch expression {
        case .empty:
            text = ""
        case let .lhs(lhs):
            text = formattedString(from: lhs)
        case let .lhsOperator(lhs, opt):
            text = formattedString(from: lhs) + opt.rawValue.padding()
        case let .lhsOperatorRhs(lhs, opt, rhs):
            text = formattedString(from: lhs) + opt.rawValue.padding() + rightHandString(from: rhs)
        }
        return text
    }
}

private extension Formatter {
    func rightHandString(from string: String) -> String {
        if validator.isValidDecimalString(string) {
            return string
        }
             
        else {
            return ""
        }
        
    }
    
    func formattedString(from string: String) -> String {
        guard validator.isValidDecimalString(string),
              let decimal = Decimal(string: string, locale: Constants.locale),
              let formatted = formatter.string(from: decimal as NSDecimalNumber)
        else {
            return localizeSeparator(string)
        }

        // formatter doesn't remove space before suffixed currency symbol, trim it manually
        return formatted.trimmingCharacters(in: .whitespaces)
    }
    
    func localizeSeparator(_ string: String) -> String {
        return (Locale.current.currencySymbol ?? "$") + string
    }
}

private extension String {
    func hasZeroesRightAfterSeparator(_ separator: String) -> Bool {
        hasSuffix("\(separator)0") || hasSuffix("\(separator)00")
    }

    func padding() -> String {
        " \(self) "
    }
}
