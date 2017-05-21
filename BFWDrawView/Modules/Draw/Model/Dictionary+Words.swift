//
//  Dictionary+Words.swift
//
//  Created by Tom Brodhurst-Hill on 9/05/2015.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

extension Dictionary where Key == String {
    
    func object(forLongestPrefixKeyMatchingWordsIn wordsString: String) -> Value? {
        guard let prefix = wordsString.longestWordsMatch(inPrefixArray: Array(keys))
            else { return nil }
        return self[prefix]
    }
    
    func object(forWordsKey wordsKey: String) -> Value? {
        let object: Value?
        if let exactMatchObject = self[wordsKey] {
            object = exactMatchObject
        } else {
            let searchKey = wordsKey.lowercaseWords
            if let key = Array(keys).first(where: { searchKey == $0.lowercaseWords } ) {
                object = self[key]
            } else {
                object = nil
            }
        }
        return object
    }
    
}
