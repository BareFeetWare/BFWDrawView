//
//  String+PaintCode.swift
//
//  Created by Tom Brodhurst-Hill on 26/9/16.
//  Copyright (c) 2016 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import Foundation

extension String {
    
    var uppercasedFirstCharacter: String {
        let index = characters.index(startIndex, offsetBy: 1)
        return substring(to: index).uppercased() + substring(from: index)
    }

    var lowercasedFirstCharacter: String {
        let index = characters.index(startIndex, offsetBy: 1)
        return substring(to: index).lowercased() + substring(from: index)
    }

    var words: [String] {
        return components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
    }
    
    var paintcodeCaseFromWords: String {
        let casedString = words.reduce ("") { $0 + $1.uppercasedFirstCharacter }
        return casedString
    }
    
    var camelCaseFromWords: String {
        var remainder = words
        remainder.removeFirst()
        let casedString = remainder.reduce (words.first!) { $0 + $1.uppercasedFirstCharacter }
        return casedString
    }
    
    var isUppercase: Bool {
        return self == uppercased()
    }
    
    var wordsFromCamelCase: String {
        var wordString = ""
        var previousChar: String? = nil
        for charN in 0 ..< characters.count {
            let thisChar = String(characters[characters.index(startIndex, offsetBy: charN)])
            let nextChar: String? = charN + 1 < characters.count ? String(characters[characters.index(startIndex, offsetBy: charN + 1)]) : nil
            if charN > 0
                && previousChar != " "
                && thisChar != " "
                && thisChar.isUppercase
                && (previousChar != nil && !previousChar!.isUppercase || (nextChar != nil && !nextChar!.isUppercase))
            {
                wordString += " "
            }
            wordString += thisChar
            previousChar = thisChar
        }
        return wordString
    }
    
    var lowercasedWords: String {
        return wordsFromCamelCase.lowercased()
    }
    
    func longestWordsMatch(inPrefixes prefixes: [String]) -> String? {
        return prefixes.reduce(nil) { (longest: String?, prefix) in
            return prefix.characters.count > (longest?.characters.count ?? 0)
                && lowercasedWords.hasPrefix(prefix.lowercasedWords)
                ? prefix : longest
        }
    }

    func words(matching wordsArray: [String]) -> String? {
        return wordsArray.first { self.lowercasedWords == $0.lowercasedWords }
    }

    var methodNameComponents: [String]? {
        let withString = "With"
        var parameters: [String]?
        if hasSuffix(":") {
            let parameterComponents = components(separatedBy: ":")
            if var withComponents = parameterComponents.first?.components(separatedBy: withString)
            {
                // TODO: Dynamic, less magic:
                if withComponents.count == 1 {
                    let firstComponent = withComponents.first!
                    if firstComponent.hasSuffix("InFrame") {
                        let drawAndName = firstComponent.deletedLast(count: "Frame".characters.count)
                        withComponents = [drawAndName, "Frame"]
                    } else {
                        fatalError("Can't parse \"\(self)\"")
                    }
                }
                let methodBaseName = withComponents.dropLast().joined(separator: withString)
                let firstParameter = withComponents.last!.lowercasedFirstCharacter
                parameters = [methodBaseName, firstParameter]
                parameters?.append(contentsOf: parameterComponents.dropFirst().dropLast())
            } else {
                debugPrint("Failed to find '\(withString)' in \(parameterComponents.first ?? "nil")")
            }
        } else {
            parameters = [self]
        }
        return parameters
    }
    
    func deletedLast(count: Int) -> String {
        return self[startIndex ..< characters.index(endIndex, offsetBy: -count)]
    }
    
}
