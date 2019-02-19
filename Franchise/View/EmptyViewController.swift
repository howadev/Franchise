//
//  File.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-18.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import UIKit
import SnapKit

final class EmptyViewController: UIViewController {
    private let messageLabel = UILabel()
    
    init(message: String) {
        super.init(nibName: nil, bundle: nil)
        messageLabel.text = message
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
            make.center.equalToSuperview()
        }
    }
}
