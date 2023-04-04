import SwiftUI
import Combine
public struct CalculatorTextFieldView: UIViewRepresentable {

    @Binding
    private var decimalValue: Decimal?
    private let textFieldConfig: UITextFieldConfig
    private let onFirstResponderChange: (Bool) -> Void
    @Binding var input: InputResult
    let textField = CalculatorTextField()
    
    public init(
        decimalValue: Binding<Decimal?>,
        inputResult: Binding<InputResult>,
        textFieldConfig: UITextFieldConfig = UITextFieldConfig(),
        onFirstResponderChange: @escaping (Bool) -> Void = { _ in }
    ) {
        _input = inputResult
        _decimalValue = decimalValue
        self.textFieldConfig = textFieldConfig
        self.onFirstResponderChange = onFirstResponderChange
    }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextField {
        
        textField.onDecimalValueChange = { [unowned coordinator = context.coordinator] in
            coordinator.setDecimalValue($0)
        }
        
        textField.borderStyle = .roundedRect
        textField.delegate = context.coordinator
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontSizeToFitWidth = textFieldConfig.adjustsFontSizeToFitWidth
        textField.adjustsFontForContentSizeCategory = true
        textField.textAlignment = textFieldConfig.textAlignment
        textField.placeholder = textFieldConfig.placeholder
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        (uiView as? CalculatorTextField)?.setDecimalValue(decimalValue)
    }

    public func makeCoordinator() -> Self.Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        private let parent: CalculatorTextFieldView
        private var subcriptions = Set<AnyCancellable>()
        init(_ parent: CalculatorTextFieldView) {
            self.parent = parent
            parent.textField.evaluator.outputSubject.sink { val in
                parent.input = val
            }
            .store(in: &subcriptions)
        }

        func setDecimalValue(_ value: Decimal?) {
            parent.decimalValue = value
        }

        // MARK: UITextFieldDelegate
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onFirstResponderChange(true)
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onFirstResponderChange(false)
        }
    }
}

public struct InputResult: Equatable {
    public var operand: Operator
    public var num: Decimal
    
    public init(operand: Operator, num: Decimal) {
        self.operand = operand
        self.num = num
    }
}
