//
//  DataProccessor.swift
//  善言
//
//  Created by Wenqiao Wang on 4/28/23.
//

import Foundation
public func analyzeFrequentSubstrings() {
    DispatchQueue.global(qos: .userInteractive).async {
        guard let toxicWords = UserDefaults.standard.dictionary(forKey: "toxicWords") as? [String: Int] else { return }
        print(toxicWords)
        var substringCounts: [String: Int] = [:]
        
        for (word, count) in toxicWords {
            let substrings = generateSubstrings(word)
            for substring in substrings {
                if let currentCount = substringCounts[substring] {
                    substringCounts[substring] = currentCount + count
                } else {
                    substringCounts[substring] = count
                }
            }
        }
        
        let frequentSubstrings = substringCounts.filter { $0.value > 10 }
        print(frequentSubstrings)
        
        // Update UserDefaults
        UserDefaults.standard.set(frequentSubstrings, forKey: "frequentSubstrings")
    }
}

public func generateSubstrings(_ word: String) -> [String] {
    let minSubstringLength = 2
    let maxSubstringLength = word.count
    
    var substrings: [String] = []
    
    for length in minSubstringLength...maxSubstringLength {
        for i in 0...(word.count - length) {
            let startIndex = word.index(word.startIndex, offsetBy: i)
            let endIndex = word.index(word.startIndex, offsetBy: i + length)
            let substring = String(word[startIndex..<endIndex])
            substrings.append(substring)
        }
    }
    
    return substrings
}
