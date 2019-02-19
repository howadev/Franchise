//
//  ContentViewController.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-14.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import UIKit
import SnapKit

class ContentViewController: UIViewController {
    var contentViewController: UIViewController? {
        willSet {
            removeContentViewController(contentViewController)
        }
        didSet {
            addContentViewController(contentViewController)
        }
    }
    
    private func addContentViewController(_ content: UIViewController?) {
        guard let content = content else { return }
        
        addChild(content)
        
        view.addSubview(content.view)
        content.view.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        content.didMove(toParent: self)
    }
    
    private func removeContentViewController(_ content: UIViewController?) {
        guard let content = content else { return }
        
        content.willMove(toParent: nil)
        
        content.view.removeFromSuperview()
        
        content.removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
