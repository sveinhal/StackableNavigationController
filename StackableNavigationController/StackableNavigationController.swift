//
//  StackableNavigationController.swift
//  StackableNavigationController
//
//  Created by Svein Halvor Halvorsen on 21.06.15.
//  Copyright (c) 2015 Svein Halvor Halvorsen. All rights reserved.
//

import UIKit

class StackableNavigationController: UIViewController {

    init(viewControllers: [UINavigationController] = []) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
        selectedViewController = viewControllers.first
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        for viewController in viewControllers {
            removeViewController(viewController)
        }
    }

    var viewControllers: [UINavigationController] = [] {
        didSet {
            //don't animate adding/removing view controllers for now.
            UIView.performWithoutAnimation { [unowned self] in
                let inserted = self.viewControllers.filter{!contains(oldValue, $0)}
                let removed = oldValue.filter{!contains(self.viewControllers, $0)}
                for child in inserted {
                    self.insertViewController(child)
                }
                for child in removed {
                    self.removeViewController(child)
                }
                //make sure that the selected view controller is still in the list.
                if self.selectedViewController == nil {
                    self.selectedViewController = self.viewControllers.first
                }
                if let selected = self.selectedViewController {
                    if !contains(self.viewControllers, selected) {
                        let index = max(find(oldValue, selected)! - 1, 0)
                        self.selectedViewController = self.viewControllers[index]
                    }
                }
                self.view.layoutIfNeeded()
                if (self.viewControllers.first != oldValue.first) {
                    self.viewControllers.first?.resetBarHeight()
                    oldValue.first?.resetBarHeight()
                }
            }
        }
    }

    weak var selectedViewController: UINavigationController? = nil {
        didSet {
            //animate selection change
            view.setNeedsLayout()
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    private var tapGestureRecognizers = [UINavigationController: UITapGestureRecognizer]()

    private func insertViewController(viewController: UINavigationController) {
        if !isViewLoaded() {
            return
        }
        addChildViewController(viewController)
        view.insertSubview(viewController.view, atIndex: find(viewControllers, viewController)!)
        let tap = UITapGestureRecognizer(target: self, action: Selector("didTap:"))
        tap.cancelsTouchesInView = false
        viewController.navigationBar.addGestureRecognizer(tap)
        tapGestureRecognizers[viewController] = tap
        view.setNeedsLayout()
        viewController.didMoveToParentViewController(self)
    }

    private func removeViewController(viewController: UINavigationController) {
        if !isViewLoaded() {
            return
        }
        viewController.willMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        let tap = tapGestureRecognizers.removeValueForKey(viewController)!
        viewController.navigationBar.removeGestureRecognizer(tap)
        view.setNeedsLayout()
        viewController.removeFromParentViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        for viewController in viewControllers {
            insertViewController(viewController)
        }
    }

    override func viewWillLayoutSubviews() {
        //calculate thei height of each child view controller: The total height minus the height of all the bars
        let contentHeight = viewControllers.reduce(view.bounds.size.height, combine: { (height: CGFloat, nav: UINavigationController) -> CGFloat in
            return height - nav.barHeight
        })
        //offset each child view controller from the top. They all have the same height, but are drawn on top of each other.
        var offset: CGFloat = 0.0
        for viewController in viewControllers {
            let barHeight = viewController.barHeight
            viewController.view.frame = CGRect(x: 0, y: offset, width: view.bounds.size.width, height: contentHeight + barHeight)
            offset += barHeight + (viewController == selectedViewController ? contentHeight : 0.0)
        }
    }

    @objc private func didTap(tap: UITapGestureRecognizer) {
        for viewController in viewControllers {
            if viewController.navigationBar == tap.view {
                //implicitly animated
                selectedViewController = viewController
            }
        }
    }

}

extension UINavigationController: UIBarPositioningDelegate {
    var stackableNavigationController: StackableNavigationController? {
        get {
            return self.parentViewController as? StackableNavigationController
        }
    }
    private var barHeight: CGFloat {
        return navigationBar.frame.size.height +
            (self == self.stackableNavigationController?.viewControllers.first
                ? UIApplication.sharedApplication().statusBarFrame.height
                : 0.0)
    }
    private func resetBarHeight() {
        //HACK: Trick UIKit into redrawing the navigation bar.
        //UINavigationController will draw the bar with a height of 64 if the
        //view is positioned at the origin, ie. under the status bar, 44 otherwise.
        //Since we're moving the navigation controllers around, we need to refresh
        //by cycling around the hidden attribute.
        let hidden = navigationBarHidden
        setNavigationBarHidden(!hidden, animated: false)
        setNavigationBarHidden(hidden, animated: false)
    }
}

