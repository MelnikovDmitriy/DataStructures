//
//  WeakReference.swift
//  DataStructures&Algorithms
//
//  Created by Dmitry Melnikov on 31/07/2019.
//  Copyright © 2019 Dmitry Melnikov. All rights reserved.
//

import Foundation

// Associated Types protocols - это модно, молодёжно, но можно было и без них
protocol WeakReferencePotocol: AnyObject {
    associatedtype T
    // я реализую это свойство в классе Node, чтобы copy-on-write техника работала
    // не как у чувака из интернета, а правильно
    var weakReference: WeakReference<Node<T>> { get }
}
// Обёртка, которая используется для хранения слабой ссылки на контейнер
final class WeakReference<T: AnyObject> {
    // private(set) - это модификатор, чтобы свойство нельзя изменить извне
    private(set) weak var node: T?
    
    init(node: T?) {
        self.node = node
    }
}
// Да простят меня адепты мантры "1 класс - 1 файл". Это просто демо проект, ребят
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
