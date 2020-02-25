//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaTextField<Label: View>: View {
    private var label: Label
    
    private var text: Binding<String>
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    
    private var isEditing: Binding<Bool>
    
    private var autocapitalization: UITextAutocapitalizationType?
    private var font: UIFont?
    private var inputAccessoryView: AnyView?
    private var kerning: CGFloat?
    private var keyboardType: UIKeyboardType = .default
    private var placeholder: String?
    private var textAlignment: TextAlignment = .leading
    
    public var body: some View {
        return ZStack(alignment: .topLeading) {
            if placeholder == nil {
                label.opacity(text.wrappedValue.isEmpty ? 1.0 : 0.0)
            }
            
            _CocoaTextField(
                text: text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
                isEditing: isEditing,
                autocapitalization: autocapitalization,
                font: font,
                inputAccessoryView: inputAccessoryView,
                kerning: kerning,
                keyboardType: keyboardType,
                placeholder: placeholder,
                textAlignment: textAlignment
            )
        }
    }
}

public struct _CocoaTextField: UIViewRepresentable {
    public typealias UIViewType = UITextField
    
    @Binding var text: String
    
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    
    @Environment(\.font) var environmentFont
    
    @Binding var isEditing: Bool
    
    var autocapitalization: UITextAutocapitalizationType?
    var font: UIFont?
    var inputAccessoryView: AnyView?
    var kerning: CGFloat?
    var keyboardType: UIKeyboardType
    var placeholder: String?
    var textAlignment: TextAlignment
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var base: _CocoaTextField
        
        init(base: _CocoaTextField) {
            self.base = base
        }
        
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            base.text = textField.text ?? ""
            base.onEditingChanged(false)
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            base.isEditing = true
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            base.isEditing = false
            base.onCommit()
        }
        
        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {            base.onCommit()
            
            return true
        }
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = _UITextField()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.delegate = context.coordinator
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        if let autocapitalization = autocapitalization {
            uiView.autocapitalizationType = autocapitalization
        }
        
        uiView.font = font ?? environmentFont?.toUIFont()
        
        if let kerning = kerning {
            uiView.defaultTextAttributes.updateValue(kerning, forKey: .kern)
        }
        
        if let inputAccessoryView = inputAccessoryView {
            if let _inputAccessoryView = uiView.inputAccessoryView as? UIHostingView<AnyView> {
                _inputAccessoryView.rootView = inputAccessoryView
            } else {
                uiView.inputAccessoryView = UIHostingView(rootView: inputAccessoryView)
                uiView.inputAccessoryView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        } else {
            uiView.inputAccessoryView = nil
        }
        
        uiView.keyboardType = keyboardType
        
        if let placeholder = placeholder {
            uiView.attributedPlaceholder = NSAttributedString(
                string: placeholder, attributes: [
                    .paragraphStyle: NSMutableParagraphStyle().then {
                        $0.alignment = .init(textAlignment)
                    }
                ]
            )
        } else {
            uiView.attributedPlaceholder = nil
            uiView.placeholder = nil
        }
        
        uiView.text = text
        uiView.textAlignment = .init(textAlignment)

        if uiView.window != nil {
            if isEditing && !uiView.isFirstResponder {
                DispatchQueue.main.async { uiView.becomeFirstResponder() }
            } else if uiView.isFirstResponder {
                DispatchQueue.main.async { uiView.resignFirstResponder() }
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

// MARK: - Extensions -

extension CocoaTextField where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        isEditing: Binding<Bool> = State(initialValue: false).projectedValue,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title).foregroundColor(.placeholderText)
        self.text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.isEditing = isEditing
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String?>,
        isEditing: Binding<Bool> = State(initialValue: false).projectedValue,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.init(
            title,
            text: text.withDefaultValue(String()),
            isEditing: isEditing,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit
        )
    }
    
    public init(
        text: Binding<String>,
        isEditing: Binding<Bool> = State(initialValue: false).projectedValue,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        @ViewBuilder label: () -> Text
    ) {
        self.label = label()
        self.text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.isEditing = isEditing
    }
}

extension CocoaTextField {
    public func autocapitalization(_ autocapitalization: UITextAutocapitalizationType) -> Self {
        then({ $0.autocapitalization = autocapitalization })
    }
    
    public func font(_ font: UIFont) -> Self {
        then({ $0.font = font })
    }
    
    public func inputAccessoryView<InputAccessoryView: View>(_ view: InputAccessoryView) -> Self {
        then({ $0.inputAccessoryView = .init(view) })
    }
    
    public func inputAccessoryView<InputAccessoryView: View>(@ViewBuilder _ view: () -> InputAccessoryView) -> Self {
        then({ $0.inputAccessoryView = .init(view()) })
    }
    
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.keyboardType = keyboardType })
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.placeholder = placeholder })
    }
}

extension CocoaTextField where Label == Text {
    public func kerning(_ kerning: CGFloat) -> Self {
        then {
            $0.kerning = kerning
            $0.label = $0.label.kerning(kerning)
        }
    }
    
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.label = Text(placeholder).kerning(kerning) })
    }
}

#endif
