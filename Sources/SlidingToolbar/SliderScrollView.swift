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
    
    /// Setup scrollable content.
    var content: ToolbarView? {
        didSet {
            guard let content = content else { return }
            guard let parent = parent else { return }
            
            self.subviews.forEach { $0.removeFromSuperview() }
            self.addSubview(content)
            
            if position == .right {
                NSLayoutConstraint.activate([
                    self.topAnchor.constraint(equalTo: parent.view.topAnchor),
                    self.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                    self.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
                    self.heightAnchor.constraint(equalTo: parent.view.heightAnchor),
                    self.widthAnchor.constraint(equalToConstant: contentWidth),
                ])
            } else if position == .left {
                NSLayoutConstraint.activate([
                    self.topAnchor.constraint(equalTo: parent.view.topAnchor),
                    self.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                    self.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
                    self.heightAnchor.constraint(equalTo: parent.view.heightAnchor),
                    self.widthAnchor.constraint(equalToConstant: contentWidth),
                ])
            }
            NSLayoutConstraint.activate([
                content.topAnchor.constraint(equalTo: self.topAnchor),
                content.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                content.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                content.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                content.heightAnchor.constraint(equalTo: self.heightAnchor),
                content.widthAnchor.constraint(equalToConstant: 2*contentWidth),
            ])
            self.layoutIfNeeded()
        }
    }
    
    /// Orientation for sliding container.
    public var position: SlidingToolbarPosition = .right
    
    /// Expandable offset in % of content view.
    /// Note that the actual range of values are [0, 0.5].
    ///
    /// For the right side toolbar,
    /// 0       => fully visible
    /// 0.5     => completely hidden
    ///
    /// For the left side toolbar, 0 means completely hidden
    /// 0       => completely hidden
    /// 0.5     => fully visible
    ///
    /// Either left or right list of values has to be reversed.
    private var _offsets: [CGFloat] = []
    public var offsets: [CGFloat] {
        set {
            guard newValue.count > 0 else { return }
            
            let clearOffsets: [CGFloat] = (NSOrderedSet(array: newValue).array as? [CGFloat])!
            let valid = clearOffsets.reduce( true, { $0 && (0 <= $1 && $1 <= 1) })
            guard valid else { return }
            
            let invertedScaled = clearOffsets.map { (1 - $0) * 0.5 }
            let scaled = clearOffsets.map { $0 * 0.5 }
            _offsets = self.position == .left ? invertedScaled.sorted { $0 < $1 } : scaled.sorted { $0 > $1 }
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
    
    /// Parent view controller.
    var parent: UIViewController?
    
    /// Parent view controller.
    var contentWidth: CGFloat = 0
    
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
    
    // Only available init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // Disabled implementation use instead `init(frame: CGRect)`.
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Methods to Increase or decrease offset of content within ScrollView.
    /// - Parameters:
    ///   - offsetIndex: offsetIndex description
    ///   - animated: animated description
    ///   - completion: completion description
    func changeOffsetTo(offsetIndex: Int, animated: Bool, completion: ((Bool) -> Void)?) {
        guard self.content != nil && self.offsets.count > 0 else { return }
        
        panGestureRecognizer.isEnabled = false
        UIView.animate(
            withDuration: TimeInterval(self.duration),
            delay: TimeInterval(self.delay),
            usingSpringWithDamping: CGFloat(self.damping),
            initialSpringVelocity: CGFloat(self.velocity),
            options: .curveEaseOut,
            animations: {() -> Void in
                switch self.position {
                case .left:
                    let offset = CGPoint(x: self.offsets[offsetIndex] * self.content!.bounds.width, y: self.contentOffset.y)
                    self.setContentOffset(offset, animated: animated)
                case .right:
                    let offset = CGPoint(x: self.offsets[offsetIndex] * self.content!.bounds.width, y: self.contentOffset.y)
                    self.setContentOffset(offset, animated: animated)
                }
        },
            completion: {(_ finished: Bool) -> Void in
                self.offsetIndex = offsetIndex
                self.isOpen = offsetIndex != self.offsets.count-1
                self.panGestureRecognizer.isEnabled = true
                completion?(finished)
        })
    }
    
    func expandWithCompletion(completion: ((Bool) -> Void)?) {
        let nextIndex: Int = self.offsetIndex == 0 ? 0 : self.offsetIndex - 1
        self.changeOffsetTo(offsetIndex: nextIndex, animated: false, completion: completion)
    }
    
    func collapseWithCompletion(completion: ((Bool) -> Void)?) {
        let nextIndex: Int = self.offsetIndex + 1 < self.offsets.count ? self.offsetIndex + 1 : self.offsetIndex
        self.changeOffsetTo(offsetIndex: nextIndex, animated: false, completion: completion)
    }
    
    func closeWithCompletion(completion: ((Bool) -> Void)?) {
        self.changeOffsetTo(offsetIndex: offsets.count-1, animated: false, completion: completion)
    }

    // MARK: - Hit Test
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }

        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        return nil
    }
}
