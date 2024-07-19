import Foundation

enum UIError: Error {
	case invalidArgumentNumber (correctNumber: Int)
	case unknownCommand
}

class AbstractUI {
	
	func boot () {
		startUp()
		
		print(startLine(), terminator: "")
		
		while (parseLine(readLine() ?? "")) {
			print(startLine(), terminator: "")
		}
	}
	
	//Abstract
	func startUp () {}
	
	//Abstract
	func startLine () -> String {return ""}
	
	func parseLine (_ line: String) -> Bool {
		let args = line.split(whereSeparator: isWhiteSpace)
		
		if args.count == 0 {
			return true
		}
		
		do {
			return try runCommand(args)
		} catch UIError.invalidArgumentNumber(let correctNumber) {
			return invalidArgumentNumberHandler(String(args[0]), given: args.count, correct: correctNumber)
		} catch UIError.unknownCommand {
			return unknownCommandHandler(String(args[0]))
		} catch {
			return false
		}
	}
	
	//Abstract: default: throw UIError.unknownCommand
	func runCommand (_ args: [Substring]) throws -> Bool {return false}
	
	func validateArgumentNumber (_ args: [Substring], _ number: Int) throws {
		if args.count != number + 1 {
			throw UIError.invalidArgumentNumber(correctNumber: number)
		}
	}
	
	
	func invalidArgumentNumberHandler (_ command: String, given: Int, correct: Int) -> Bool {
		print("\(command) accepts \(correct) arguments but \(given - 1) were given.")
		return true
	}
	
	func unknownCommandHandler (_ command: String) -> Bool {
		print("\(command) is not a valid command. Type help to see a list of commands.")
		return true
	}
}
