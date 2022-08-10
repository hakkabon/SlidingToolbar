//
//  SlidingToolbar.swift
//  Sliding Toolbar
//
//  Created by Ulf Akerstedt-Inoue on 2020/01/10.
//  Copyright © 2020 hakkabon software. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
public protocol SlidingToolbarDelegate {
    
    /// Notifies performed changes in offset.
    /// - Parameters:
    ///   - slidingToolbar: the sliding toolbar object
    ///   - offset: sliding offset in points
    func slidingToolbar(_ slidingToolbar: SlidingToolbar, didChangeOffset offset: CGPoint)
    
    /// Notifies increase in offset by one.
    /// - Parameter slidingToolbar: the sliding toolbar object
    func slidingToolbarWillExpand(_ slidingToolbar: SlidingToolbar)
    
    /// Notifies decrease in offset by one.
    /// - Parameter slidingToolbar: the sliding toolbar object
    func slidingToolbarWillCollapse(_ slidingToolbar: SlidingToolbar)
    
    /// Notifies performed increase in offset by one.
    /// - Parameter slidingToolbar: the sliding toolbar object
    func slidingToolbarDidExpand(_ slidingToolbar: SlidingToolbar)
    
    /// Notifies performed decrease in offset by one.
    /// - Parameter slidingToolbar: the sliding toolbar object
    func slidingToolbarDidCollapse(_ slidingToolbar: SlidingToolbar)
}

/// Toolbar position, either `left` or `right`.
public enum SlidingToolbarPosition {
    case left
    case right
}

@available(iOS 9.0, *)
public class SlidingToolbar: UIViewController {
    
    public var delegate: SlidingToolbarDelegate?
    
    /// Supplying buttons for the toolbar.
    public var buttons: [ToolbarButton] = [ToolbarButton]() {
        didSet {
            contentViewController.toolbarView.toolbarButtons = buttons
        }
    }
    
    /// Setting size of the toolbar view.
    public var toolbarSize: CGSize = CGSize(width: 40, height: 100) {
        didSet {
            contentViewController.toolbarView.barSize = toolbarSize
        }
    }
    
    /// View scrolling the content view.
    lazy var scrollView: SliderScrollView = {
        let scroller = SliderScrollView()
        scroller.backgroundColor = .clear
        scroller.bounces = false
        scroller.clipsToBounds = false
        scroller.contentInset = UIEdgeInsets.zero
        scroller.decelerationRate = UIScrollView.DecelerationRate.fast
        scroller.isPagingEnabled = false
        scroller.isDirectionalLockEnabled = false
        scroller.scrollsToTop = false
        scroller.showsVerticalScrollIndicator = false
        scroller.showsHorizontalScrollIndicator = false
        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.delegate = self
        return scroller
    }()
    
    /// Content view controller hosting the toolbar.
    lazy var contentViewController: ToolbarViewController = {
        let controller = ToolbarViewController()
        controller.view.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 0.1)
        controller.toolbarView.side = .left
        controller.toolbarView.tabView.handleTapAction = expand
        return controller
    }()
    
    /// Height of the sliding toolbar grip (percent of total height).
    public var gripHeightMultiplier: CGFloat = 0.5 {
        didSet {
            contentViewController.toolbarView.gripHeightMultiplier = gripHeightMultiplier
        }
    }

    /// Sorted list of offsets in % of contentVC view. from 0 to 1
    public var offsets: [CGFloat] {
        get {
            return self.scrollView.offsets
        }
        set {
            if newValue.count > 0 {
                self.scrollView.offsets = newValue
            }
        }
    }
    
    /// Position of the sliding toolbar.
    public var position: SlidingToolbarPosition { return self.scrollView.position }
    
    /// Current offset of the sliding toolbar.
    public var currentOffsetIndex: Int { return self.scrollView.offsetIndex }
    
    /// Returns a bool for determining if sliding toolbar is closed or not.
    public var isOpen: Bool { return self.scrollView.isOpen }
    
    /// If true enabling swipe motion to close the sliding toolbar.
    public var disableDraggingToClose: Bool = false
    
    /// Initializator of the object, it requires the parent view controller to build its components.
    /// - Parameters:
    ///   - parent: parent class hosting the sliding toolbar
    ///   - side: position of sliding toolbar { left or right }
    ///   - offsets: array of offsets in % (0 to 1)
    public init(parent: UIViewController, attachedTo side: SlidingToolbarPosition, withOffsets offsets: [CGFloat]) {
        super.init(nibName: nil, bundle: nil)
        
        // Setup view controller containment.
        parent.addChild(self)
        parent.view.addSubview(scrollView)
        self.didMove(toParent: parent)
        
        scrollView.addSubview(contentViewController.toolbarView)
        contentViewController.toolbarView.side = side
        contentViewController.toolbarView.tabView.handleTapAction = expand
        
        self.setupContent(parent: parent, attachedTo: side, withOffsets: offsets)
    }
    
    /// Setup for the scroll view
    /// - Parameters:
    ///   - parent: parent class hosting the sliding toolbar
    ///   - side: position of sliding toolbar { left or right }
    ///   - offsets: array of offsets in % (0 to 1)
    public func setupContent(parent: UIViewController, attachedTo side: SlidingToolbarPosition, withOffsets offsets: [CGFloat]) {
        self.scrollView.parent = parent
        self.scrollView.position = side
        self.scrollView.offsets = offsets
        self.scrollView.contentWidth = contentViewController.view.bounds.width
        self.scrollView.content = contentViewController.toolbarView
        self.scrollView.delegate = self
        self.scrollView.isOpenState = displayToolbarGrip
        self.close()
    }
    
    /// Init Disabled
    /// - Parameter aDecoder:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Manages rotation events.
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.changeOffset(to: self.currentOffsetIndex, animated: true)
        }) { _ in
        }
    }
    
    /// Increase the position of the slider view by one in the list of offsets.
    public func expand() {
        self.delegate?.slidingToolbarWillExpand(self)
        self.scrollView.expandWithCompletion(completion: { (_) in
            self.delegate?.slidingToolbarDidExpand(self)
        })
    }
    
    /// Decrease the position of the slider view by one in the list of offsets.
    public func collapse() {
        self.delegate?.slidingToolbarWillCollapse(self)
        self.scrollView.collapseWithCompletion(completion: { (_) in
            self.delegate?.slidingToolbarDidCollapse(self)
        })
    }
    
    /// Moves the slider view directly to the first offset which is the default position.
    public func close() {
        self.delegate?.slidingToolbarWillCollapse(self)
        self.scrollView.closeWithCompletion(completion: { (_) in
            self.delegate?.slidingToolbarDidCollapse(self)
        })
    }
    
    /// Manages display of the toolbar grip.
    /// - Parameter isOpen: current position of the slider, closed or open.
    func displayToolbarGrip(_ isOpen: Bool) {
        contentViewController.toolbarView.isGripVisible = isOpen ? false : true
    }
}

// MARK: - UIScrollView Delegate
@available(iOS 9.0, *)
extension SlidingToolbar: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.slidingToolbar(self, didChangeOffset: scrollView.contentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        changeOffset(to: self.nearestOffsetIndex(to: scrollView.contentOffset), animated: false)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
}

@available(iOS 9.0, *)
extension SlidingToolbar {
    
    /// Change offset of view.
    /// - Parameters:
    ///   - offsetIndex: new offset parameter needs to be within offsets Array count list.
    ///   - animated: animates the offset change
    public func changeOffset(to offsetIndex: Int, animated: Bool) {
        if self.currentOffsetIndex < offsetIndex {
            self.delegate?.slidingToolbarWillExpand(self)
        } else if offsetIndex < self.currentOffsetIndex {
            self.delegate?.slidingToolbarWillCollapse(self)
        }
        
        self.scrollView.changeOffsetTo(offsetIndex: offsetIndex, animated: animated, completion: { (_) in
            if self.currentOffsetIndex < offsetIndex {
                self.delegate?.slidingToolbarDidExpand(self)
            } else {
                self.delegate?.slidingToolbarDidCollapse(self)
            }
        })
    }
    
    /// Approximates the nearest offset index to given point.
    /// - Parameter contentOffset: given point for which an offset index is calculated.
    func nearestOffsetIndex(to contentOffset: CGPoint) -> Int {
        var nearest: (index: Int, distance: CGFloat) = (0, .greatestFiniteMagnitude)
        let position: CGFloat = contentOffset.x
        let width: CGFloat = self.scrollView.bounds.width
        
        for i in 0 ..< self.offsets.count {
            let step: CGFloat = self.scrollView.offsets[i] * width
            let distance: CGFloat = abs(position - step)
            nearest = distance < nearest.distance ? (i,distance) : nearest
        }
        
        return (nearest.index == 0 && self.disableDraggingToClose) ? 1 : nearest.index
    }
}
