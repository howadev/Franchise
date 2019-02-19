//
//  TeamListViewController.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-14.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import ReactiveSwift
import ReactiveCocoa
import Result

final class TeamListViewController: ContentViewController {
    private let viewModel: TeamListViewModel
    
    init(viewModel: TeamListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpBindings()
        viewModel.viewDidLoad()
    }
    
    private func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    private func setUpBindings() {
        title = viewModel.title
        
        viewModel.loaded.producer
            .take(duringLifetimeOf: self)
            .observe(on: UIScheduler())
            .map { [reload = viewModel.reload] loaded -> UIViewController in
                switch loaded {
                case .loading:
                    return LoadingViewController()
                case .done(let onceLoaded):
                    return TeamListContentViewController(onceLoaded: onceLoaded)
                case .failed(let error):
                    return ErrorViewController(error: error, reload: reload)
                }
            }
            .startWithValues { [weak self] vc in
                self?.contentViewController = vc
            }
    }
}

final class TeamListContentViewController: UIViewController {
    private enum Constants {
        static let cellHeight: CGFloat = 100
    }
    
    private let onceLoaded: TeamListViewModel.OnceLoaded
    
    private let tableView = UITableView()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    init(onceLoaded: TeamListViewModel.OnceLoaded) {
        self.onceLoaded = onceLoaded
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpSearchBar()
        setUpBindings()
    }
    
    private func setUpTableView() {
        tableView.register(TeamListCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.rowHeight = Constants.cellHeight
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setUpSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func setUpBindings() {
        onceLoaded.teams.producer
            .take(duringLifetimeOf: self)
            .skipRepeats()
            .observe(on: UIScheduler())
            .startWithValues { [weak self] _ in
                self?.tableView.reloadData()
            }
    }
}

extension TeamListContentViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        onceLoaded.filterTeam.apply(searchController.searchBar.text).start()
    }
}

extension TeamListContentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onceLoaded.teams.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = onceLoaded.teams.value[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TeamListCell
        cell.selectionStyle = .none
        cell.fullNameLabel.text = team.fullName
        
        if let logoURL = team.logoURL {
            cell.logoImageView.isHidden = false
            cell.logoImageView.kf.setImage(with: logoURL)
        } else if let color = team.color {
            cell.logoImageView.isHidden = false
            cell.logoImageView.backgroundColor = color
        } else {
            cell.logoImageView.isHidden = true
        }
        
        return cell
    }
}

final class TeamListCell: UITableViewCell {
    private enum Constants {
        static let contentInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
        static let imageSize = CGSize(width: 100, height: 100)
        static let spacing: CGFloat = 32
    }
    
    let logoImageView = UIImageView()
    let fullNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.kf.cancelDownloadTask()
        logoImageView.image = nil
        logoImageView.isHidden = true
        
        fullNameLabel.text = nil
    }
    
    private func setUpAppearance() {
        logoImageView.isHidden = true
        
        let stackView = UIStackView(arrangedSubviews: [logoImageView, fullNameLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = Constants.spacing
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Constants.contentInsets)
        }
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(logoImageView.snp.height)
        }
    }
}

