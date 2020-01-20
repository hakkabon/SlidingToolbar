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
    
    /// Delegate method to notify invoke object when offset has changed
    /// - Parameters:
    ///   - slidingToolbar: the sliding toolbar object
    ///   - offset: current sliding offset in points
    func slidingToolbar(_ slidingToolbar: SlidingToolbar, didChangeOffset offset: CGPoint)
    
    /// Delegate method to notify invoke object when glideView will increase offset by one
    /// - Parameter slidingToolbar: the sliding toolbar object
    func slidingToolbarWillExpand(_ slidingToolbar: SlidingToolbar)
    
    /// Delegate method to notify invoke object when glideView will decrease offset by one
    /// - Parameter slidingToolbar: the sliding toolbar object
    func slidingToolbarWillCollapse(_ slidingToolbar: SlidingToolbar)
    
    /// Delegate method to notify invoke object when glideView did increase offset by one
    /// - Parameter slidingToolbar: the sliding toolbar object
    func slidingToolbarDidExpand(_ slidingToolbar: SlidingToolbar)
    
    /// Delegate method to notify invoke object when glideView did decrease offset by one
    /// - Parameter slidingToolbar: the sliding toolbar object
    func slidingToolbarDidCollapse(_ slidingToolbar: SlidingToolbar)
}

public enum SlidingToolbarPosition {
    case left
    case right
}

@available(iOS 9.0, *)
public class SlidingToolbar: UIViewController, UIScrollViewDelegate {

    public var delegate: SlidingToolbarDelegate?

    public var buttons: [ToolbarButton] = [ToolbarButton]() {
        didSet {
            contentViewController.toolbarView.toolbarButtons = buttons
        }
    }

    public var barSize: CGSize = CGSize(width: 40, height: 100) {
        didSet {
            contentViewController.toolbarView.barSize = barSize
        }
    }

    /// View scrolling the content view.
    public private(set) var scrollView: SliderScrollView!

    /// Content view Controller hosted on the scrollView
    public private(set) var contentViewController: ToolbarViewController!

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
    public private(set) var placement: SlidingToolbarPosition {
        get {
            return self.scrollView.placement
        }
        set { }
    }

    /// Current offset of the sliding toolbar.
    public private(set) var currentOffsetIndex: Int {
        get {
            return self.scrollView.offsetIndex
        }
        set { }
    }

    /// Returns a bool for determining if sliding toolbar is closed or not.
    public private(set) var isOpen: Bool {
        get {
            return self.scrollView.isOpen
        }
        set { }
    }

    /// If true enabling swipe motion to close the sliding toolbar.
    public var disableDraggingToClose: Bool = false
    
    /// Initializator of the object, it requires the parent view controller to build its components
    /// - Parameters:
    ///   - parent: Parent class hosting sliding toolbar.
    ///   - side: Side attachment of sliding toolbar { left or right }.
    ///   - offsets: Array of offsets in % (0 to 1).
    public init(parent: UIViewController, attachedTo side: SlidingToolbarPosition, withOffsets offsets: [CGFloat]) {
        super.init(nibName: nil, bundle: nil)
        
        // Make toolbar swipable depending on its attached side.
        self.scrollView = SliderScrollView.init(frame: parent.view.bounds)

        // Setup view controller containment.
        parent.view.addSubview(self.scrollView)
        parent.addChild(self)
        self.didMove(toParent: parent)
        
        self.contentViewController = ToolbarViewController()
        self.contentViewController.toolbarView.side = side
        self.contentViewController.tapToolbarAction = expand

        self.setupContent(content: self.contentViewController, attachedTo: side, withOffsets: offsets)
    }

    /// Init Disabled
    /// - Parameter aDecoder:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Change content type and offsets after the VC has been initialized.
    /// - Parameters:
    ///   - side: side to which the sliding toolbar is attached, one of { left | top | right | bottom }.
    ///   - offsets: list of offsets in % (0 to 1) in regards to given leeway.
    public func setupContent(content: ToolbarViewController, attachedTo side: SlidingToolbarPosition, withOffsets offsets: [CGFloat]) {
        self.parent?.automaticallyAdjustsScrollViewInsets = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollView.placement = side
        self.scrollView.offsets = offsets
        self.scrollView.content = content.view
        self.scrollView.delegate = self
        self.scrollView.isOpenState = manageState
        self.close()
    }
    
    /// Increase the position of the slider view by one in the list of offsets
    public func expand() {
        self.delegate?.slidingToolbarWillExpand(self)
        self.scrollView.expandWithCompletion(completion: { (_) in
            self.delegate?.slidingToolbarDidExpand(self)
        })
    }

    /// Decrease the position of the slider view by one in the list of offsets
    public func collapse() {
        self.delegate?.slidingToolbarWillCollapse(self)
        self.scrollView.collapseWithCompletion(completion: { (_) in
            self.delegate?.slidingToolbarDidCollapse(self)
        })
    }

    /// This method moves the slider view directly to the first offset which is the default position.
    public func close() {
        self.delegate?.slidingToolbarWillCollapse(self)
        self.scrollView.closeWithCompletion(completion: { (_) in
            self.delegate?.slidingToolbarDidCollapse(self)
        })
    }
    
    /// Manage diaplay of grip.
    /// - Parameter isOpen: current display state of the grip.
    func manageState(_ isOpen: Bool) {
        if isOpen {
            contentViewController.toolbarView.isGripVisible = false
        } else {
            contentViewController.toolbarView.isGripVisible = true
        }
    }

    /// Change offset of view.
    /// - Parameters:
    ///   - offsetIndex: new Offset of GlideView, parameter needs to be within offsets Array count list.
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

// MARK: - UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.slidingToolbar(self, didChangeOffset: scrollView.contentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.changeOffset(to: self.nearestOffsetIndex(to: scrollView.contentOffset), animated: false)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }

// MARK: - private Methods
    
    /// Approximates the nearest offset index to given point.
    /// - Parameter contentOffset: given point for which an offset index is calculated.
    func nearestOffsetIndex(to contentOffset: CGPoint) -> Int {
        var index: Int = 0
        let offset: CGFloat = contentOffset.x
        let threshold: CGFloat = self.scrollView.content!.frame.width
        var distance: CGFloat = CGFloat.greatestFiniteMagnitude

        for i in 0 ..< self.offsets.count {
            let transformedOffset: CGFloat = self.scrollView.offsets[i] * threshold
            let distToAnchor: CGFloat = abs(offset - transformedOffset)
            if distToAnchor < distance {
                distance = distToAnchor
                index = i
            }
        }

        return (index == 0 && self.disableDraggingToClose) ? 1 : index
    }

// MARK: - Rotation event

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.changeOffset(to: self.currentOffsetIndex, animated: true)
        }) { _ in
            self.scrollView.recalculateContentSize()
        }
    }
}
