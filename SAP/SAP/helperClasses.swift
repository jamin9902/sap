import Foundation

class GrowingArray <Element>: Collection {
	var array: [Element]
	
	let startIndex = 0
	var endIndex: Int {return array.count}
	
	let defaultValue: Element
	
	init (_ defaultValue: Element) {
		self.array = [Element]()
		self.defaultValue = defaultValue
	}
	
	func index (after i: Int) -> Int {
		return i + 1
	}
	
	func get (_ index: Int) -> Element {
		if index >= array.count {
			return defaultValue
		} else {
			return array[index]
		}
	}
	
	func set (_ index: Int, _ value: Element) {
		if index < array.count {
			array[index] = value
		} else {
			for _ in array.count..<index {
				array.append(defaultValue)
			}
			array.append(value)
		}
	}
	
	func set (to array: [Element]) {
		self.array = array
	}
	
	func export () -> [Element] {
		return array
	}
	
	subscript (_ index: Int) -> Element {
		get {
			return get(index)
		}
		set {
			set(index, newValue)
		}
	}
}

class Wrapper <T> : CustomStringConvertible{
	var value: T
	
	init (_ value: T) {
		self.value = value;
	}
	
	var description: String {
		if let printable = value as? CustomStringConvertible {
			return "Wrapper: " + printable.description
		} else {
			return "Wrapper"
		}
	}
}

class StringPopper {
	let string: String
	var index: String.Index
	
	init (_ string: String) {
		self.string = string
		self.index = string.startIndex
	}
	
	func peek () -> Character? {
		if index < string.endIndex {
			return string[index]
		}
		return nil
	}
	
	func pop () -> Character? {
		let out = peek()
		index = string.index(after: index)
		return out
	}
	
	func increment () {
		index = string.index(after: index)
	}
	
	func rest () -> String {
		return String(string[index..<string.endIndex])
	}
}
