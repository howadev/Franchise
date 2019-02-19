//
//  AppDelegate.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-13.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window = UIWindow()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let leagueListViewController = LeagueListViewController()
        let masterViewController = UINavigationController(rootViewController: leagueListViewController)
        
        let emptyMessage = NSLocalizedString("Select a league", comment: "")
        let emptyViewController = EmptyViewController(message: emptyMessage)
        let detailViewController = UINavigationController(rootViewController: emptyViewController)
        
        let rootViewController = UISplitViewController()
        rootViewController.viewControllers = [masterViewController, detailViewController]
        rootViewController.preferredDisplayMode = .allVisible
        rootViewController.delegate = self
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        // Show team list when a league is selected
        leagueListViewController.selectLeague
            .take(duringLifetimeOf: self)
            .observe(on: UIScheduler())
            .map(TeamListViewController.init)
            .observeValues { vc in
                let nav = UINavigationController(rootViewController: vc)
                rootViewController.showDetailViewController(nav, sender: nil)
            }
        
        return true
    }
}

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let nav = secondaryViewController as? UINavigationController {
            // It means that the user has never selected a league when the top
            // view controller of detail view controller (`secondaryViewController`)
            // is `EmptyViewController`. In this case, `true` is returned to
            // to prevent to show detail view controller after startup for
            // a horizontal compact size class such as the iPhone.
            return nav.topViewController is EmptyViewController
        }
        return false
    }
}

