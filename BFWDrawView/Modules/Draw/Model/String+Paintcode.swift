//
//  String+Paintcode.swift
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
    
    func longestWordsMatch(inPrefixes prefixes: [String]) -> String {
        return prefixes.reduce("") { (longest, prefix) in
            return prefix.characters.count > longest.characters.count
                && self.lowercasedWords.hasPrefix(prefix.lowercasedWords)
                ? prefix : longest
        }
    }

    func words(matching wordsArray: [String]) -> String? {
        let lowercasedWords = self.lowercasedWords
        return wordsArray.filter { words in
            return lowercasedWords == words.lowercasedWords
        }.first
    }

    var methodNameComponents: [String]? {
        let withString = "With"
        var parameters: [String]?
        if hasSuffix(":") {
            let parameterComponents = components(separatedBy: ":")
            if let withComponents = parameterComponents.first?.components(separatedBy: withString), !withComponents.isEmpty
            {
                let methodBaseName = withComponents.dropLast().joined(separator: withString)
                let firstParameter = withComponents.last!.lowercasedFirstCharacter
                parameters = [methodBaseName, firstParameter]
                parameters?.append(contentsOf: parameterComponents.dropFirst().dropLast())
            }
        } else {
            parameters = [self]
        }
        return parameters
    }
    
}
