//
//  String+PaintCode.swift
//
//  Created by Tom Brodhurst-Hill on 26/9/16.
//  Copyright (c) 2016 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import Foundation

extension String {
    
    var lowercasedFirstCharacter: String {
        let index = self.index(startIndex, offsetBy: 1)
        return String(self[..<index]).lowercased() + String(self[index...])
    }
    
    var words: [String] {
        return components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
    }
    
    var paintcodeCaseFromWords: String {
        let casedString = words.reduce ("") { $0 + $1.capitalized }
        return casedString
    }
    
    var camelCaseFromWords: String {
        var remainder = words
        remainder.removeFirst()
        let casedString = remainder.reduce (words.first!) { $0 + $1.capitalized }
        return casedString
    }
    
    var isUppercase: Bool {
        return self == uppercased()
    }
    
    var wordsFromCamelCase: String {
        var wordString = ""
        var previousChar: String? = nil
        for charN in 0 ..< count {
            let thisChar = String(self[index(startIndex, offsetBy: charN)])
            let nextChar: String? = charN + 1 < count
                ? String(self[index(at: charN + 1)])
                : nil
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
            return prefix.count > (longest?.count ?? 0)
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
                // Usually, a drawing <name> created in PaintCode will create a function draw<name>WithFrame, but if the <name> ends in a preposition, like `In`, `On`, `To`, then the `With` will be dropped. That makes it difficult to parse. We have to look for those specific prepositions.
                if withComponents.count == 1 {
                    let firstComponent = withComponents.first!
                    if let drawAndName = firstComponent.substring(beforeSuffix: "Frame"),
                        firstComponent.hasSuffix("InFrame")
                            || firstComponent.hasSuffix("AfterFrame")
                            || firstComponent.hasSuffix("AsFrame")
                            || firstComponent.hasSuffix("BeforeFrame")
                            || firstComponent.hasSuffix("OnFrame")
                            || firstComponent.hasSuffix("ToFrame")
                    {
                        withComponents = [drawAndName, "Frame"]
                    } else {
                        fatalError("Can't parse the function name `\(self)` to determine the drawing name")
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
    
}
