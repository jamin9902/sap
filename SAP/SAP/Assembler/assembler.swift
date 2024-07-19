import Foundation

class Assembler {
	
	enum Token {
		case instruction (Int)
		case directive (Directive)
		case number (Int)
		case register (Int)
		case label (String)
		case labelDefinition (String)
		case comment (String)
		case string (String)
		case tuple (Int, Character, Int, Character, Int)
	}
	
	enum Directive {
		case start (String)
		case integer
		case allocate (Int)
		case string
		case end
		case tuple
	}
	
	func trimEndSpace (_ string: String) -> String {
		if string.count == 0 {
			return ""
		}
		let end = string.lastIndex(where: {!isWhiteSpace($0)})
		let start = string.firstIndex(where: {!isWhiteSpace($0)})
		
		if start == nil && end == nil {
			return ""
		}
		
		return String(string[(start ?? string.startIndex)...(end ?? (string.index(before: string.endIndex)))])
	}
	
	func tokenize (_ program: String) -> [[Token]] {
		var output = [[Token]]()
		
		let lines = program.split(separator: "\n").map{trimEndSpace(String($0))}
		
		for (count, line) in lines.enumerated() {
			output.append(tokenize(count: count, line: line))
		}
		
		
		return output
	}
	
	
	func tokenize (count: Int, line fullLine: String) -> [Token] {
		if fullLine.count == 0 {return []}
		
		var lineOut = [Token]()
		var line = fullLine
		
		switch line.first {
		case ".":
			if let directive = tokenize(directive: &line) {
				lineOut.append(.directive(directive))
				switch directive {
				case .allocate:
					if line.count == 0 {addError(count, "Nothing after .allocate");  return lineOut}
					else {addError(count, "Something other than a number after .allocate"); return lineOut}
					
				case .end:
					if line.count == 0 {return lineOut}
					else if line.first == ";" {lineOut.append(.comment(String(line.dropFirst())));  return lineOut}
					else {addError(count, "Something after .end other than a comment");  return lineOut}
					
				case .integer:
					if line.count == 0 {addError(count, "Nothing after .integer");  return lineOut}
					if line.first == "#" {
						if let number = tokenize(number: &line) {
							lineOut.append(.number(number))
							if line.count == 0 {return lineOut}
							else if line.first == ";" {lineOut.append(.comment(String(line.dropFirst())));  return lineOut}
							else {addError(count, "Something after the number other than a comment");  return lineOut}
						} else {
							addError(count, "Invalid Number"); return lineOut
						}
					} else {addError(count, "Something other than a number after .integer"); return lineOut}
					
				case .start:
					if line.count == 0 {return lineOut}
					else if line.first == ";" {lineOut.append(.comment(String(line.dropFirst())));  return lineOut}
					else {addError(count, "Something after the label other than a comment");  return lineOut}
					
				case .string:
					if line.count == 0 {addError(count, "Nothing after .string");  return lineOut}
					if line.first != "\"" {addError(count, "Something other than a string after .string");  return lineOut}
					
					var buffer = ""
					var index = line.startIndex
					while index < line.endIndex {
						index = line.index(after: index)
						if line[index] == "\"" {index = line.index(after: index); break}
						buffer.append(line[index])
					}
					lineOut.append(.string(buffer))
					line = String(line[index..<line.endIndex])
					line = trimEndSpace(line)
					
					if line.count == 0 {return lineOut}
					else if line.first == ";" {lineOut.append(.comment(String(line.dropFirst())));  return lineOut}
					else {addError(count, "Something after the string other than a comment");  return lineOut}
					
				case .tuple:
					if line.count == 0 {addError(count, "Nothing after .tuple");  return lineOut}
					if line.first != "\\" {addError(count, "Something other than a tuple after .tuple");  return lineOut}
					line = String(line.dropFirst())
					guard let endTuple = line.firstIndex(of: "\\") else {addError(count, "No end to tuple");  return lineOut}
					let tuple = String(line[line.startIndex..<endTuple])
					line = String(line[line.index(after:endTuple)..<line.endIndex])
					
					let parts = tuple.split(separator: " ")
					if parts.count != 5 {addError(count, "Number of things in tuple != 5");  return lineOut}
					guard let oldState = Int(parts[0]), let newState = Int(parts[2]) else {addError(count, "Invalid number");  return lineOut}
					guard parts[1].count == 1 && parts[3].count == 1 else {addError(count, "Character is more than one character long");  return lineOut}
					guard parts[4].lowercased() == "r" || parts[4].lowercased() == "l" else {addError(count, "Direction is not r or l");  return lineOut}
					
					lineOut.append(.tuple(oldState, parts[1].first!, newState, parts[3].first!, parts[4] == "r" ? 1 : -1))
					
					line = trimEndSpace(line)
					if line.count == 0 {return lineOut}
					else if line.first == ";" {lineOut.append(.comment(String(line.dropFirst())));  return lineOut}
					else {addError(count, "Something after the string other than a comment");  return lineOut}
					
				}
			} else {
				addError(count, "Invalid directive")
				return lineOut
			}
		case ";":
			lineOut.append(.comment(String(line.dropFirst())))
			return lineOut
		default: break
		}
		
		if let labelDef = tokenize(labelDef: &line) {
			lineOut.append(.labelDefinition(labelDef.lowercased()))
			
			if line.count > 0 {
				lineOut += tokenize(count: count, line: line)
				return lineOut
			}
		}
		
		if let instruction = Instruction.forAssembler[getFirstWord(line: &line).lowercased()] {
			lineOut.append(.instruction(instruction.opCode))
			while true {
				if line.count == 0 {return lineOut}
				if line.first == ";" {lineOut.append(.comment(String(line.dropFirst())));  return lineOut}
				
				let word = getFirstWord(line: &line)
				if word.first == "#" {
					if let number = Int(word.dropFirst()) {
						lineOut.append(.number(number))
						continue
					} else {
						addError(count, "Invalid Number"); return lineOut
					}
				}
				
				switch word {
				case "r0": lineOut.append(.register(0))
				case "r1": lineOut.append(.register(1))
				case "r2": lineOut.append(.register(2))
				case "r3": lineOut.append(.register(3))
				case "r4": lineOut.append(.register(4))
				case "r5": lineOut.append(.register(5))
				case "r6": lineOut.append(.register(6))
				case "r7": lineOut.append(.register(7))
				case "r8": lineOut.append(.register(8))
				case "r9": lineOut.append(.register(9))
				default:
					lineOut.append(.label(word.lowercased()))
				}
			}
		}
		
		return lineOut
	}
	
	func addError (_ line: Int, _ message: String) {
		if errorMap[line] == nil {
			errorMap[line] = [message]
		} else {
			errorMap[line]!.append(message)
		}
	}
	
	func getFirstWord (line: inout String) -> String {
		let endWord = line.firstIndex(where: {isWhiteSpace($0)}) ?? line.endIndex
		
		let word = String(line[line.startIndex..<endWord])
		
		line = trimEndSpace(String(line[endWord..<line.endIndex]))
		
		return word
	}
	
	func tokenize (directive line: inout String) -> Directive? {
		let endDirective = line.firstIndex(where: {isWhiteSpace($0)}) ?? line.endIndex
		
		let directiveString = String(line[line.startIndex..<endDirective])
		
		line = trimEndSpace(String(line[endDirective..<line.endIndex]))
		
		switch directiveString {
		case ".start":
			if line.count == 0 {return nil}
			let label = getFirstWord(line: &line).lowercased()
			line = trimEndSpace(line)
			return .start(label)
		case ".integer":
			return .integer
		case ".allocate":
			if line.count == 0 {return nil}
			if line.first == "#" {
				if let number = tokenize(number: &line) {
					return .allocate(number)
				} else {
					return nil
				}
			}
			return nil
		case ".string":
			return .string
		case ".end":
			return .end
		case ".tuple":
			return .tuple
		default:
			return nil
		}
		
	}
	
	func tokenize (labelDef line: inout String) -> String? {
		guard let endLabel = line.firstIndex(of: ":") else {return nil}
		if endLabel == line.startIndex {return nil}
		
		let label = String(line[line.startIndex..<endLabel])
		
		line = trimEndSpace(String(line[line.index(after: endLabel)..<line.endIndex]))
		
		return label
		
	}
	
	func tokenize (number line: inout String) -> Int? {
		let endNumber = line.firstIndex(where: {isWhiteSpace($0)}) ?? line.endIndex
		
		let number = String(line[line.startIndex..<endNumber])
		
		line = trimEndSpace(String(line[endNumber..<line.endIndex]))
		
		return Int(number.dropFirst())
	}
    
    var labelMap = [String: Int]()

    var errorMap = [Int: [String]]()
	
	
    func firstPass (_ tokenArray: [[Token]]) -> Bool{
        var shouldPass = true
		var hasStart = false
        var counter = 0
        for (number, line) in tokenArray.enumerated() {
			var hasInstruction = false
            for (column, token) in line.enumerated() {
                switch token {
                case .instruction(let which):
					counter += 1
					
                    let instruction = Instruction.forCPU[which]!
					if !hasInstruction {
						hasInstruction = true
					} else {
						addError(number, "2 Instructions on one line")
					}
					
                    let args = instruction.args
					if args.count != 0 {
						var realArgs = ""
						if column + args.count >= line.count {
							addError(number,  "Invalid args")
						} else {
							argLoop: for arg in line[(column + 1)..<(column + args.count)] {
								switch arg {
								case .register:
									realArgs += "r"
								case .label:
									realArgs += "m"
								case .number:
									realArgs += "i"
								default:
									shouldPass = false
									addError(number,  "Invalid args")
									break argLoop
								}
							}
							if realArgs != args {
								addError(number, "Invalid args")
							}
						}
					}
					
                case .directive(let which) :
                    switch which {
                    case .start:
						if hasStart {
							addError(number, "Start already declared")
							shouldPass = false
						} else {
							hasStart = true
						}
                    case .allocate(let num):
						counter += num
                    default:
                        counter += 0
                    }
					
                case .number:
                    counter += 1
				case .tuple:
					counter += 5
                case .register:
                    counter += 1
                case .string(let s):
                    counter += s.count + 1
                case .label:
                    counter += 1
                case .labelDefinition(let def):
                    if labelMap[def] != nil{
                        shouldPass = false
                        addError(number, "Label defined multiple times")
                    } else {
                        labelMap[def] = counter
                    }
                default:
                    counter += 0
                }
            }
        }
        return shouldPass
    }
    
    func stringToNumbers (_ string: String) -> [Int] { //Includes length at the beginning
        return [string.unicodeScalars.count]  + string.unicodeScalars.lazy.map{Int($0.value)}
    }
    
    func secondPass(_ tokenArray: [[Token]])->[Int]{
        var binaryFile = [Int]()
		var start = 0
        binaryFile.append(0)
		binaryFile.append(0)
        for line in 0..<tokenArray.count{
            for token in 0..<tokenArray[line].count{
                let t = tokenArray[line][token]
                switch t {
                case .instruction(let which):
                    binaryFile.append(which)
				case .tuple(let oldState, let oldChar, let newState, let newChar, let dir):
					binaryFile.append(oldState)
					binaryFile.append(Int(oldChar.unicodeScalars.first!.value))
					binaryFile.append(newState)
					binaryFile.append(Int(newChar.unicodeScalars.first!.value))
					binaryFile.append(dir)
                case .register(let which):
                    binaryFile.append(which)
                case .number(let num):
                    binaryFile.append(num)
                case .label(let which):
                    if labelMap[which] == nil{
                        addError(line, "Undefined label")
                    } else {
                        binaryFile.append(labelMap[which]!)
                    }
                case .directive(let which):
                    switch which{
                    case .start(let label):
						start = labelMap[label]!
                    case .allocate(let num):
						for _ in 0..<num {
							binaryFile.append(0)
						}
                    default:
                        break
                    }
                case .string(let which):
                    for i in stringToNumbers(which){
                        binaryFile.append(i)
                    }
                default:
                    break
                }
            }
        }
		binaryFile[1] = start
		binaryFile[0] = binaryFile.count - 2
        return binaryFile
    }
    
    func symTable () -> String {
		var out = ""
		for (macro, val) in labelMap {
			out += "\(macro) \(val)\n"
		}
		
		return String(out.dropLast())
    }
	
	func listFile (_ program: String, _ tokens: [[Token]]) -> String {
        var output = ""
        let lines = program.split(whereSeparator: {"\n".contains($0)})
        var counter: Int = 0
		
        for (number, line) in lines.enumerated() {
            var outLine = "\(counter):"
            
            outLine = outLine.padding(toLength: 6, withPad: " ", startingAt: 0)
            
			var errors = errorMap[number]?.joined(separator: ", ")
			
			var assembledLine = [Any]()
			
			for token in tokens[number] {
				switch token {
				case .instruction(let opCode):
					assembledLine.append(opCode)
					counter += 1
				case .number(let number):
					assembledLine.append(number)
					counter += 1
				case .register(let register):
					assembledLine.append(register)
					counter += 1
				case .label(let label):
					if let value = labelMap[label] {assembledLine.append(value)}
					else {assembledLine.append(label)}
					counter += 1
				case .tuple(let oldState, let oldChar, let newState, let newChar, let dir):
					assembledLine.append(oldState)
					assembledLine.append(Int(oldChar.unicodeScalars.first!.value))
					assembledLine.append(newState)
					assembledLine.append(Int(newChar.unicodeScalars.first!.value))
					assembledLine.append(dir)
					counter += 5
				case .string(let string):
					for i in stringToNumbers(string){
						assembledLine.append(i)
					}
					counter += string.count + 1
				case .directive(let directive):
					switch directive {
					case .allocate(let num):
						for _ in 0..<num {
							assembledLine.append(0)
						}
						counter += num
					default:
						counter += 0
					}
				default:
					counter += 0
				}
			}
            
            let firstFourSlice = assembledLine[0..<min(4,assembledLine.count)]
			let firstFour = Array(firstFourSlice)
			outLine += String(firstFour.map{"\($0)"}.joined(separator: " "))
            
            output += outLine.padding(toLength: 30, withPad: " ", startingAt: 0) + " "
            
            output += line
			if errors != nil {
                output += " Errors: "
                output += errors!
            }
            
            output += "\n"
        }
		
		return output
	}

}

