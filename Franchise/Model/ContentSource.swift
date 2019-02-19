//
//  ContentSource.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-16.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

/// It's able to reload the provided `source`
final class ContentSource<Value> {
    var values: Signal<Value, NoError> {
        return action.values
    }
    
    var reload: Action<(), (), NoError> {
        return Action<(), (), NoError>(enabledIf: action.isEnabled) { [action] _ in
            action.apply()
                // Discard values
                .map(value: ())
                // Discard errors
                .flatMapError { error in SignalProducer<(), NoError>.empty }
        }
    }
    
    private let action: Action<(), Value, NoError>
    
    private let disposable = CompositeDisposable()
    
    init(source: SignalProducer<Value, NoError>) {
        action = Action { source }
    }
    
    deinit {
        disposable.dispose()
    }
    
    func load() {
        disposable += action.apply().start()
    }
}
