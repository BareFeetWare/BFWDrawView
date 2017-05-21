//
//  Dictionary+Words.swift
//
//  Created by Tom Brodhurst-Hill on 9/05/2015.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

extension Dictionary where Key == String {
    
    func object(forLongestPrefixKeyMatchingWordsIn wordsString: String) -> Value? {
        guard let prefix = wordsString.longestWordsMatch(inPrefixes: Array(keys))
            else { return nil }
        return self[prefix]
    }
    
    func object(forWordsKey wordsKey: String) -> Value? {
        let object: Value?
        if let exactMatchObject = self[wordsKey] {
            object = exactMatchObject
        } else {
            let searchKey = wordsKey.lowercasedWords
            if let key = Array(keys).first(where: { searchKey == $0.lowercasedWords } ) {
                object = self[key]
            } else {
                object = nil
            }
        }
        return object
    }
    
}
