//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingTableViewCell<Content: View> : UITableViewCell {
    var contentHostingController: UIHostingController<Content>?
    
    public var content: Content? {
        get {
            contentHostingController?.rootView
        } set {
            guard let content = newValue else {
                return
            }
            
            if let contentHostingController = contentHostingController {
                contentHostingController.rootView = content
            } else {
                contentHostingController = UIHostingController(rootView: content)
                
                let view = contentHostingController!.view!
                let margins = contentView.layoutMarginsGuide
                
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = .clear

                contentView.addSubview(view)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                    view.topAnchor.constraint(equalTo: margins.topAnchor),
                    view.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                    view.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
                ])
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    static let hostingCellIdentifier = "HostingCell"
}

#endif
