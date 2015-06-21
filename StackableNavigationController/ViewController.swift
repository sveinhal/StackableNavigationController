//
//  ViewController.swift
//  StackableNavigationController
//
//  Created by Svein Halvor Halvorsen on 21.06.15.
//  Copyright (c) 2015 Svein Halvor Halvorsen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pushButton: UIButton!

    struct Counter {
        static var counter: Int = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randomColor()
        title = Counter.counter++.description
    }

    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override var nibName: String {
        return "ViewController"
    }

    @IBAction func push(sender: AnyObject) {
        let vc = ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func new(sender: AnyObject) {
        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.stackableNavigationController?.viewControllers.append(nav)
        navigationController?.stackableNavigationController?.selectedViewController = nav
    }

    @IBAction func remove(sender: AnyObject) {
        if let nav = navigationController,
            stack = nav.stackableNavigationController,
            index = find(stack.viewControllers, nav)
        {
            if stack.viewControllers.count == 1 {
                return
            }
            stack.viewControllers.removeAtIndex(index)
        }
    }

}

extension UIColor {
    static func randomColor() -> UIColor {
        let r = CGFloat.random()
        let g = CGFloat.random()
        let b = CGFloat.random()
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension CGFloat {
    static func random(max: CGFloat = 1.0) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max) * max
    }
}
