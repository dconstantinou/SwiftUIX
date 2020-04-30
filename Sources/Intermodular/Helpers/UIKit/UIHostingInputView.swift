//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

open class UIHostingInputView<Content: View>: UIView {
    private let controller: UIHostingController<Content>

    public var rootView: Content {
        get {
            return controller.rootView
        } set {
            controller.rootView = newValue
        }
    }

    public required init(rootView: Content) {
        self.controller = UIHostingController(rootView: rootView)

        super.init(frame: .zero)

        controller.view.backgroundColor = .clear
        addSubview(controller.view)
        controller.view.constrainEdges(to: safeAreaLayoutGuide)
        backgroundColor = UIColor.secondarySystemBackground
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

#endif
