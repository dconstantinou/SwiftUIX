//
//  UITextInput.swift
//  
//
//  Created by Dino Constantinou on 29/04/2020.
//

import SwiftUI
import UIKit

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct UITextInputEnvironmentKey: EnvironmentKey {
    static var defaultValue: UITextInput? {
        return nil
    }
}

extension EnvironmentValues {
    public var textInput: UITextInput? {
        get {
            self[UITextInputEnvironmentKey.self]
        } set {
            self[UITextInputEnvironmentKey.self] = newValue
        }
    }
}

#endif
