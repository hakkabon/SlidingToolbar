//
//  ToolbarViewController.swift
//  Sliding Toolbar
//
//  Created by Ulf Akerstedt-Inoue on 2020/01/05.
//  Copyright © 2020 hakkabon software. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
final public class ToolbarViewController: UIViewController {

    var tapToolbarAction: (() -> ())?
    
    lazy var toolbarView: ToolbarView = {
        let view = ToolbarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public var showShadow: Bool = false {
        didSet {
            if showShadow {
                self.toolbarView.layer.shadowColor = UIColor.black.cgColor
                self.toolbarView.layer.shadowOpacity = 0.5
                self.toolbarView.layer.shadowRadius = 5.0
                self.toolbarView.layer.shadowOffset = CGSize.init(width: 0, height: 0)
            } else {
                self.toolbarView.layer.shadowRadius = 0.0
            }
        }
    }

    public var cornerRadius: Float = 0.0 {
        didSet {
            self.toolbarView.layer.cornerRadius = CGFloat(cornerRadius)
            self.toolbarView.subviews.first?.layer.cornerRadius = CGFloat(cornerRadius)
        }
    }

    required public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(toolbarView)
        
        // Fill the entire parent view.
        // The `toolbarView` will attach itself to one side, .left or .right inside the UIScrollView.
        NSLayoutConstraint.activate([
            toolbarView.topAnchor.constraint(equalTo: self.view.topAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            toolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        self.view.backgroundColor = .clear
        self.view.frame = CGRect(origin: .zero, size: CGSize(width: 2 * toolbarView.barSize.width, height: self.view.bounds.height))
        self.showShadow = true
        
        toolbarView.tabView.handleTapAction = handleTapAction
    }
    
    func handleTapAction() {
        tapToolbarAction?()
    }
}
