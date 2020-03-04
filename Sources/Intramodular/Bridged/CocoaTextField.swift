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
            }
        }

        @objc func editingEnded() {
            DispatchQueue.main.async {
                self.view.isEditing?.wrappedValue = false
            }
        }

    }

    // MARK: - Properties

    @Binding var text: String
    private let isEditing: Binding<Bool>?

    let onEditingChanged: (() -> Void)?

    private var font: UIFont?
    private var placeholder: String?
    private var autocapitalizationType: UITextAutocapitalizationType
    private var keyboardType: UIKeyboardType

    // MARK: - Init

    public init(text: Binding<String>, isEditing: Binding<Bool>? = nil, onEditingChanged: (() -> Void)? = nil) {
        _text = text
        self.isEditing = isEditing
        self.placeholder = nil
        self.font = nil
        self.autocapitalizationType = .none
        self.keyboardType = .default
        self.onEditingChanged = onEditingChanged
    }

    // MARK: - UIViewRepresentable

    public func makeCoordinator() -> Coordinator {
        Coordinator(view: self)
    }

    public func makeUIView(context: UIViewRepresentableContext<CocoaTextField>) -> UITextField {
        let view = UITextField()
        view.placeholder = placeholder
        view.font = font
        view.autocapitalizationType = autocapitalizationType
        view.keyboardType = keyboardType

        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        view.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        view.addTarget(context.coordinator, action: #selector(Coordinator.editingBegun), for: .editingDidBegin)
        view.addTarget(context.coordinator, action: #selector(Coordinator.editingEnded), for: .editingDidEnd)

        return view
    }

    public func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CocoaTextField>) {
        uiView.text = text

        if uiView.window != nil {
            if uiView.isFirstResponder && isEditing?.wrappedValue == false {
                DispatchQueue.main.async {
                    uiView.resignFirstResponder()
                }
            }
        }
    }

}

extension CocoaTextField {
    public func autocapitalization(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        then({ $0.autocapitalizationType = autocapitalizationType })
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
}

#endif
