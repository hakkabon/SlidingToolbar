//
//  Toolbar.swift
//  Sliding Toolbar
//
//  Created by Ulf Akerstedt-Inoue on 2020/01/05.
//  Copyright © 2020 hakkabon software. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
public class ToolbarView: UIView {
    
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
            if let b0 = toolbarButtons.first {
                toolbarButtons.dropFirst().forEach { button in
                    if button.buttonType == .button {
                        button.heightAnchor.constraint(equalTo: b0.heightAnchor).isActive = true
                    } else {
                        button.heightAnchor.constraint(equalTo: b0.heightAnchor, multiplier: 0.25).isActive = true
                    }
                }
            }
            self.barSize = CGSize(width: self.barSize.width, height: minHeight)
        }
    }
    
    var minHeight: CGFloat {
        let buttons = toolbarButtons.reduce(0) { $1.buttonType == .button ? $0 + 1 : $0 }
        let separators = toolbarButtons.count - buttons
        var height = CGFloat(separators) * (barSize.width * 0.25 + margin)
        height += CGFloat(buttons) * ( barSize.width + margin) //+ 2 * margin
        return height
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
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let blurEffect = UIBlurEffect(style: blurEffectStyle())
    
    lazy var blurredView: UIVisualEffectView = {
        let effect = UIVisualEffectView(effect: blurEffect)
        effect.translatesAutoresizingMaskIntoConstraints = false
        return effect
    }()
    
    lazy var vibrancyView: UIVisualEffectView = {
        let vibrancy = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        vibrancy.translatesAutoresizingMaskIntoConstraints = false
        return vibrancy
    }()
    
    lazy var barHeightConstraint: NSLayoutConstraint = {
        let constraint = barView.heightAnchor.constraint(equalToConstant: 100)
        return constraint
    }()
    
    lazy var barWidthConstraint: NSLayoutConstraint = {
        let constraint = barView.widthAnchor.constraint(equalToConstant: 54)
        return constraint
    }()
    
    class func blurEffectStyle() -> UIBlurEffect.Style {
        if #available(iOS 13, *) {
            return .systemUltraThinMaterial
        } else {
            return .dark
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override public func awakeFromNib() {
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
        
        barView.insertSubview(blurredView, at: 0)
        blurredView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(stackView)
    }
    
    override public func updateConstraints() {
        switch side {
        case .left:
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
                tabView.heightAnchor.constraint(equalTo: barView.heightAnchor, multiplier: 0.5),
                tabView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
                tabView.leadingAnchor.constraint(equalTo: barView.trailingAnchor),
            ])
        case .right:
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
                tabView.heightAnchor.constraint(equalTo: barView.heightAnchor, multiplier: 0.5),
                tabView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
                tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            ])
        }
        NSLayoutConstraint.activate([
            blurredView.heightAnchor.constraint(equalTo: barView.heightAnchor),
            blurredView.widthAnchor.constraint(equalTo: barView.widthAnchor),
            blurredView.centerXAnchor.constraint(equalTo: barView.centerXAnchor),
            blurredView.centerYAnchor.constraint(equalTo: barView.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            vibrancyView.heightAnchor.constraint(equalTo: blurredView.contentView.heightAnchor),
            vibrancyView.widthAnchor.constraint(equalTo: blurredView.contentView.widthAnchor),
            vibrancyView.centerXAnchor.constraint(equalTo: blurredView.contentView.centerXAnchor),
            vibrancyView.centerYAnchor.constraint(equalTo: blurredView.contentView.centerYAnchor)
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
        blurredView.layer.mask = maskLayer
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutToolbar()
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return overlapHitTest(point: point, with: event)
    }
}

// https://stackoverflow.com/questions/4961386/event-handling-for-ios-how-hittestwithevent-and-pointinsidewithevent-are-r
extension UIView {
    
    func overlapHitTest(point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden && alpha > 0 else { return nil }
        
        var hitView: UIView? = self
        if !self.point(inside: point, with: event) {
             if self.clipsToBounds {
                 return nil
             } else {
                 hitView = nil
             }
        }

        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.overlapHitTest(point: subPoint, with: event) {
                return result
            }
        }
        return hitView
    }
}
