//
//  ToolbarButton.swift
//  Sliding Toolbar
//
//  Created by Ulf Akerstedt-Inoue on 2019/02/07.
//  Copyright © 2019 hakkabon software. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
public class ToolbarButton: UIView {
    
    public var action: (() -> ())?
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var separator: UIView = UIView() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var restoreTransform: CGAffineTransform = CGAffineTransform.identity
    
    enum ButtonType { case button, separator }
    var buttonType: ButtonType = .button
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize(subtype: .button)
    }
    
    public init(image: UIImage) {
        super.init(frame: .zero)
        imageView.image = image
        self.initialize(subtype: .button)
    }
    
    public init(separator: Separator) {
        super.init(frame: .zero)
        self.separator = separator
        self.initialize(subtype: .separator)
        imageView.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize(subtype: .button)
    }
    
    private func initialize(subtype type: ButtonType) {
        self.buttonType = type
        self.backgroundColor = .clear
        
        if buttonType == .button {
            self.addSubview( imageView )
        } else {
            self.addSubview( separator )
            self.isUserInteractionEnabled = false
        }
    }
    
    override public func updateConstraints() {
        if buttonType == .button {
            NSLayoutConstraint.activate([ // aspect ratio 1:1
                imageView.widthAnchor.constraint(equalTo: self.widthAnchor),
                imageView.heightAnchor.constraint(equalTo: widthAnchor),
                imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                separator.topAnchor.constraint(equalTo: self.topAnchor),
                separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                separator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                separator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        }
        super.updateConstraints()
    }
    
    override public func tintColorDidChange() {
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pressDown()
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pressUp()
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pressUp()
    }
}

@available(iOS 9.0, *)
private extension ToolbarButton {
    
    func pressUp() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: { () -> Void in
            self.transform = self.restoreTransform
            self.action?()
        }, completion: nil)
    }
    
    func pressDown() {
        UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: .beginFromCurrentState, animations: { () -> Void in
            self.restoreTransform = self.transform
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }
}

public class Separator: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    private func initialize() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let strokeColor = UIColor.lightGray.cgColor
    let lineWidth: CGFloat = 2
    let margin: CGFloat = 6
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let rect = self.bounds.insetBy(dx: margin, dy: margin)
        context.setStrokeColor(strokeColor)
        context.setLineWidth(lineWidth)
        context.setFillColor(UIColor.clear.cgColor)
        context.setLineCap(.round)
        
        context.move(to: CGPoint(x: rect.minX, y: rect.midY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        context.strokePath()
    }
}
