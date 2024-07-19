import Foundation

class Debugger: AbstractUI {
	let cpu = CPU()
	var path = ""
	var symTable = [String: Int]()
	var lastState: CPU.State = .play
	var breakPoints = Set<Int>()
	var breakEnabled = true
	
	func setup (path: String) -> String? {
		
		self.path = path
		
		let bin = readTextFile(path + ".bin")
		let sym = readTextFile(path + ".sym")
		
		guard let programText = bin.fileText else {
			return "No .bin file"
		}
		
		guard let symText = sym.fileText else {
			return "No .sym file"
		}
		
		let program: [Int] = programText.split(separator: "\n").map{Int($0) ?? 0}
		
		for line in symText.split(separator: "\n") {
			let words = line.split(separator: " ")
			symTable[String(words[0])] = Int(words[1]) ?? 0
		}
		
		cpu.reset(program)
		
		return nil
	}
	
	var directory = "/"

	
	override func startUp() {
		print("Welcome to the debugger!")
	}
	
	override func startLine() -> String {
		return "> "
	}
	
	
	override func runCommand(_ args: [Substring]) throws -> Bool {
		switch args[0] {
		case "help":
			return try help(args)
		case "quit", "exit":
			return try quit(args)
		case "step", "s":
			return try step(args)
		case "run", "go", "g":
			return try run(args)
		case "printsymbols", "psymbols", "symbols", "pst":
			return try symbols(args)
		case "printreg", "preg":
			return try printReg(args)
		case "writereg", "wreg":
			return try writeReg(args)
		case "writemem", "wmem":
			return try writeMem(args)
		case "printmem", "pmem":
			return try printMem(args)
		case "reset":
			return try reset(args)
		case "addbreak", "setbreak", "addbk", "setbk":
			return try addBreak(args)
		case "delbreak", "rembreak", "delbk", "rembk":
			return try delBreak(args)
		case "enablebreak", "enbreak", "enablebk", "enbk":
			return try enableBreak(args)
		case "disablebreak", "disbreak", "disablebk", "disbk":
			return try disableBreak(args)
		case "clearbreak", "clrbreak", "clearbk", "clrbk":
			return try clearBreak(args)
		case "printbreak", "pbreak", "printbk", "pbk":
			return try printBreak(args)
		case "setpc", "wpc":
			return try setPC(args)
		case "disassemble", "disas", "deassemble", "deas":
			return try deassemble(args)
		default: throw UIError.unknownCommand
		}
		
	}
	
	func help (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		
		print("""
help - prints help tape
quit / exit - quits debgger
step / s - moves one step
symbols / pst - prints symbol table
run / go / g - executes program
printsymbols / psymbols / symbols / pst - prints symbol table
printreg / preg [register] - prints register if specified, else, prints all registers
writereg / wreg <register> <value> - sets the value of specified register to value
printmem / pmem <start> <end> - prints range of memory, including start, but not end
writemem / wmem <register> <value> - sets the value of specified memory address to value
reset - resets all states
addbreak / setbreak / addbk / setbk <break point> - sets break point
delbreak / rembreak / delbk / rembk <break point> - deletes break point
enablebreak / enbreak / enablebk / enbk - enables break points
disablebreak / disbreak / disablebk / disbk - disables break points
clearbreak / clrbreak / clearbk / clrbk - clears break points
printbreak / pbreak / printbk / pbk - prints break points
setpc / wpc <value> - sets the program counter to value
disassemble / disas / deassemble / deas <start> <end> - deassembles program from start to end
"""
		)
		
		return true
	}
	
	func getNum (_ string: Substring) -> Int? {
		var num: Int?
		if let maybe = Int(string) {
			num = maybe
		} else if let maybe = symTable[String(string)] {
			num = maybe
		} else {
			num = nil
		}
		return num
	}
	
	func quit (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		
		print("Debugger Exited")
		return false
	}
	
	func step (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		
		print(Instruction.forCPU[cpu.ram[cpu.programCounter]]?.name ?? "No valid instruction")
		lastState = cpu.step()
		print()
		
		return true
	}
	
	func run (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		
		lastState = .play
		while true {
			lastState = cpu.step()
			if lastState == .pause {
				print("\nBreak instruction")
				break
			} else if lastState == .stop {
				print("\nHalt instruction")
				break
			}
			if breakEnabled && breakPoints.contains(cpu.programCounter) {
				print("\nBreak point reached")
				break
			}
		}
		
		return true
	}
	
	func symbols (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		for (symbol, value) in symTable {
			print("\(symbol): \(value)")
		}
		
		return true
	}
	
	func printReg (_ args: [Substring]) throws -> Bool {
		if args.count > 3 {
			print("\(args[0]) takes 0 or 1 argument, \(args.count - 1) inputted.")
		}
		
		if args.count == 2 {
			guard let first = getNum(args[1]), first > 0 && first < 10 else {
				print("\(args[1]) is not a valid number or symbol that is > 0 and < 10")
				return true
			}
			print("r\(first): \(cpu.registers[first])")
		} else {
			for (index, val) in cpu.registers.enumerated() {
				print("\tr\(index): \(val)")
			}
			print("PC: \(cpu.programCounter)")
			print("CMP: \(cpu.compareRegister)")
			print("STK: \(cpu.stack.register)")
		}
		
		return true
	}
	
	func writeReg (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 2)
		
		guard let first = getNum(args[1]), first > 0 && first < 10 else {
			print("\(args[1]) is not a valid number or symbol that is > 0 and < 10")
			return true
		}
		
		guard let second = getNum(args[2]) else {
			print("\(args[2]) is not a valid number or symbol")
			return true
		}
		
		cpu.registers[first] = second
		
		return true
	}
	
	func writeMem (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 2)
		
		guard let first = getNum(args[1]), first >= 0 else {
			print("\(args[1]) is not a valid numbe or symbol >= 0.")
			return true
		}
		
		guard let second = getNum(args[2]) else {
			print("\(args[2]) is not a valid number or symbol.")
			return true
		}
		
		cpu.ram[first] = second
		
		return true
	}
	
	func printMem (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 2)
		
		guard let first = getNum(args[1]), first >= 0 else {
			print("\(args[1]) is not a valid number or symbol >= 0.")
			return true
		}
		
		guard let second = getNum(args[2]), second > first else {
			print("\(args[2]) is not a valid number or symbol > \(first).")
			return true
		}
		
		for i in first..<second {
			print("\(i)\t\(cpu.ram[i])")
		}
		
		return true
	}

	func reset (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		if setup(path: path) == nil {
			print("Done")
		}
		
		return true
	}
	
	func addBreak  (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 1)
		
		guard let point = getNum(args[1]), point >= 0 else {
			print("\(args[1]) is not a valid number or symbol >= 0.")
			return true
		}
		
		breakPoints.insert(point)
		
		return true
	}
	
	func delBreak  (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 1)
		
		guard let point = getNum(args[1]), point >= 0 else {
			print("\(args[1]) is not a valid number or symbol >= 0.")
			return true
		}
		
		breakPoints.remove(point)
		
		return true
	}
	
	func enableBreak  (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		breakEnabled = true
		return true
	}
	
	func disableBreak  (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		breakEnabled = false
		return true
	}
	
	func clearBreak  (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		breakPoints = Set<Int>()
		return true
	}
	
	func printBreak  (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		for point in breakPoints {
			var associatedSymbols = [String]()
			for (symbol, value) in symTable {
				if value == point {associatedSymbols.append(symbol)}
			}
			
			if associatedSymbols.count == 0 {
				print(point)
			} else {
				print("\(point): \(associatedSymbols.joined(separator: ", "))")
			}
			
		}
		return true
	}
	
	func setPC (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 1)
		
		guard let location = getNum(args[1]), location >= 0 else {
			print("\(args[1]) is not a valid number or symbol >= 0.")
			return true
		}
		
		print(location)
		cpu.programCounter = location
		
		return true
	}
	
	func deassemble (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 2)
		
		guard let first = getNum(args[1]), first >= 0 else {
			print("\(args[1]) is not a valid number or symbol >= 0.")
			return true
		}
		
		guard let second = getNum(args[2]), second > first else {
			print("\(args[2]) is not a valid number or symbol > \(first).")
			return true
		}
		
		var i = first
		
		while i < second {
			var printed = false
			for (symbol, value) in symTable {
				if value == i {
					print("\(symbol):", terminator: " ")
					printed = true
				}
			}
			if !printed {
				print("\t", terminator: "")
			}
			
			guard let instruction = Instruction.forCPU[cpu.ram[i]] else {
				print("Invalid opCode \(cpu.ram[i])")
				break
			}
			
			print(instruction.name, terminator: " ")
			i += 1
			
			for letter in instruction.args {
				if letter == "r" {print("r", terminator: "")}
				print(cpu.ram[i], terminator: " ")
				i += 1
			}
			
			print()
		}
		
		return true
	}
}
