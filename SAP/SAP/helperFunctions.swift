//
//  helperFunctions.swift
//  SAP
//
//  Created by jamin on 4/2/19.
//  Copyright © 2019 Gideon Rabson. All rights reserved.
//

import Foundation

func splitToWords (_ expression: String) -> [String] {
	return expression.split(separator: " ").map{String($0)}
}

func splitToLines (_ expression: String) -> [String] {
    return expression.split(separator: "\n").map{String($0)}
}

func trimLeadingSpace (_ expression: String) -> String {
	return  String(expression[(expression.firstIndex(where: {!isWhiteSpace($0)}) ?? expression.endIndex)..<expression.endIndex])
}

func trimTrailingSpace (_ expression: String) -> String {
	let location = expression.lastIndex(where: {!isWhiteSpace($0)})
	if let place = location {return String(expression[expression.startIndex...place])}
	return ""
}

//Functions to perform actual i/o from console and filesystem

func readTextFile (_ path: String) -> (message: String?, fileText: String?) {
    let text: String
    do {
        text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
	} catch {
        return ("\(error)", nil)
    }
    return (nil, text)
}

func writeTextFile (_ path: String, data: String) -> String? {
    let url = NSURL.fileURL(withPath : path)
    do {
        try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    } catch let error as NSError {
        return "Failed writing to URL: \(url), Error: " + error.localizedDescription
    }
    return nil
}



func isAlphaNum (_ char: Character) -> Bool {
	return ("a"..."z" ~= char || "A"..."Z" ~= char || "0"..."9" ~= char || "_" == char)
}

func isAlpha (_ char: Character) -> Bool {
	return ("a"..."z" ~= char || "A"..."Z" ~= char)
}

func isNum (_ char: Character) -> Bool {
	return ("0"..."9" ~= char)
}

func isWhiteSpace (_ char: Character) -> Bool {
	return (" " == char || "\t" == char || "\n" == char)
}
