import Foundation
import Darwin

class Stack {
	let size = 100
	
	var array = [Int]()
	var register = 0
	
	func push (_ value: Int) {
		if array.count < size {
			register = 0
			array.append(value)
		} else {
			register = 1
		}
	}
	
	func pop () -> Int {
		if let out = array.popLast() {
			register = 0
			return out
		} else {
			register = 2
			exit(1)
		}
	}
}
