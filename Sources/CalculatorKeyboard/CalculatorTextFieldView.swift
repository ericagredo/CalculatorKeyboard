import SwiftUI
import Combine
public struct CalculatorTextFieldView<T: CalculatorTextFieldItem>: UIViewRepresentable {
    @Binding var item: T
    private let textFieldConfig: UITextFieldConfig
    private let onFirstResponderChange: (Bool) -> Void
    private let evaluator: Evaluator

    public init(
        item: Binding<T>,
        textFieldConfig: UITextFieldConfig = UITextFieldConfig(),
        onFirstResponderChange: @escaping (Bool) -> Void = { _ in },
        evaluator: Evaluator = Evaluator()
    ) {
        _item = item
        self.textFieldConfig = textFieldConfig
        self.onFirstResponderChange = onFirstResponderChange
        self.evaluator = evaluator
    }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextField {
        let textField = CalculatorTextField(evaluator: evaluator)
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
        (uiView as? CalculatorTextField)?.setDecimalValue(item.value)
    }

    public func makeCoordinator() -> Self.Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        private let parent: CalculatorTextFieldView
        private var subcriptions = Set<AnyCancellable>()
        
        var textField: CalculatorTextField? {
            willSet {
                subcriptions.removeAll()
            }
            didSet {
                textField?.evaluator.outputSubject.sink { val in
                    self.parent.item.inputResult = val
                }
                .store(in: &subcriptions)
            }
        }
        
        init(_ parent: CalculatorTextFieldView) {
            self.parent = parent
            textField?.evaluator.outputSubject.sink { val in
                parent.item.inputResult = val
            }
            .store(in: &subcriptions)
        }

        func setDecimalValue(_ value: Decimal?) {
            parent.item.value = value
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

public protocol CalculatorTextFieldItem {
    var value: Decimal? { get set }
    var inputResult: InputResult { get set }
}

