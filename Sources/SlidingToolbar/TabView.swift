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
            setNeedsLayout()
        }
    }
    
    public var cornerRadius: CGFloat = 17 {
        didSet {
            setNeedsLayout()
        }
    }

    lazy var tabView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

    var tabRect: CGRect {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        return CGRect(x: 10 * (width/11), y: height/2 - 50, width: width/11, height: 100)
    }
    
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
        self.isUserInteractionEnabled = true
        
        addSubview(tabView)
        tabView.addSubview(overlayView)

        tabView.insertSubview(blurView, at: 0)
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(overlayView)
        
        // Setup gesture recognizers.
//        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
//        for direction in directions {
//            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//            gesture.direction = direction
//            self.addGestureRecognizer(gesture)
//        }
//        self.isUserInteractionEnabled = true
//        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    override func updateConstraints() {
        switch side {
        case .left:
            NSLayoutConstraint.activate([
                tabView.topAnchor.constraint(equalTo: self.topAnchor),
                tabView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                tabView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        case .right:
            NSLayoutConstraint.activate([
                tabView.topAnchor.constraint(equalTo: self.topAnchor),
                tabView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                tabView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        }
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: tabView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: tabView.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: tabView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: tabView.trailingAnchor),
        ])
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: tabView.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: tabView.widthAnchor),
            blurView.centerXAnchor.constraint(equalTo: tabView.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: tabView.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            vibrancyView.heightAnchor.constraint(equalTo: blurView.contentView.heightAnchor),
            vibrancyView.widthAnchor.constraint(equalTo: blurView.contentView.widthAnchor),
            vibrancyView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            vibrancyView.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
        ])

        super.updateConstraints()
    }
    
    func layoutTab() {
        let maskPath: UIBezierPath = {
            if side == .left {
                return UIBezierPath(roundedRect: tabView.bounds, byRoundingCorners: [.topRight, .bottomRight],
                                            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            } else {
                return UIBezierPath(roundedRect: tabView.bounds, byRoundingCorners: [.topLeft, .bottomLeft],
                                            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            }
        }()

        let maskLayer = CAShapeLayer()
        maskLayer.frame = tabView.bounds
        maskLayer.path = maskPath.cgPath
        tabView.layer.mask = maskLayer
        blurView.layer.mask = maskLayer

        tabView.layer.sublayers?.forEach {
            if $0.name == "grip" {
                $0.removeFromSuperlayer()
            }
        }

        // Add grove lines to tab.
        let rect = tabView.bounds.insetBy(dx: 5, dy: 15)
        let countLine: Int = 3
        for i in 1 ... 3 {
            let linePath = UIBezierPath()
            let x = ((rect.size.width / CGFloat(countLine + 1)) * CGFloat(i)) + 1.5
            linePath.move(to: CGPoint(x: x, y: rect.minY))
            linePath.addLine(to: CGPoint(x: x, y: rect.maxY))

            let shapeLayer = CAShapeLayer()
            shapeLayer.name = "grip"
            shapeLayer.path = linePath.cgPath
            shapeLayer.strokeColor = UIColor(white: 1, alpha: 0.5).cgColor
            shapeLayer.lineCap = .round
            shapeLayer.lineWidth = 1.5
            shapeLayer.fillColor = UIColor.clear.cgColor
            tabView.layer.addSublayer(shapeLayer)
         }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTab()
    }
}
