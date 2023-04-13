import SwiftUI
import Combine
public struct CalculatorTextFieldView: UIViewRepresentable {

    @Binding
    private var decimalValue: Decimal?
    private let textFieldConfig: UITextFieldConfig
    private let onFirstResponderChange: (Bool) -> Void
    @Binding var input: InputResult
    private let evaluator: Evaluator
    private let textFieldId: UUID
    public init(
        textFieldId: UUID,
        decimalValue: Binding<Decimal?>,
        inputResult: Binding<InputResult>,
        textFieldConfig: UITextFieldConfig = UITextFieldConfig(),
        onFirstResponderChange: @escaping (Bool) -> Void = { _ in },
        evaluator: Evaluator = Evaluator()
    ) {
        _input = inputResult
        _decimalValue = decimalValue
        self.textFieldConfig = textFieldConfig
        self.onFirstResponderChange = onFirstResponderChange
        self.evaluator = evaluator
        self.textFieldId = textFieldId
    }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextField {
        let textField = CalculatorTextField(evaluator: evaluator)
        textField.tag = textFieldId.hashValue
        textField.onDecimalValueChange = { [unowned coordinator = context.coordinator] in
            coordinator.setDecimalValue($0)
        }
        context.coordinator.textField = textField
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
        
        var textField: CalculatorTextField? {
                willSet {
                    // Remove any old subscriptions before assigning a new textField
                    subcriptions.removeAll()
                }
                didSet {
                    // Re-subscribe to the new textField
                    textField?.evaluator.outputSubject.sink { val in
                        self.parent.input = val
                    }
                    .store(in: &subcriptions)
                }
            }
        
        init(_ parent: CalculatorTextFieldView) {
            self.parent = parent
            textField?.evaluator.outputSubject.sink { val in
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
