import Foundation

class GidAssembler1 {
	class Token: CustomStringConvertible {
		func getLength () -> Int? {return 1}
		
		func getValue () -> [Int]? {return nil}
		
		var description: String {return "Token"}
	}
	
	enum MathOp {
		case add
		case subtract
		case mutliply
		case divide
		case modulo
		
		var function: (Int, Int) -> Int {
			switch self {
				case .add: 			return {$0 + $1}
				case .subtract: 	return {$0 - $1}
				case .mutliply: 	return {$0 * $1}
				case .divide: 		return {$0 / $1}
				case .modulo: 		return {$0 % $1}
			}
		}
	}
	
	class Expression: Token {
		override var description: String {return "Expression"}
	}
	
	class BadExpression: Expression {
		let contents: String
		let error: String
		
		init (contents: String, error: String) {
			self.contents = contents
			self.error = error
		}
		override func getLength() -> Int? {return nil}
		override func getValue() -> [Int]? {return nil}
		
		override var description: String {return "Bad Expression: " + contents + ", Error: " + error}
	}
	
	class Macro: Expression {
		let name: String
		let symbolTable: FloatingTable
		
		init (name: String, symbolTable: FloatingTable) {
			self.name = name
			self.symbolTable = symbolTable
		}
		
		override func getValue() -> [Int]? {
			if let value = symbolTable.value[name] {return [value]}; return nil
		}
		
		override var description: String {return "Macro: " + name}
	}
	
	class ComplexExpression: Expression {
		let isNegative: Bool
		let leftSide: Expression
		let mathOp: MathOp
		let rightSide: Expression
		
		init (isNegative: Bool, leftSide: Expression, mathOp: MathOp , rightSide: Expression) {
			self.isNegative = isNegative
			self.leftSide = leftSide
			self.mathOp = mathOp
			self.rightSide = rightSide
		}
		
		override func getValue() -> [Int]? {
			guard let left = leftSide.getValue()?[0], let right = rightSide.getValue()?[0] else {
				return nil
			}
			let realLeft = isNegative ? -left : left
			return [mathOp.function(realLeft, right)]
		}
		
		override var description: String {
			let op: String
			switch mathOp {
			case .add: op = " + "
			case .subtract: op = " - "
			case .mutliply: op = " * "
			case .divide: op = " / "
			case .modulo: op = " % "
			}
			return "Complex Expression: " + (isNegative ? "- " : " ") + leftSide.description + op + rightSide.description
			
		}
	}
	
	class Number: Expression {
		let value: Int
		
		init (value: Int) {
			self.value = value
		}
		
		override func getValue() -> [Int]? {
			return [value]
		}
		
		override var description: String {return "Number: " + String(value)}
	}
	
	class CharacterToken: Expression {
		let character: Character
		
		init (character: Character) {
			self.character = character
		}
		
		override func getValue() -> [Int]? {
			return [Int(character.unicodeScalars.first!.value)]
		}
		
		override var description: String {return "Character: " + String(character)}
	}
	
	class InstructionToken: Token {
		let value: Instruction
		
		init? (name: String) {
			if let instruction = Instruction.forAssembler[name] {
				value = instruction
			} else {
				return nil
			}
		}
		
		override func getValue() -> [Int]? {
			return [value.opCode]
		}
		
		override var description: String {return "Instruction: " + value.name + "/" + String(value.opCode)}
	}
	
	class Allocation: Token {
		let length: Expression
		
		init (length: Expression) {
			self.length = length
		}
		
		override func getLength() -> Int? {
			return length.getValue()?[0]
		}
		
		override func getValue() -> [Int]? {
			if let length = getLength() {
				return Array<Int>(repeating: 0, count: length)
			}
			return nil
		}
		
		override var description: String {return "Allocation: " + length.description}
	}
	
	class StringToken: Token {
		let hasLength: Bool
		let string: String
		
		init (hasLength: Bool, string: String) {
			self.hasLength = hasLength
			self.string = string
		}
		
		override func getLength() -> Int? {
			return string.unicodeScalars.count + (hasLength ? 1 : 0)
		}
		
		override func getValue() -> [Int]? {
			var head = hasLength ? [string.unicodeScalars.count] : []
			head += string.unicodeScalars.lazy.map{Int($0.value)}
			return head
		}
		
		override var description: String {return "String: " + string + ", Has Length: " + String(hasLength)}
	}
	
	class MacroDefinition: Token {
		let name: String
		
		init (name: String) {
			self.name = name
		}
		
		override func getLength() -> Int? {return 0}
		override func getValue() -> [Int]? {return []}
		
		override var description: String {return "Macro Definition: " + name}
	}
	
	class Label: MacroDefinition {
		override var description: String {return "Label: " + name}
	}
	
	class Constant: MacroDefinition {
		let value: Expression
		
		init (name: String, value: Expression) {
			self.value = value
			super.init(name: name)
		}
		
		override var description: String {return "Constant: " + name + " = " + value.description}
	}
	
	class Comment: Token {
		let contents: String
		
		init (contents: String) {
			self.contents = contents
		}
		override func getLength() -> Int? {return 0}
		override func getValue() -> [Int]? {return []}
		
		override var description: String {return "Comment: " + contents}
	}
	
	class BadToken: Token {
		let contents: String
		let error: String
		
		init (contents: String, error: String) {
			self.contents = contents
			self.error = error
		}
		override func getLength() -> Int? {return nil}
		override func getValue() -> [Int]? {return nil}
		
		override var description: String {return "Bad Token: " + contents + ", Error: " + error}
	}
	
	//=========================================================
	
	typealias FloatingTable = Wrapper<[String: Int]>
	
	//=========================================================
	
	var symbolTable =  FloatingTable(["r1": 1,
									  "r2": 2,
									  "r3": 3,
									  "r4": 4,
									  "r5": 5,
									  "r6": 6,
									  "r7": 7,
									  "r8": 8,
									  "r9": 9,
									  "r0": 0,
									  "SPACE": 32,
									  "NEWLINE": 10,
									  "TAB": 9,
									  ])
	var tokens = [[Token]]()
	
	var isBad = false
	var isRecursive = true
	var undefindedMacros = [Token]()
	var doubledMacros = Set<String>()
	
	var assembled: [Int]? = nil
	
	var program: String
	
	init (program: String) {
		self.program = program
		self.tokens = tokenize()
		if !isBad {
			isRecursive = !symbolize()
			
			if !isRecursive && checkAll() {
				assembled = assemblize()
			}
		}
	}
	
	//=========================================================
	
	func trimEndSpace (_ string: [Character]) -> [Character]{
		if string == [] {return []}
		let end = string.lastIndex(where: {!isWhiteSpace($0)})
		let start = string.firstIndex(where: {!isWhiteSpace($0)})
		
		if start == nil && end == nil {
			return []
		}
		
		return Array(string[(start ?? 0)...(end ?? (string.count-1))])
	}
	
	//=========================================================
	
	func tokenize () -> [[Token]] {
		return chunk(program).map{tokenize(line: $0)}
	}
	
	func chunk (_ program: String) -> [[Character]] {
		return program.split(whereSeparator: {"\n|".contains($0)}).map{trimEndSpace(Array($0))}
	}
	
	func tokenize (line string: [Character]) -> [Token] {
		if string.count == 0 {
			return []
		}
		
		switch string[0] {
		case "$":
			return tokenize(macroDefinition: Array(string.dropFirst()))
		case ".":
			return tokenize(value: Array(string.dropFirst()))
		case ";":
			return [Comment(contents: String(string.dropFirst()))]
		default:
			if isAlpha(string.first!) {
				return tokenize(instruction: string)
			}
			isBad = true
			return [BadToken(contents: String(string), error: "Line should start with one of the following:\n$ for macro declaration,\n. for variables stored in memory,\n; for a comment,\n an upper or lowercase letter for an instruction.")]
		}
	}
	
	func tokenize (instruction string: [Character]) -> [Token] {
		let endInstruction = string.firstIndex(where: {isWhiteSpace($0)}) ?? string.count
		if endInstruction == 0 {
			return []
		}
		
		var output = [Token]()
		
		let instructionString = String(string[0..<endInstruction]).lowercased()
		if let instructionToken = InstructionToken(name: instructionString) {
			output.append(instructionToken)
		} else {
			isBad = true
			output.append(BadToken(contents: instructionString, error: "Not a valid instruction"))
		}
		
		var buffer = [Character]()
		var depth = 0
		for character in string[endInstruction..<string.count] {
			if isWhiteSpace(character) && depth == 0{
				let next = trimEndSpace(buffer)
				if next.count > 0 {
					output.append(tokenize(expression: next))
				}
				buffer = []
				continue
			}
			
			if character == "(" {depth += 1}
			
			if character == ")" {depth -= 1}
			
			buffer.append(character)
		}
		let next = trimEndSpace(buffer)
		if next.count > 0 {
			output.append(tokenize(expression: next))
		}
		
		if depth != 0 {
			isBad = true
			output.append(BadToken(contents: String(string), error: "No end to Expression"))
		}
		
		return output
	}
	
	func tokenize (value string: [Character]) -> [Token] {
		if string.count == 0 {
			return []
		}
		
		switch string[0]{
		case "$", "#", "(", "@":
			return [tokenize(expression: string)]
		case "\"", "'":
			return [tokenize(string: string)]
		default:
			if let endWord = string.firstIndex(where: {isWhiteSpace($0)}) {
				let word = String(string[0..<endWord])
				let rest = trimEndSpace(Array(string[endWord..<string.count]))
				switch word.uppercased() {
				case "ALLOCATE":
					if rest.count <= 1 {
						isBad = true
						return [BadToken(contents: String(string), error: "An expression is required after an allocation.")]
					} else {
						return [Allocation(length: tokenize(expression: rest))]
					}
				default:
					isBad = true
					return [BadToken(contents: String(string), error: "That is not a valid value to store.")]
				}
			} else {
				isBad = true
				return [BadToken(contents: String(string), error: "That is not a valid value to store.")]
			}
		}
	}
	
	func tokenize (string: [Character]) -> StringToken {
		var buffer = ""
		let type = string[0]
		var index = 1
		
		while index < string.count - 1 {
			if string[index] == "\\" {
				index += 1
				switch string[index] {
				case "n":
					buffer.append("\n")
				case "t":
					buffer.append("\t")
				case "\\":
					buffer.append("\\")
				case "/":
					buffer.append("|")
				case type:
					buffer.append(type)
				default:
					buffer.append("\\")
					buffer.append(string[index])
				}
			} else {
				buffer.append(string[index])
			}
			
			index += 1
		}
		
		return StringToken(hasLength: type == "\"", string: buffer)
	}
	
	func tokenize (macroDefinition string: [Character]) -> [Token] {
		
		let maybeEndNameLocation = string.firstIndex(where: {!isAlphaNum($0)})
		let name = String(string[0..<(maybeEndNameLocation ??  string.count)])
		
		guard let endNameLocation = maybeEndNameLocation else {
			isBad = true
			return [BadToken(contents: String(string), error: "If you wish to store the value of the macro in memory, place a . before the $.")]
		}
		
		switch string[endNameLocation] {
		case ":":
			return [Label(name: name)] + tokenize(line: trimEndSpace(Array(string[(endNameLocation+1)..<string.count])))
		case "=":
			let rest = Array(string[endNameLocation+1..<string.count])
			if trimEndSpace(rest).count == 0 {
				isBad = true
				return [BadToken(contents: String(string), error: "An expression is required after a constant definition.")]
			}
			return [Constant(name: name, value: tokenize(expression: rest))]
		case " ":
			isBad = true
			return [BadToken(contents: String(string), error: "If you wish to store the value of the macro in memory, place a . before the $. If you meant to define a constant, remove the space between the name and the =.")]
		default:
			isBad = true
			return [BadToken(contents: String(string), error: "Invalid character in name of macro.")]
		}
	}
	
	func tokenize (expression: [Character]) -> Expression {
		let string = trimEndSpace(expression)
		
		switch string[0] {
		case "$":
			let endNameLocation = string[1..<string.count].firstIndex(where: {!isAlphaNum($0)})  ?? string.count
			let name = String(string[1..<endNameLocation])
			
			if endNameLocation == string.count {
				return Macro(name: name, symbolTable: symbolTable)
			}
			isBad = true
			return BadExpression(contents: String(string), error: "There were extra characters after the end of the macro.")
			
		case "#":
			let endNumberLocation = string[1..<string.count].firstIndex(where: {!isNum($0) && $0 != "-"})  ??  string.count
			let maybeNumber = Int(String(string[1..<endNumberLocation]))
			
			
			if let number = maybeNumber {
				if endNumberLocation == string.count {
					return Number(value: number)
				}
				isBad = true
				return BadExpression(contents: String(string), error: "There were extra characters after the end of the number.")
			}
			isBad = true
			return BadExpression(contents: String(string), error: "Invalid number.")
		
		case "@":
			if string.count < 2 {
				isBad = true
				return BadExpression(contents: String(string), error: "Invalid number.")
			}
			
			return CharacterToken(character: string[1])
		
		case "(":
			return tokenize(complexExpression: string)
			
		default:
			isBad = true
			return BadExpression(contents: String(string), error: "An expression must begin with $, #, or (.")
		}
	}
	
	func tokenize (complexExpression string: [Character]) -> Expression {
		var body = trimEndSpace(Array(trimEndSpace(string)[1..<(string.count-1)]))
		
		let isNegative = (body[0] == "-")
		var leftSide: Expression
		let mathOp: MathOp
		var rightSide: Expression
		
		if isNegative {body = trimEndSpace(Array(body[1..<body.count]))}
		
			
		//Macro Dothing
		if body[0] == "(" {
			var index = 1
			var depth = 1
			while (depth > 0) {
				if index < body.count {
					switch body[index] {
					case "(":
						depth += 1
					case ")":
						depth -= 1
					default:
						break
					}
					
					index += 1
				} else {
					isBad = true
					return BadExpression(contents: String(string), error: "No close parenthesis.")
				}
			}
			leftSide = tokenize(complexExpression: Array(body[0..<index]))
			body = trimEndSpace(Array(body[index..<body.count]))
				
		} else {
			if let endExpression = body.firstIndex(where: {return isWhiteSpace($0) || "+*/%".contains($0)}) {
				leftSide = tokenize(expression: Array(body[0..<endExpression]))
				body = trimEndSpace(Array(body[endExpression..<body.count]))
			} else {
				isBad = true
				return BadExpression(contents: String(string), error: "No end to first expression.")
			}
		}
		//End Macro
		
		switch body.first {
		case "+":	mathOp = .add
		case "-":	mathOp = .subtract
		case "*":	mathOp = .mutliply
		case "/":	mathOp = .divide
		case "%":	mathOp = .modulo
		case nil:
			isBad = true
			return BadExpression(contents: String(string), error: "Invalid math operator")
		default:
			isBad = true
			return BadExpression(contents: String(string), error: "Invalid math operator")
		}
		
		body = trimEndSpace(Array(body[1..<body.count]))
		
		//Macro Dothing
		if body[0] == "(" {
			var index = 1
			var depth = 1
			while (depth > 0) {
				if index < body.count {
					switch body[index] {
					case "(":
						depth += 1
					case ")":
						depth -= 1
					default:
						break
					}
					
					index += 1
				} else {
					isBad = true
					return BadExpression(contents: String(string), error: "No close parenthesis.")
				}
			}
			rightSide = tokenize(complexExpression: Array(body[0..<index]))
			body = trimEndSpace(Array(body[index..<body.count]))
			
		} else {
			let endExpression = body.firstIndex(where: {return isWhiteSpace($0)}) ?? body.count
			rightSide = tokenize(expression: Array(body[0..<endExpression]))
				//body = trimEndSpace(Array(body[endExpression..<body.count]))
		}
		//End Macro
		
		return ComplexExpression(isNegative: isNegative, leftSide: leftSide, mathOp: mathOp, rightSide: rightSide)
		
	}
	
	//===========================================================
	
	func symbolize () -> Bool {
		var allPresent = true
		var updated = false
		var index: Int? = 0
		
		for line in tokens {
			for token in line {
				if let label = token as? Label {
					if symbolTable.value[label.name] == nil {
						if let trueIndex = index {
							symbolTable.value[label.name] = trueIndex
							updated = true
						} else {
							allPresent = false
						}
					}
				}
				
				if let constant = token as? Constant {
					if symbolTable.value[constant.name] == nil {
						if let result = constant.value.getValue() {
							symbolTable.value[constant.name] = result[0]
							updated = true
						} else {
							allPresent = false
						}
					}
				}
				
				let length = token.getLength()
				if length == nil {
					index = nil
				} else if index != nil {
					index! += length!
				}
			}
		}
		
		if updated {
			return symbolize()
		} else {
			return (index != nil) && allPresent
		}
	}
	
	func checkAll () -> Bool {
		var checkSet = Set<String>()
		
		for line in tokens {
			for token in line {
				if let definition = token as? MacroDefinition {
					if checkSet.contains(definition.name) {
						doubledMacros.insert(definition.name)
					}
					checkSet.insert(definition.name)
				}
				
				if token.getValue() == nil {
					undefindedMacros.append(token)
				}
			}
		}
		
		if !symbolTable.value.keys.contains("START") {
			symbolTable.value["START"] = 0
		}
		
		return doubledMacros.isEmpty && undefindedMacros.isEmpty
	}
	
	//===========================================================
	
	func assemblize () -> [Int] {
		var output = [0, symbolTable.value["START"]!]
		
		for line in tokens {
			for token in line {
				output += token.getValue()!
			}
		}
		
		output[0] = output.count - 2
		
		return output
	}
	
	//============================================================
	
	func symTable () -> String {
		var out = ""
		for (macro, val) in symbolTable.value {
			out += "\(macro) \(val)\n"
		}
		
		return String(out.dropLast())
	}
	
	func programFile () -> String {
		var out = ""
		for num in assembled ?? [] {
			out += "\(num)\n"
		}
		
		return String(out.dropLast())
	}
	
	func listFile () -> String {
		var output = ""
		let lines = program.split(whereSeparator: {"\n|".contains($0)})
		var counter: Int? = 0
		for i in 0..<lines.count {
			var outLine: String
			if counter != nil {
				outLine = "\(counter!):"
			} else {
				outLine = "?:"
			}
			
			outLine = outLine.padding(toLength: 6, withPad: " ", startingAt: 0)
			
			
			var errors = [String]()
			var assembledLine: [Any]? = [Any]()
			for token in tokens[i] {
				if let outVals = token.getValue() {
					assembledLine? += (outVals as [Any])
				} else if let macro = token as? Macro {
					assembledLine?.append(macro.name)
				} else {
					assembledLine = nil
					errors.append(token.description)
				}
				
				if let length = token.getLength() {
					counter? += length
				} else {
					counter = nil
				}
			}
			
			if let firstFourSlice = assembledLine?[0..<min(4,assembledLine!.count)] {
				let firstFour = Array(firstFourSlice)
				outLine += String(firstFour.map{"\($0)"}.joined(separator: " "))
			}
			
			output += outLine.padding(toLength: 30, withPad: " ", startingAt: 0) + " "
			
			output += lines[i]
			output += " "
			if errors.count > 0 {
				output += "Error Tokens: "
				output += errors.joined(separator: " ")
			}
			
			output += "\n"
		}
		
		if undefindedMacros.count > 0 {
			output += "\nUndefined Macros:\n"
			for token in undefindedMacros {
				if let macro = token as? Macro {
					output += macro.name
					output += "\n"
				}
			}
		}
		return output
	}
}

