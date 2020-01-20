//
//  TabView.swift
//  Sliding Toolbar
//
//  Created by Ulf Akerstedt-Inoue on 2020/01/10.
//  Copyright © 2020 hakkabon software. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class TabView: UIView {
    
    var handleTapAction: (() -> ())?
    
    public var side: SlidingToolbarPosition = .left {
        didSet {
            gripView.side = side
            setNeedsLayout()
        }
    }
    
    public var cornerRadius: CGFloat = 17 {
        didSet {
            gripView.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }

    lazy var gripView: GripView = {
        let view = GripView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let blurEffect = UIBlurEffect(style: .dark)

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        self.clipsToBounds = false
        self.backgroundColor = .clear
        
        self.addSubview(gripView)
        self.insertSubview(blurredView, at: 0)
        blurredView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(gripView)
        
        gripView.blurredBackgroundView = blurredView
        gripView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    override func updateConstraints() {
        switch side {
        case .left:
            NSLayoutConstraint.activate([
                gripView.topAnchor.constraint(equalTo: self.topAnchor),
                gripView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                gripView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                gripView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        case .right:
            NSLayoutConstraint.activate([
                gripView.topAnchor.constraint(equalTo: self.topAnchor),
                gripView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                gripView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                gripView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        }
        NSLayoutConstraint.activate([
            blurredView.heightAnchor.constraint(equalTo: gripView.heightAnchor),
            blurredView.widthAnchor.constraint(equalTo: gripView.widthAnchor),
            blurredView.centerXAnchor.constraint(equalTo: gripView.centerXAnchor),
            blurredView.centerYAnchor.constraint(equalTo: gripView.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            vibrancyView.heightAnchor.constraint(equalTo: blurredView.contentView.heightAnchor),
            vibrancyView.widthAnchor.constraint(equalTo: blurredView.contentView.widthAnchor),
            vibrancyView.centerXAnchor.constraint(equalTo: blurredView.contentView.centerXAnchor),
            vibrancyView.centerYAnchor.constraint(equalTo: blurredView.contentView.centerYAnchor)
        ])

        super.updateConstraints()
    }
    
    @objc func handleTap(_ sender: AnyObject) {
        self.handleTapAction?()
    }
}

class GripView: UIView {

    var side: SlidingToolbarPosition = .left {
        didSet {
           setNeedsLayout()
       }
    }
    
    var blurredBackgroundView: UIVisualEffectView?
    
    public var cornerRadius: CGFloat = 17 {
        didSet {
            setNeedsLayout()
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

    func initialize() {
        self.clipsToBounds = true
        self.backgroundColor = .clear
    }
    
    // Add grove lines to grip.
    override func draw(_ rect: CGRect) {
      guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        defer { context.restoreGState() }
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineCap(.round)
        context.setLineWidth(1.5)

        let groves = rect.insetBy(dx: 5, dy: 15)
        let countLine: Int = 3
        for i in 1 ... 3 {
            let x = ((groves.size.width / CGFloat(countLine)) * CGFloat(i)) - CGFloat(countLine)
            context.move(to: CGPoint(x: x, y: groves.minY))
            context.addLine(to: CGPoint(x: x, y: groves.maxY))
        }

        context.strokePath()
    }

    func layoutView() {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        if side == .left {
            maskLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomRight],
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        } else {
            maskLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft],
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        }
        self.layer.mask = maskLayer
        blurredBackgroundView?.layer.mask = maskLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutView()
    }
}
