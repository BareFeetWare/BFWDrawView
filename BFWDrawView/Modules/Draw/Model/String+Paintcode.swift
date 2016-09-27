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
        let index = startIndex.advancedBy(1)
        return substringToIndex(index).uppercaseString + substringFromIndex(index)
    }

    var lowercasedFirstCharacter: String {
        let index = startIndex.advancedBy(1)
        return substringToIndex(index).lowercaseString + substringFromIndex(index)
    }

    var words: [String] {
        return componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter { !$0.isEmpty }
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
        return self == uppercaseString
    }
    
    var wordsFromCamelCase: String {
        var wordString = ""
        var previousChar: String? = nil
        for charN in 0 ..< characters.count {
            let thisChar = String(characters[startIndex.advancedBy(charN)])
            let nextChar: String? = charN + 1 < characters.count ? String(characters[startIndex.advancedBy(charN + 1)]) : nil
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
        return wordsFromCamelCase.lowercaseString
    }
    
    func longestWordsMatchInPrefixes(prefixes: [String]) -> String {
        return prefixes.reduce("") { (longest, prefix) in
            return prefix.characters.count > longest.characters.count
                && self.lowercasedWords.hasPrefix(prefix.lowercasedWords)
                ? prefix : longest
        }
    }

    func wordsMatchingWordsArray(wordsArray: [String]) -> String? {
        let lowercasedWords = self.lowercasedWords
        return wordsArray.filter { words in
            return lowercasedWords == words.lowercasedWords
        }.first
    }

    var methodNameComponents: [String]? {
        let withString = "With"
        var parameters: [String]?
        if hasSuffix(":") {
            let parameterComponents = componentsSeparatedByString(":")
            if let withComponents = parameterComponents.first?.componentsSeparatedByString(withString)
                where !withComponents.isEmpty
            {
                let methodBaseName = withComponents.dropLast().joinWithSeparator(withString)
                let firstParameter = withComponents.last!.lowercasedFirstCharacter
                parameters = [methodBaseName, firstParameter]
                parameters?.appendContentsOf(parameterComponents.dropFirst().dropLast())
            }
        } else {
            parameters = [self]
        }
        return parameters
    }
    
}
