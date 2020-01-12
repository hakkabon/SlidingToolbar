//
//  SliderScrollView.swift
//  Sliding Toolbar
//
//  Created by Ulf Akerstedt-Inoue on 2020/01/05.
//  Copyright © 2020 hakkabon software. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
public class SliderScrollView: UIScrollView {
    
    var isOpenState: ((Bool) -> ())?
    
    /// Draggable content
    var content: UIView? {
        didSet {
            self.addContent(content: self.content!)
        }
    }
    
    /// Orientation for sliding container.
    public var placement: SlidingToolbarPosition = .right
    
    /// Expandable offset in % of content view. from 0 to 1.
    private var _offsets: [CGFloat] = []
    public var offsets: [CGFloat] {
        set {
            guard newValue.count > 0 else { return }
            
            let clearOffsets: [CGFloat] = (NSOrderedSet(array: newValue).array as? [CGFloat])!
            let valid = clearOffsets.reduce( true, { $0 && (0 <= $1 && $1 <= 1) })
            guard valid else { return }

            _offsets = self.placement == .left ? clearOffsets.map { 1 - $0 }.sorted { $0 > $1 } : clearOffsets.sorted { $0 < $1 }
            self.recalculateContentSize()
        }
        get {
            return _offsets
        }
    }
    
    /// Determines whether the element's offset is different than % 0.
    public private(set) var isOpen: Bool = false {
        didSet {
            isOpenState?(isOpen)
        }
    }
    
    /// Returns the position of open Offsets.
    public private(set) var offsetIndex: Int = 0
        
    /// Consider subviews of the content as part of the content, used when dragging.
    var selectContentSubViews: Bool = false
    
    /// Duration of animation for changing offset.
    var duration: Float = 0.3
    
    /// Delay of animation for changing offset.
    var delay: Float = 0.0
    
    /// Damping of animation for changing offset.
    var damping: Float = 0.7
    
    /// Damping of animation for changing offset.
    var velocity: Float = 0.6
    
    lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Only available init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    // Disabled implementation use instead `init(frame: CGRect)`.
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Call this method to force recalculation of contentSize in ScrollView, i.e. when content changes.
    func recalculateContentSize() {
        guard self.content != nil && !self.offsets.isEmpty else { return }

        var size: CGSize = CGSize.zero

        switch self.placement {
        case .left: // max <= 1 (self.offsets.first!)
            size.width = self.frame.width + self.content!.frame.width * self.offsets.first!
        case .right: // max <= 1 (self.offsets.last!)
            size.width = self.frame.width + self.content!.frame.width * self.offsets.last!
        }
        
        self.contentSize = size
        self.layoutIfNeeded()
    }
    
    /// Methods to Increase or decrease offset of content within ScrollView.
    /// - Parameters:
    ///   - offsetIndex: offsetIndex description
    ///   - animated: animated description
    ///   - completion: completion description
    func changeOffsetTo(offsetIndex: Int, animated: Bool, completion: ((Bool) -> Void)?) {
        guard self.content != nil && self.offsets.count > 0 else { return }

        panGestureRecognizer.isEnabled = false
        self.content?.isHidden = false
        UIView.animate(
            withDuration: TimeInterval(self.duration),
            delay: TimeInterval(self.delay),
            usingSpringWithDamping: CGFloat(self.damping),
            initialSpringVelocity: CGFloat(self.velocity),
            options: .curveEaseOut,
            animations: {() -> Void in
                switch self.placement {
                case .left:
                    self.setContentOffset(CGPoint(x: self.offsets[offsetIndex] * self.content!.frame.width, y: self.contentOffset.y), animated: animated)
                case .right:
                    self.setContentOffset(CGPoint(x: self.offsets[offsetIndex] * self.content!.frame.width, y: self.contentOffset.y), animated: animated)
                }
        },
        completion: {(_ finished: Bool) -> Void in
            self.offsetIndex = offsetIndex
            if self.placement == .left {
                self.isOpen = offsetIndex == 0 ? false : true
            } else {
                self.isOpen = self.offsets[offsetIndex] <= 0.15 ? false : true
            }
            
            //self.content?.isHidden = !self.isOpen
            self.panGestureRecognizer.isEnabled = true
            
            completion?(finished)
        })
    }
    
    func expandWithCompletion(completion: ((Bool) -> Void)?) {
        let nextIndex: Int = self.offsetIndex + 1 < self.offsets.count ? self.offsetIndex + 1 : self.offsetIndex
        self.changeOffsetTo(offsetIndex: nextIndex, animated: false, completion: completion)
    }
    
    func collapseWithCompletion(completion: ((Bool) -> Void)?) {
        let nextIndex: Int = self.offsetIndex == 0 ? 0 : self.offsetIndex - 1
        self.changeOffsetTo(offsetIndex: nextIndex, animated: false, completion: completion)
    }
    
    func closeWithCompletion(completion: ((Bool) -> Void)?) {
        self.changeOffsetTo(offsetIndex: 0, animated: false, completion: completion)
    }
    
    // MARK: - private methods
    
    private func initialize() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.translatesAutoresizingMaskIntoConstraints = true

        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.isDirectionalLockEnabled = false
        self.scrollsToTop = false
        self.isPagingEnabled = false
        self.contentInset = UIEdgeInsets.zero
        self.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    private func addContent(content: UIView) {
        guard !content.frame.isNull else { return }

        self.subviews.forEach { $0.removeFromSuperview() }

        self.addSubview(container)
        container.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false

        if self.placement == .right {
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: self.topAnchor),
                container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                container.heightAnchor.constraint(equalTo: self.heightAnchor),
                container.widthAnchor.constraint(equalToConstant: self.frame.width + content.frame.width),
            ])
            NSLayoutConstraint.activate([
                content.topAnchor.constraint(equalTo: container.topAnchor),
                content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                content.widthAnchor.constraint(equalToConstant: content.frame.width),
            ])
        } else if self.placement == .left {
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: self.topAnchor),
                container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                container.heightAnchor.constraint(equalTo: self.heightAnchor),
                container.widthAnchor.constraint(equalToConstant: self.frame.width),
            ])
            NSLayoutConstraint.activate([
                content.topAnchor.constraint(equalTo: container.topAnchor),
                content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                content.widthAnchor.constraint(equalToConstant: content.frame.width),
            ])
        }
        self.recalculateContentSize()
        self.layoutIfNeeded()
    }

    private func viewContainsPoint(point: CGPoint, inView view: UIView) -> Bool {
        if self.content != nil && self.content!.frame.contains(point) {
            return true
        }
        if self.selectContentSubViews {
            for subView in view.subviews {
                if subView.frame.contains(point) {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - touch handlers
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.isUserInteractionEnabled && !self.isHidden && self.alpha > 0.01 else { return nil }
        guard let content = self.content else { return nil }

        if self.viewContainsPoint(point: point, inView: content) {
            for subview in self.subviews.reversed() {
                let pt: CGPoint = CGPoint(x: abs(point.x), y: abs(point.y))
                let convertedPoint: CGPoint = subview.convert(pt, from: self)
                let hitTestView = subview.hitTest(convertedPoint, with: event)
                if hitTestView != nil {
                    return hitTestView
                }
            }
        }
        return nil
    }
}
