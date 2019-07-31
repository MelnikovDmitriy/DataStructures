//
//  LinkedList.swift
//  DataStructures&Algorithms
//
//  Created by Dmitry Melnikov on 30/07/2019.
//  Copyright © 2019 Dmitry Melnikov. All rights reserved.
//

import Foundation

struct LinkedList<T> {
    
    // хранить в списке мы будем только ссылки на первый и последний контейнеры
    private var firstNode: Node<T>?
    private var lastNode: Node<T>?
    
    // Cвойства для доступа к контейнерам извне. Я использую слабые ссылки, чтобы никто не увеличил счетчик.
    // Могут возникнуть проблемы с ARC и copy-on-write
    var first: WeakReference<Node<T>>? {
        return firstNode?.weakReference
    }
    
    var last: WeakReference<Node<T>>? {
        return lastNode?.weakReference
    }
    
    var isEmpty: Bool {
        return first == nil
    }
    
    // Вызов метода необходимо вставить в каждый из ранее созданных.
    // Как несложно было догадаться, метод отвечает за создание копии списка,
    // если в ней произошли изменения
    private mutating func copyIfNeeded() {
        // Проверим количество сильных ссылок на наш список.
        // Копирование необходимо только, если сильных ссылок больше одной
        guard !isKnownUniquelyReferenced(&firstNode),
            // сохраним первый контейнер исходного списка
            var previous = firstNode else { return }
        // Создаем новый контейнер и помещаем в него значение первого контейнера исходного списка
        // Тепер это наш новый перый контейнер
        firstNode = Node(value: previous.value)
        // Используем current для итерации по новому списку, а previous по старому
        var current = firstNode
        // Пройдемся по всем контейнерам в списке
        while let next = previous.next {
            // в каждой итерации мы создаем новый контейнер и копируем в него значение из исходного списка
            current?.next = Node(value: next.value, previous: current)
            // После просто сдвигаем элементы в списках на один шаг вперед
            current = current?.next
            previous = next
        }
        // в завершении остается присвоить last элементу получившегося списка current-контейнер
        lastNode = current
    }
    
    /// Вставка значения в начало списка
    /// - Complexity: O(1)
    mutating func insertFirst(_ value: T) {
        copyIfNeeded()
        // создаем новый контейнер и передаем ему текущий первый контейнер списка как next
        let node = Node(value: value, next: firstNode)
        // текущему первому контейнеру списка задаем previous. Им будет наш новый контейнер
        firstNode?.previous = node
        // Остается только передать новый контейнер в список как актуальный первый элемент
        firstNode = node
        // если у нас в списке отсутствует последний контейнер (в списке был один элемент)
        if lastNode == nil && firstNode?.next?.next == nil {
            // обновим наш last контейнер
            lastNode = firstNode?.next
        }
    }
    
    /// Вставка значения в конец списка
    /// - Complexity: O(1)
    mutating func append(_ value: T) {
        copyIfNeeded()
        // первым делом проверяем не пуст ли наш список
        guard !isEmpty else {
            // если пуст, то просто вставляем контейнер в начало
            insertFirst(value)
            return
        }
        // создадим новый контейнер и присвоим ему в качестве previous текущий последний контейнер списка
        lastNode?.next = Node(value: value, previous: lastNode)
        // заменим последний контейнер в списке на только что созданный
        lastNode = lastNode?.next
    }
    
    /// Вставка значения после заданного контейнера
    /// - Complexity: O(1)
    mutating func insert(_ value: T, after referenced: WeakReference<Node<T>>) {
        copyIfNeeded()
        // проверяем не ссылается ли наш последний элемент списка на контейнер, переданный в параметре
        guard lastNode !== referenced.node else {
            // если это один и тот же экземпляр класса, просто добавляем новый контейнер в конец нашего списка
            append(value)
            return
        }
        // вставляем новый контейнер между заданным и его next контейнером
        let oldNextNode = referenced.node?.next
        let newNode = Node(value: value, next: oldNextNode, previous: referenced.node)
        // Теперь у нас есть все три учасника перестановки. Расставим их в новом порядке
        oldNextNode?.previous = newNode
        referenced.node?.next = newNode
    }
    
    /// Удаление первого значения в списке
    /// - Complexity: O(1)
    @discardableResult
    mutating func removeFirst() -> T? {
        copyIfNeeded()
        // Еще одна причина задать вопрос: "Почему использовал defer?" в комментариях
        defer {
            // 2 шаг - обновляем первый элемент списка
            firstNode = firstNode?.next
            // нельзя забывать про ссылку на предыдущий контейнер, теперь он вне нашего списка
            firstNode?.previous = nil
            // 3 шаг - если в списке не осталось элементов, необходимо очистить ссылку на последний контейнер
            if isEmpty {
                lastNode = nil
            }
        }
        // 1 шаг - возвращаем текущий первый контейнер из списка
        return firstNode?.value
    }
    
    /// Удаление последнего значения в списке
    /// - Complexity: O(1)
    @discardableResult
    mutating func removeLast() -> T? {
        copyIfNeeded()
        // убедимся, что контейнер в списке не один
        guard firstNode?.next != nil else {
            // если один, то просто удалим его
            removeFirst()
            return nil
        }
        // логика работы функции идентична удалению первого контейнера из списка
        defer {
            lastNode = lastNode?.previous
            lastNode?.next = nil
            
            if isEmpty {
                lastNode = nil
            }
        }
        return lastNode?.value
    }
    
    /// Удаление значения после заданного контейнера
    /// - Complexity: O(1)
    @discardableResult
    mutating func remove(after referenced: WeakReference<Node<T>>) -> T? {
        copyIfNeeded()
        defer {
            // проверим, не оказался ли контейнер-параметр предпоследним в списке
            if referenced.node?.next === lastNode {
                // если это так, то делаем его последним
                lastNode = referenced.node
                lastNode?.next = nil
            }
            // в противном случае меняем контейнер, следующий за контейнером-параментром, на его next
            let newNext = referenced.node?.next?.next
            referenced.node?.next = newNext
            newNext?.previous = referenced.node
        }
        return referenced.node?.next?.value
    }
}

extension LinkedList: BidirectionalCollection {
    // В качестве индекса использовать Int крайне непрактично. Это погубит производительность
    // Пойдем другим путем и напишем специальную структурку, которая будет представлять индекс
    struct Index: Comparable {
        // Контейнер, связанный с индексом. Иначе зачем нам вообще индекс?
        var node: Node<T>?
        
        // Метод протокола Comparable. LinkedList<T>.Index как тип писать не обязательно, достаточно Index
        static func == (lhs: LinkedList<T>.Index, rhs: LinkedList<T>.Index) -> Bool {
            // Логика сравнения следующая: создаем кортеж с контейнерами, на которые указывают наши индексы.
            // Проверяем, ссылаются ли они на один и тот же экземпляр класса
            switch (lhs.node, rhs.node) {
            // Одного единственного case достаточно
            case let (left, right):
                return left === right
            }
        }
        
        // осталось реализовать обязательный метод "<"
        static func < (lhs: LinkedList<T>.Index, rhs: LinkedList<T>.Index) -> Bool {
            guard lhs != rhs else { return false }
            // Создадим последовательность, взяв lhs-контейнер за первый элемент.
            let nodes = sequence(first: lhs.node) { $0?.next }
            // Осталось проверить находится ли rhs-контейнер в сформированной последовательности.
            // Если да, то индекс правее и соотвественно больше и мы возвращаем false
            return nodes.contains { $0 === rhs.node }
        }
    }
    
    // С перым индексом все очень просто. Возвращем индекс first контейнера
    var startIndex: LinkedList<T>.Index {
        return Index(node: firstNode)
    }
    // Аналогично. Возвращаем индекс last контейнера
    var endIndex: LinkedList<T>.Index {
        return Index(node: lastNode)
    }
    // Как видно из сигнатуры, метод возвращет индекс следующий за указанным
    func index(after i: LinkedList<T>.Index) -> LinkedList<T>.Index {
        // Вернем индекс следующего контейнера
        return Index(node: i.node?.next)
    }
    // Метод возвращет предыдущий индекс
    func index(before i: LinkedList<T>.Index) -> LinkedList<T>.Index {
        return Index(node: i.node?.previous)
    }
    // И наконец реализуем subscript. Это даст нам возможность получить значение из нашего списка через []
    // Это будет запись в духе работы с индексами String. Например list[LinkedList.Index(node: yourNode)]
    subscript(position: Index) -> T? {
        // не зря же мы прописали в структуре Index свойство node
        return position.node?.value
    }
}

// MARK: - Debug only
extension LinkedList: CustomStringConvertible {
    
    var description: String {
        return firstNode?.description ?? "Empty list"
    }
}

