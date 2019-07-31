//
//  Node.swift
//  DataStructures&Algorithms
//
//  Created by Dmitry Melnikov on 30/07/2019.
//  Copyright © 2019 Dmitry Melnikov. All rights reserved.
//

import Foundation

class Node<T> {
    
    // Здесь мы будем хранить значение нашего контейнера
    let value: T
    
    // Эти свойства используем для хранения связей между контейнерами
    var next: Node?
    weak var previous: Node?
    
    init(value: T, next: Node? = nil, previous: Node? = nil) {
        self.value = value
        self.next = next
        self.previous = previous
    }
}

extension Node: WeakReferencePotocol {
    // Слабая ссылка нам пригодится, когда мы будем реализовывать copy-on-write
    var weakReference: WeakReference<Node<T>> {
        return WeakReference(node: self)
    }
}

// MARK: - Debug only
extension Node: CustomStringConvertible {
    
    var description: String {
        
        guard let next = next else { return "\(value)"}
        return "\(value) -> \(next.description)"
    }
}
