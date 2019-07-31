//
//  main.swift
//  DataStructures&Algorithms
//
//  Created by Dmitry Melnikov on 30/07/2019.
//  Copyright © 2019 Dmitry Melnikov. All rights reserved.
//

import Foundation

// MARK: - LinkedList<T>
var linkedList = LinkedList<Int>()

linkedList.insertFirst(6)
linkedList.insertFirst(5)
linkedList.insertFirst(4)
linkedList.insertFirst(3)
linkedList.insertFirst(2)
linkedList.insertFirst(1)

print(linkedList) // 1 -> 2 -> 3 -> 4 -> 5 -> 6
print("\n")

linkedList.append(7)
linkedList.append(8)
linkedList.append(9)

print(linkedList) // 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9
print("\n")

linkedList.insert(10, after: linkedList.last!)
linkedList.insert(666, after: linkedList.first!)

print(linkedList) // 1 -> 69 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9 -> 10
print("\n")

linkedList.remove(after: linkedList.last!)
linkedList.remove(after: linkedList.first!)

print(linkedList) // 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9
print("\n")

linkedList.removeFirst()
linkedList.removeLast()

print(linkedList) // 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8
print("\n")

let secondLinkedList = linkedList.map { String($0 ?? 0) + "0" }

print(secondLinkedList) // [20, 30, 40, 50, 60, 70, 80]
print("\n")

let index = linkedList.index(linkedList.endIndex, offsetBy: -5)

print(index.node!.value) // 4
print("\n")
