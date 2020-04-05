//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

public struct CocoaTextField: UIViewRepresentable {

    // MARK: - Types

    public class Coordinator: NSObject {

        let view: CocoaTextField

        init(view: CocoaTextField) {
            self.view = view
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            view.text = textField.text ?? ""
            view.onEditingChanged?()
        }

        @objc func editingBegun() {
            DispatchQueue.main.async {
                self.view.isEditing?.wrappedValue = true
                self.view.onEditingBegun?()
            }
        }

        @objc func editingEnded() {
            DispatchQueue.main.async {
                self.view.isEditing?.wrappedValue = false
                self.view.onEditingEnded?()
            }
        }

    }

    // MARK: - Properties

    @Binding var text: String

    let isEditing: Binding<Bool>?
    let onEditingBegun: (() -> Void)?
    let onEditingChanged: (() -> Void)?
    let onEditingEnded: (() -> Void)?

    private var font: UIFont?
    private var placeholder: String?
    private var autocapitalizationType: UITextAutocapitalizationType
    private var autocorrectionType: UITextAutocorrectionType
    private var keyboardType: UIKeyboardType
    private var textAlignment: NSTextAlignment
    private var textColor: UIColor?

    private var inputView: AnyView?
    private var inputAccessoryView: AnyView?

    // MARK: - Init

    public init(text: Binding<String>, isEditing: Binding<Bool>? = nil, onEditingBegun: (() -> Void)? = nil, onEditingChanged: (() -> Void)? = nil, onEditingEnded: (() -> Void)? = nil) {
        _text = text
        self.isEditing = isEditing
        self.placeholder = nil
        self.font = nil
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.keyboardType = .default
        self.textAlignment = .left
        self.textColor = nil
        self.onEditingBegun = onEditingBegun
        self.onEditingChanged = onEditingChanged
        self.onEditingEnded = onEditingEnded
    }

    // MARK: - UIViewRepresentable

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }

    public func makeUIView(context: UIViewRepresentableContext<CocoaTextField>) -> UITextField {
        let view = UITextField()

        view.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        view.addTarget(context.coordinator, action: #selector(Coordinator.editingBegun), for: .editingDidBegin)
        view.addTarget(context.coordinator, action: #selector(Coordinator.editingEnded), for: .editingDidEnd)

        return view
    }

    public func updateUIView(_ view: UITextField, context: UIViewRepresentableContext<CocoaTextField>) {
        if view.text != text {
            DispatchQueue.main.async {
                view.sendActions(for: .editingChanged)
            }
        }

        view.text = text
        view.placeholder = placeholder
        view.font = font
        view.autocapitalizationType = autocapitalizationType
        view.autocorrectionType = autocorrectionType
        view.keyboardType = keyboardType
        view.textAlignment = textAlignment
        view.textColor = textColor

        if view.window != nil {
            if view.isFirstResponder && isEditing?.wrappedValue == false {
                DispatchQueue.main.async {
                    view.resignFirstResponder()
                }
            }
        }

        if let inputAccessoryView = inputAccessoryView {
            if let _inputAccessoryView = view.inputAccessoryView as? UIHostingView<AnyView> {
                _inputAccessoryView.rootView = inputAccessoryView
            } else {
                view.inputAccessoryView = UIHostingView(rootView: inputAccessoryView)
                view.inputAccessoryView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        } else {
            view.inputAccessoryView = nil
        }

        if let inputView = inputView {
            if let _inputView = view.inputView as? UIHostingView<AnyView> {
                _inputView.rootView = inputView
            } else {
                view.inputView = UIHostingView(rootView: inputView)
                view.inputView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        } else {
            view.inputView = nil
        }
    }

}

extension CocoaTextField {

    public func autocapitalization(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        then({ $0.autocapitalizationType = autocapitalizationType })
    }
    public func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        then({ $0.autocorrectionType = autocorrectionType })
    }

    public func font(_ font: UIFont?) -> Self {
        then({ $0.font = font })
    }

    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.keyboardType = keyboardType })
    }

    public func placeholder(_ placeholder: String?) -> Self {
        then({ $0.placeholder = placeholder })
    }

    public func inputView<Content: View>(@ViewBuilder _ content: () -> Content) -> Self {
        then({ $0.inputView = .init(content()) })
    }

    public func inputAccessoryView<Content: View>(@ViewBuilder _ content: () -> Content) -> Self {
        then({ $0.inputAccessoryView = .init(content()) })
    }

    public func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        then({ $0.textAlignment = textAlignment })
    }

    public func textColor(_ textColor: UIColor?) -> Self {
        then({ $0.textColor = textColor })
    }

}

#endif
