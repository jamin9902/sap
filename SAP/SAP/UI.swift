import Foundation
import Darwin

class UI: AbstractUI {
	var directory = ""
	
	override func startUp () {
		print("""
Welcome to the SAP environment!"
""")
	}
	
	override func startLine() -> String {
		return "> "
	}
	
	override func runCommand (_ args: [Substring]) throws -> Bool {
		switch args[0] {
		case "help":
			return try help(args)
		case "quit":
			return try quit(args)
		case "path":
			return try path(args)
		case "run":
			return try run(args)
		case "gidasm":
			return try gidAsm(args)
		case "asm":
			return try asm(args)
		case "debug":
			return try debug(args)
		default:
			throw UIError.unknownCommand
		}
	}
	

	
	func help (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		
		print("""
help - List commands
quit - Quits the program
path [directory] - Sets directory to specified if given, otherwise prints the current path
run <file> - Runs the specified program without entering the debugger (need to include .bin at the end)
gidasm <file> - Assembles the specified program with the Gideon assembler
asm <file> - Assembles the specified program with the Stulin assembler
debug <file> - Enters debugger for specified program (no .bin at the end)
"""
		)
		
		return true
	}
	
	func quit (_ args: [Substring]) throws -> Bool {
		try validateArgumentNumber(args, 0)
		
		return false
	}
	
	func path (_ args: [Substring]) throws -> Bool {
		if args.count == 1 {
			print(directory)
			return true
		}
		
		directory = Array(args[1..<args.count]).joined(separator: " ")
		
		return true
	}
	
	func run (_ args: [Substring]) throws -> Bool {
		if args.count < 2 {
			throw UIError.invalidArgumentNumber(correctNumber: 1)
		}
		
		let file = Array(args[1..<args.count]).joined(separator: " ")
		
		let maybeStr = readTextFile(directory + file)
		
		guard let str = maybeStr.fileText else {
			print(maybeStr.message!)
			return true
		}
		
		let program: [Int] = str.split(separator: "\n").map{Int($0) ?? 0}
		
		let cpu = CPU()
		cpu.reset(program)
		
		while(cpu.step()==CPU.State.play){}
		
		print()
		return true
	}
	
	func gidAsm (_ args: [Substring]) throws -> Bool {
		if args.count < 2 {
			throw UIError.invalidArgumentNumber(correctNumber: 1)
		}
		
		let file = Array(args[1..<args.count]).joined(separator: " ")
		
		let maybeStr = readTextFile(directory + file)
		
		guard let str = maybeStr.fileText else {
			print(maybeStr.message!)
			return true
		}
		
		let asm = GidAssembler1(program: str)
		
		writeTextFile(directory + file + ".sym", data: asm.symTable())
		writeTextFile(directory + file + ".lst", data: asm.listFile())
		
		if asm.assembled != nil {
			writeTextFile(directory + file + ".bin", data: asm.programFile())
		}
		
		print("Done")
		return true
	}
	
	func asm (_ args: [Substring]) throws -> Bool {
		if args.count < 2 {
			throw UIError.invalidArgumentNumber(correctNumber: 1)
		}
		
		let file = Array(args[1..<args.count]).joined(separator: " ")
		
		let maybeStr = readTextFile(directory + file)
		
		guard let str = maybeStr.fileText else {
			print(maybeStr.message!)
			return true
		}
		
		let asm = Assembler()
		
		let tokens = asm.tokenize(str)
		
		
		if asm.firstPass(tokens) {
			let program: [Int] = asm.secondPass(tokens)
			writeTextFile(directory + file + ".bin", data: program.map{String($0)}.joined(separator: "\n"))
		}
		writeTextFile(directory + file + ".sym", data: asm.symTable())
		writeTextFile(directory + file + ".lst", data: asm.listFile(str, tokens))
		
		print("Done")
		return true
	}
	
	func debug (_ args: [Substring]) throws -> Bool {
		if args.count < 2 {
			throw UIError.invalidArgumentNumber(correctNumber: 1)
		}
		
		let file = Array(args[1..<args.count]).joined(separator: " ")
		
		let path = directory + file
		
		let debugger = Debugger()
		let maybeMessage = debugger.setup(path: path)
		if  maybeMessage != nil {
			print(maybeMessage!)
			return true
		}
		debugger.boot()
		return true
	}
}
