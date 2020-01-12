//
//  Toolbar.swift
//  Sliding Toolbar
//
//  Created by Ulf Akerstedt-Inoue on 2020/01/05.
//  Copyright © 2020 hakkabon software. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class ToolbarView: UIView {
    
    public var side: SlidingToolbarPosition = .left {
        didSet {
            tabView.side = side
            setNeedsLayout()
        }
    }
    
    var isGripVisible: Bool = false {
        didSet {
            tabView.alpha = isGripVisible ? 1 : 0
        }
    }
    
    public var barSize: CGSize = CGSize(width: 54, height: 100) {
        didSet {
            // Make room for all buttons (avoid overlapping buttons).
            if toolbarButtons.count > 0 {
                barSize.height = minHeight > barSize.height ? minHeight : barSize.height
                barHeightConstraint.constant = barSize.height
                barWidthConstraint.constant = barSize.width
                setNeedsLayout()
            }
        }
    }
    
    public var cornerRadius: CGFloat = 17 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var margin: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var toolbarButtons: [ToolbarButton] = [ToolbarButton]() {
        didSet {
            stackView.subviews.forEach { $0.removeFromSuperview() }
            toolbarButtons.forEach {
                stackView.addArrangedSubview($0)
                $0.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
                $0.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
            }
            self.barSize = CGSize(width: self.barSize.width, height: minHeight)
        }
    }
    
    var minHeight: CGFloat {
        return CGFloat(toolbarButtons.count) * ( barSize.width + margin ) + 2 * margin
    }
    
    lazy var barView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var tabView: TabView = {
        let view = TabView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let blurEffect = UIBlurEffect(style: .dark)
    
    lazy var blurView: UIVisualEffectView = {
        let effect = UIVisualEffectView(effect: blurEffect)
        effect.translatesAutoresizingMaskIntoConstraints = false
        return effect
    }()
    
    lazy var vibrancyView: UIVisualEffectView = {
        let vibrancy = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        vibrancy.translatesAutoresizingMaskIntoConstraints = false
        return vibrancy
    }()
    
    var barHeightConstraint: NSLayoutConstraint!
    var barWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    func initialize() {
        self.clipsToBounds = false
        self.backgroundColor = .clear
        
        // Add subviews
        addSubview(barView)
        barView.addSubview(stackView)
        barView.addSubview(tabView)
        
        barView.insertSubview(blurView, at: 0)
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(stackView)
    }
    
    override func updateConstraints() {
        switch side {
        case .left:
            barHeightConstraint = barView.heightAnchor.constraint(equalToConstant: barSize.height)
            barWidthConstraint = barView.widthAnchor.constraint(equalToConstant: barSize.width)
            NSLayoutConstraint.activate([
                barView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                barView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                barWidthConstraint,
                barHeightConstraint
            ])
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: barView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: barView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: barView.leadingAnchor, constant: margin * 0.5),
                stackView.trailingAnchor.constraint(equalTo: barView.trailingAnchor, constant: -margin * 0.5),
            ])
            NSLayoutConstraint.activate([
                tabView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                tabView.heightAnchor.constraint(equalTo: barView.heightAnchor, multiplier: 0.25),
                tabView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
                tabView.leadingAnchor.constraint(equalTo: barView.trailingAnchor),
            ])
        case .right:
            barHeightConstraint = barView.heightAnchor.constraint(equalToConstant: barSize.height)
            barWidthConstraint = barView.widthAnchor.constraint(equalToConstant: barSize.width)
            NSLayoutConstraint.activate([
                barView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                barView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: barSize.width),
                barWidthConstraint,
                barHeightConstraint
            ])
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: barView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: barView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: barView.leadingAnchor, constant: margin * 0.5),
                stackView.trailingAnchor.constraint(equalTo: barView.trailingAnchor, constant: -margin * 0.5),
            ])
            NSLayoutConstraint.activate([
                tabView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                tabView.heightAnchor.constraint(equalTo: barView.heightAnchor, multiplier: 0.25),
                tabView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
                tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            ])
        }
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: barView.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: barView.widthAnchor),
            blurView.centerXAnchor.constraint(equalTo: barView.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: barView.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            vibrancyView.heightAnchor.constraint(equalTo: blurView.contentView.heightAnchor),
            vibrancyView.widthAnchor.constraint(equalTo: blurView.contentView.widthAnchor),
            vibrancyView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            vibrancyView.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
        ])
        
        super.updateConstraints()
    }
    
    func layoutToolbar() {
        let dy = (barView.bounds.height - barSize.height) * 0.5
        let rect = barView.bounds.insetBy(dx: 0, dy: dy)
        
        let maskPath: UIBezierPath = {
            if side == .left {
                return UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .bottomRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            } else {
                return UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .bottomLeft],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            }
        }()
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = barView.bounds
        maskLayer.path = maskPath.cgPath
        barView.layer.mask = maskLayer
        blurView.layer.mask = maskLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutToolbar()
    }
    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        //if super.point(inside: point, with: event) { return true }
//        for subview in subviews {
//            let subviewPoint = subview.convert(point, from: self)
//            if subview.point(inside: subviewPoint, with: event) { return true }
//        }
//        return false
//    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if !self.clipsToBounds && !self.isHidden && self.alpha > 0.0 {
//            let subviews = self.subviews.reversed()
//            for member in subviews {
//                let subPoint = member.convert(point, from: self)
//                if let result: UIView = member.hitTest(subPoint, with:event) {
//                    return result
//                }
//            }
//        }
//        return nil  //super.hitTest(point, with: event)
//    }    
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
//
//        for subview in subviews.reversed() {
//            let subPoint = subview.convert(point, from: self)
//            if let result = subview.hitTest(subPoint, with: event) {
//                return result
//            }
//        }
//        return nil
//    }
}
