import UIKit

final class ButtonFactory {
    private let titleColor = UIColor.label

    func makeDigit(with digit: Digit) -> UIButton {
        DigitButton(digit: digit, titleColor: titleColor)
    }

    func makeSeparator() -> UIButton  {
        makeWithTitle(Locale.autoupdatingCurrent.decimalSeparator ?? ".")
    }

    func makeBackspace() -> UIButton  {
        makeWithSystemImageName("delete.left", highlighted: "delete.left.fill", color: .label)
    }

    func makeEqual() -> UIButton  {
        makeDoneTitle("Done")
    }

    func makeAddition() -> UIButton  {
        makeWithSystemImageName("plus.circle", highlighted: "plus.circle.fill")
    }

    func makeSubtraction() -> UIButton  {
        makeWithSystemImageName("minus.circle", highlighted: "minus.circle.fill")
    }

    func makeMultiplication() -> UIButton  {
        makeWithSystemImageName("multiply.circle", highlighted: "multiply.circle.fill")
    }

    func makeDivision() -> UIButton {
        makeWithSystemImageName("divide.circle", highlighted: "divide.circle.fill")
    }
}

private extension ButtonFactory {
    func makeWithSystemImageName(_ normal: String, highlighted: String, color: UIColor = .myControlBackground) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.tintColor = color
        let configuration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: normal, withConfiguration: configuration)
        let highlightedImage = UIImage(systemName: highlighted, withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.setImage(highlightedImage, for: .highlighted)
        return button
    }
    
    func makeWithTitle(_ title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        return button
    }
    
    func makeDoneTitle(_ title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}


extension UIColor {
    static var myControlBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xA085FF) :
                UIColor(rgb: 0x5413FF)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x5413FF)
        }
    }
}
