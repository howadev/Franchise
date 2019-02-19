//
//  ErrorViewController.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-14.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveSwift
import ReactiveCocoa
import Result

final class ErrorViewController: UIViewController {
    private let messageLabel = UILabel()
    
    private let reloadButton = UIButton(type: .system)
    
    init(error: UserError, reload: Action<(), (), NoError>) {
        super.init(nibName: nil, bundle: nil)
        messageLabel.text = error.message
        reloadButton.reactive.pressed = CocoaAction(reload)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        messageLabel.textAlignment = .center
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY)
        }
        
        let buttonTitle = NSLocalizedString("Reload", comment: "")
        reloadButton.setTitle(buttonTitle, for: .normal)
        view.addSubview(reloadButton)
        reloadButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.centerY)
        }
    }
}
