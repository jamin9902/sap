import Foundation

class Instruction {
	static var forCPU = [Int: Instruction]()
	static var forAssembler = [String: Instruction]()
	
	let name: String
	let opCode: Int
	let args: String
	
	let function: (CPU) -> () -> CPU.State
	
	init (name: String, opCode: Int, function: @escaping (CPU) -> () -> CPU.State, args: String) {
		self.name = name
		self.opCode = opCode
		self.args = args
		self.function = function
		
		Instruction.forCPU[opCode] = self
		Instruction.forAssembler[name] = self
	}
}

func createInstructions () {
	let _ = Instruction(name: "halt", opCode: 0, function: CPU.halt, args: "")
	let _ = Instruction(name: "nop", opCode: 56, function: CPU.nop, args: "")
	let _ = Instruction(name: "brk", opCode: 52, function: CPU.brk, args: "")
	
	let _ = Instruction(name: "clrr", opCode: 1, function: CPU.clrr, args: "r")
	let _ = Instruction(name: "clrx", opCode: 2, function: CPU.clrx, args: "r")
	let _ = Instruction(name: "clrm", opCode: 3, function: CPU.clrm, args: "m")
	let _ = Instruction(name: "clrb", opCode: 4, function: CPU.clrb, args: "rr")
	
	let _ = Instruction(name: "movir", opCode: 5, function: CPU.movir, args: "ir")
	let _ = Instruction(name: "movrr", opCode: 6, function: CPU.movrr, args: "rr")
	let _ = Instruction(name: "movrm", opCode: 7, function: CPU.movrm, args: "rm")
	let _ = Instruction(name: "movmr", opCode: 8, function: CPU.movmr, args: "mr")
	let _ = Instruction(name: "movrx", opCode: 53, function: CPU.movrx, args: "rr")
	let _ = Instruction(name: "movxr", opCode: 9, function: CPU.movxr, args: "rr")
	let _ = Instruction(name: "movxx", opCode: 54, function: CPU.movxx, args: "rr")
	let _ = Instruction(name: "movar", opCode: 10, function: CPU.movir, args: "mr")
	let _ = Instruction(name: "movb", opCode: 11, function: CPU.movb, args: "rrr")
	
	let _ = Instruction(name: "addir", opCode: 12, function: CPU.addir, args: "ir")
	let _ = Instruction(name: "addrr", opCode: 13, function: CPU.addrr, args: "rr")
	let _ = Instruction(name: "addmr", opCode: 14, function: CPU.addmr, args: "mr")
	let _ = Instruction(name: "addxr", opCode: 15, function: CPU.addxr, args: "rr")
	
	let _ = Instruction(name: "subir", opCode: 16, function: CPU.subir, args: "ir")
	let _ = Instruction(name: "subrr", opCode: 17, function: CPU.subrr, args: "rr")
	let _ = Instruction(name: "submr", opCode: 18, function: CPU.submr, args: "mr")
	let _ = Instruction(name: "subxr", opCode: 19, function: CPU.subxr, args: "rr")
	
	let _ = Instruction(name: "mulir", opCode: 20, function: CPU.mulir, args: "ir")
	let _ = Instruction(name: "mulrr", opCode: 21, function: CPU.mulrr, args: "rr")
	let _ = Instruction(name: "mulmr", opCode: 22, function: CPU.mulmr, args: "mr")
	let _ = Instruction(name: "mulxr", opCode: 23, function: CPU.mulxr, args: "rr")
	
	let _ = Instruction(name: "divir", opCode: 24, function: CPU.divir, args: "ir")
	let _ = Instruction(name: "divrr", opCode: 25, function: CPU.divrr, args: "rr")
	let _ = Instruction(name: "divmr", opCode: 26, function: CPU.divmr, args: "mr")
	let _ = Instruction(name: "divxr", opCode: 27, function: CPU.divxr, args: "rr")
	
	let _ = Instruction(name: "sojz", opCode: 29, function: CPU.sojz, args: "rm")
	let _ = Instruction(name: "sojnz", opCode: 30, function: CPU.sojnz, args: "rm")
	let _ = Instruction(name: "aojz", opCode: 31, function: CPU.aojz, args: "rm")
	let _ = Instruction(name: "aojnz", opCode: 32, function: CPU.aojnz, args: "rm")
	
	let _ = Instruction(name: "cmpir", opCode: 33, function: CPU.cmpir, args: "ir")
	let _ = Instruction(name: "cmprr", opCode: 34, function: CPU.cmprr, args: "rr")
	let _ = Instruction(name: "cmpmr", opCode: 35, function: CPU.cmpmr, args: "mr")
	
	let _ = Instruction(name: "jmp", opCode: 28, function: CPU.jmp, args: "m")
	let _ = Instruction(name: "jmpn", opCode: 36, function: CPU.jmpn, args: "m")
	let _ = Instruction(name: "jmpz", opCode: 37, function: CPU.jmpz, args: "m")
	let _ = Instruction(name: "jmpp", opCode: 38, function: CPU.jmpp, args: "m")
	let _ = Instruction(name: "jmpne", opCode: 57, function: CPU.jmpne, args: "m")
	
	let _ = Instruction(name: "jsr", opCode: 39, function: CPU.jsr, args: "m")
	let _ = Instruction(name: "ret", opCode: 40, function: CPU.ret, args: "")
	
	let _ = Instruction(name: "push", opCode: 41, function: CPU.push, args: "m")
	let _ = Instruction(name: "pop", opCode: 42, function: CPU.pop, args: "m")
	let _ = Instruction(name: "stackc", opCode: 43, function: CPU.stackc, args: "m")
	
	let _ = Instruction(name: "outci", opCode: 44, function: CPU.outci, args: "i")
	let _ = Instruction(name: "outcr", opCode: 45, function: CPU.outcr, args: "r")
	let _ = Instruction(name: "outcx", opCode: 46, function: CPU.outcx, args: "r")
	let _ = Instruction(name: "outcb", opCode: 47, function: CPU.outcb, args: "rr")
	let _ = Instruction(name: "outs", opCode: 55, function: CPU.outs, args: "m")
	let _ = Instruction(name: "printi", opCode: 49, function: CPU.printi, args: "r")
	
	let _ = Instruction(name: "readi", opCode: 48, function: CPU.readi, args: "rr")
	let _ = Instruction(name: "readc", opCode: 50, function: CPU.readc, args: "r")
	let _ = Instruction(name: "readln", opCode: 51, function: CPU.readln, args: "mr")
}
