//
//  SignalProducer+Operator.swift
//  Franchise
//
//  Created by Haohua Li on 2019-02-18.
//  Copyright © 2019 Haohua Li. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

extension SignalProducer {
    func valuesAsProperty() -> SignalProducer<Property<Value>, Error> {
        return SignalProducer<Property<Value>, Error> { observer, lifetime in
            var mutableProperty: MutableProperty<Value>?
            
            lifetime += self.start { event in
                switch event {
                case let .value(value):
                    if let property = mutableProperty {
                        property.value = value
                    } else {
                        let property = MutableProperty(value)
                        mutableProperty = property
                        observer.send(value: Property(property))
                    }
                    
                case let .failed(error):
                    observer.send(error: error)
                    
                case .completed:
                    observer.sendCompleted()
                    
                case .interrupted:
                    observer.sendInterrupted()
                }
            }
        }
    }
    
    func toLoaded(_ transform: @escaping (Error) -> UserError) -> SignalProducer<Loaded<Value>, NoError> {
        let initialState = SignalProducer<Loaded<Value>, NoError>(value: .loading)
        let loadedProducer: SignalProducer<Loaded<Value>, NoError> = producer
            .map { Loaded.done($0) }
            .flatMapError { error in
                let loaded: Loaded<Value> = Loaded.failed(transform(error))
                return SignalProducer<Loaded<Value>, NoError>(value: loaded)
            }
        return initialState.concat(loadedProducer)
    }
}
