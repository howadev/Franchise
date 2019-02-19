//
//  LeagueListViewController.swift
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

final class LeagueListViewController: ContentViewController {
    var selectLeague: Signal<TeamListViewModel, NoError> {
        return viewModel.loaded.signal
            // Ignore not-done values to extract `TeamListViewModel`
            .flatMap(.latest) { loaded -> Signal<TeamListViewModel, NoError> in
                switch loaded {
                case .done(let onceLoaded):
                    return onceLoaded.selectLeague.values
                default:
                    return .empty
                }
            }
    }
    
    private let viewModel = LeagueListViewModel(provider: LeagueListViewModelProvider())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        setUpBindings()
        viewModel.viewDidLoad()
    }
    
    private func setUpSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
                    return LeagueListContentViewController(onceLoaded: onceLoaded)
                case .failed(let error):
                    return ErrorViewController(error: error, reload: reload)
                }
            }
            .startWithValues { [weak self] vc in
                self?.contentViewController = vc
            }
    }
}

extension LeagueListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterLeague.apply(searchController.searchBar.text).start()
    }
}

final class LeagueListContentViewController: UIViewController {
    private let onceLoaded: LeagueListViewModel.OnceLoaded
    
    private let tableView = UITableView()
    
    init(onceLoaded: LeagueListViewModel.OnceLoaded) {
        self.onceLoaded = onceLoaded
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpBindings()
    }
    
    private func setUpTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setUpBindings() {
        onceLoaded.leagues.producer
            .take(duringLifetimeOf: self)
            .skipRepeats()
            .observe(on: UIScheduler())
            .startWithValues { [weak self] _ in
                self?.tableView.reloadData()
            }
    }
}

extension LeagueListContentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onceLoaded.leagues.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let league = onceLoaded.leagues.value[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = league.fullName
        
        return cell
    }
}

extension LeagueListContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let league = onceLoaded.leagues.value[indexPath.row]
        onceLoaded.selectLeague.apply(league).start()
    }
}
