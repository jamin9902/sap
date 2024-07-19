import Foundation

class CPU {
	var programCounter = 0
	var compareRegister = 0
	
	var registers = [Int](repeating: 0, count: 10)
	
	var ram = GrowingArray<Int>(0)
	var stack = Stack()
	
	enum State {
		case stop
		case pause
		case play
	}
	
	func reset (_ program: [Int]) {
		programCounter = program[1]
		registers = [Int](repeating: 0, count: 10)
		let realProgram = Array(program.dropFirst().dropFirst())
		ram.set(to: realProgram)
		stack = Stack()
	}
	
	func step () -> State {
		let out = Instruction.forCPU[ram[programCounter]]?.function(self)() ?? .stop
		programCounter += 1
		return out
	}
	
	//INSTRUCTIONS==========================================================================
	
	func getVals (_ numArgs: Int) -> [Int] {
		var out = [Int]()
		for _ in 0..<numArgs {
			programCounter += 1
			out.append(ram[programCounter])
		}
		return out
	}
	
	//0
	func halt () -> State {
		return .stop
	}
	
	//1
	func clrr () -> State {
		let args = getVals(1)
		registers[args[0]] = 0
		return .play
	}
	
	//2
	func clrx () -> State {
		let args = getVals(1)
		ram[registers[args[0]]] = 0
		return .play
	}
	
	//3
	func clrm () -> State {
		let args = getVals(1)
		ram[args[0]] = 0
		return .play
	}
	
	//4
	func clrb () -> State {
		let args = getVals(2)
		let start = registers[args[0]]
		let end = start + registers[args[1]]
		for i in start..<end {
			ram[i] = 0
		}
		return .play
	}
	
	//5
	func movir () -> State {
		let args = getVals(2)
		registers[args[1]] = args[0]
		return .play
	}
	
	//6
	func movrr () -> State {
		let args = getVals(2)
		registers[args[1]] = registers[args[0]]
		return .play
	}
	
	//7
	func movrm () -> State {
		let args = getVals(2)
		ram[args[1]] = registers[args[0]]
		return .play
	}
	
	//8
	func movmr () -> State {
		let args = getVals(2)
		registers[args[1]] = ram[args[0]]
		return .play
	}
	
	//9
	func movxr () -> State {
		let args = getVals(2)
		registers[args[1]] = ram[registers[args[0]]]
		return .play
	}
	
	//10
	//movar is really just movir
	
	//11
	func movb () -> State {
		let args = getVals(3)
		let source = registers[args[0]]
		let destination = registers[args[1]]
		let count = registers[args[2]]
		for i in 0..<count {
			ram[destination + i] = ram[source + i]
		}
		return .play
	}
	
	//12
	func addir () -> State {
		let args = getVals(2)
		registers[args[1]] += args[0]
		return .play
	}
	
	//13
	func addrr () -> State {
		let args = getVals(2)
		registers[args[1]] += registers[args[0]]
		return .play
	}
	
	//14
	func addmr () -> State {
		let args = getVals(2)
		registers[args[1]] += ram[args[0]]
		return .play
	}
	
	//15
	func addxr () -> State {
		let args = getVals(2)
		registers[args[1]] += ram[registers[args[0]]]
		return .play
	}
	
	//16
	func subir () -> State {
		let args = getVals(2)
		registers[args[1]] -= args[0]
		return .play
	}
	
	//17
	func subrr () -> State {
		let args = getVals(2)
		registers[args[1]] -= registers[args[0]]
		return .play
	}
	
	//18
	func submr () -> State {
		let args = getVals(2)
		registers[args[1]] -= ram[args[0]]
		return .play
	}
	
	//19
	func subxr () -> State {
		let args = getVals(2)
		registers[args[1]] -= ram[registers[args[0]]]
		return .play
	}
	
	//20
	func mulir () -> State {
		let args = getVals(2)
		registers[args[1]] *= args[0]
		return .play
	}
	
	//21
	func mulrr () -> State {
		let args = getVals(2)
		registers[args[1]] *= registers[args[0]]
		return .play
	}
	
	//22
	func mulmr () -> State {
		let args = getVals(2)
		registers[args[1]] *= ram[args[0]]
		return .play
	}
	
	//23
	func mulxr () -> State {
		let args = getVals(2)
		registers[args[1]] *= ram[registers[args[0]]]
		return .play
	}
	
	//24
	func divir () -> State {
		let args = getVals(2)
		registers[args[1]] /= args[0]
		return .play
	}
	
	//25
	func divrr () -> State {
		let args = getVals(2)
		registers[args[1]] /= registers[args[0]]
		return .play
	}
	
	//26
	func divmr () -> State {
		let args = getVals(2)
		registers[args[1]] /= ram[args[0]]
		return .play
	}
	
	//27
	func divxr () -> State {
		let args = getVals(2)
		registers[args[1]] /= ram[registers[args[0]]]
		return .play
	}
	
	//28
	func jmp () -> State {
		let args = getVals(1)
		programCounter = args[0] - 1
		return .play
	}
	
	//29
	func sojz () -> State {
		let args = getVals(2)
		registers[args[0]] -= 1
		if registers[args[0]] == 0 {
			programCounter = args[1] - 1
		}
		return .play
	}
	
	//30
	func sojnz () -> State {
		let args = getVals(2)
		registers[args[0]] -= 1
		if registers[args[0]] != 0 {
			programCounter = args[1] - 1
		}
		return .play
	}
	
	//31
	func aojz () -> State {
		let args = getVals(2)
		registers[args[0]] += 1
		if registers[args[0]] == 0 {
			programCounter = args[1] - 1
		}
		return .play
	}
	
	//32
	func aojnz () -> State {
		let args = getVals(2)
		registers[args[0]] += 1
		if registers[args[0]] != 0 {
			programCounter = args[1] - 1
		}
		return .play
	}
	
	//33
	func cmpir () -> State {
		let args = getVals(2)
		compareRegister = registers[args[1]] - args[0]
		return .play
	}
	
	//34
	func cmprr () -> State {
		let args = getVals(2)
		compareRegister = registers[args[1]] - registers[args[0]]
		return .play
	}
	
	//35
	func cmpmr () -> State {
		let args = getVals(2)
		compareRegister = registers[args[1]] - ram[args[0]]
		return .play
	}
	
	//36
	func jmpn () -> State {
		let args = getVals(1)
		if compareRegister < 0 {
			programCounter = args[0] - 1
		}
		return .play
	}
	
	//37
	func jmpz () -> State {
		let args = getVals(1)
		if compareRegister == 0 {
			programCounter = args[0] - 1
		}
		return .play
	}
	
	//38
	func jmpp () -> State {
		let args = getVals(1)
		if compareRegister > 0 {
			programCounter = args[0] - 1
		}
		return .play
	}
	
	//39
	func jsr () -> State {
		let args = getVals(1)
		stack.push(programCounter)
		for i in 5...9 {
			stack.push(registers[i])
		}
		programCounter = args[0] - 1
		return .play
	}
	
	//40
	func ret () -> State {
		for i in 1...5 {
			registers[10-i] = stack.pop()
		}
		programCounter = stack.pop()
		return .play
	}
	
	//41
	func push () -> State {
		let args = getVals(1)
		stack.push(registers[args[0]])
		return .play
	}
	
	//42
	func pop () -> State {
		let args = getVals(1)
		registers[args[0]] = stack.pop()
		return .play
	}
	
	//43
	func stackc () -> State {
		let args = getVals(1)
		registers[args[0]] = stack.register
		return .play
	}
	
	//44
	func outci () -> State {
		let args = getVals(1)
		print(String(UnicodeScalar(args[0])!), terminator: "")
		return .play
	}
	
	//45
	func outcr () -> State {
		let args = getVals(1)
		print(String(UnicodeScalar(registers[args[0]])!), terminator: "")
		return .play
	}
	
	//46
	func outcx () -> State {
		let args = getVals(1)
		print(String(UnicodeScalar(ram[registers[args[0]]])!), terminator: "")
		return .play
	}
	
	//47
	func outcb () -> State {
		let args = getVals(2)
		let start = registers[args[0]]
		let end = start + registers[args[1]]
		if end != start {
			for i in start..<end {
				if ram[i] >= 0 {
					if let scalar = UnicodeScalar(ram[i]) {
						print(scalar, terminator: "")
					}
				} else {
					print("NEGATIVE CHARACTER", terminator: "")
				}
			}
		}
		return .play
	}
	
	//48
	func readi () -> State { //Error message?
		let args = getVals(2)
        let int = 0 //Int(readLineFromConsole())
        registers[args[0]] = int
		return .play
	}
	
	//49
	func printi () -> State {
		let args = getVals(1)
		print(registers[args[0]], terminator: "")
		return .play
	}
	
	//50
	func readc () -> State { //TODO
		let args = getVals(1)
		let char: String = " " //Character(readLineFromConsole())
		registers[args[0]] = Int(char.unicodeScalars[char.unicodeScalars.startIndex].value)
        return .play
	}
	
	//51
	func readln () -> State { //TODO
		let args = getVals(2)
        let line = readLine() ?? "" //readLineFromConsole()
        ram[args[0]] = line.count
        for i in 0...line.count - 1 {
            ram[args[1] + i] = Int(line.unicodeScalars[line.index(line.startIndex, offsetBy: i)].value)
        }
        registers[args[1]] = line.count
		return .play
	}
	
	//52
	func brk () -> State { //TODO
		return .pause
	}
	
	//53
	func movrx () -> State {
		let args = getVals(2)
		ram[registers[args[1]]] = registers[args[0]]
		return .play
	}
	
	//54
	func movxx () -> State {
		let args = getVals(2)
		ram[registers[args[1]]] = ram[registers[args[0]]]
		return .play
	}
	
	//55
	func outs () -> State {
		let args = getVals(1)
		let start = args[0] + 1
		let end = args[0] + ram[args[0]] + 1
		for i in start..<end {
			print(String(UnicodeScalar(ram[i])!), terminator: "")
		}
		return .play
	}
	
	//56
	func nop () -> State {
		return .play
	}
	
	//57
	func jmpne () -> State {
		let args = getVals(1)
		if compareRegister != 0 {
			programCounter = args[0] - 1
		}
		return .play
	}
}
