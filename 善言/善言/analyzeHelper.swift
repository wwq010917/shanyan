//  analyzeHelper.swift
//  善言
//
//  Created by Wenqiao Wang on 4/28/23.
//

import Foundation
public func analyzeToxicity(_ text: String, apiKey: String, completion: @escaping (Double, String) -> Void) {
    let words = Array(text).map { String($0) }
    var highestToxicScore: Double = 0.0
    var toxicWord: String = ""

    func generateCombinations(of words: [String]) -> [String] {
        var combinations: [String] = []
        
        for i in 2...words.count {
            for j in 0...(words.count - i) {
                let combination = words[j...j + i - 1].joined(separator: "")
                combinations.append(combination)
            }
        }
        
        return combinations
    }

    func analyzeNextCombination(combinations: [String], index: Int) {
        if index >= combinations.count || highestToxicScore > 0.75 {
            completion(highestToxicScore, toxicWord) // Add this line
            return
        }

        let textToAnalyze = combinations[index]
        print(textToAnalyze)
        analyzeComment(withText: textToAnalyze, apiKey: apiKey) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let toxicityScore):
                    
                    
                    
                    if toxicityScore > highestToxicScore {
                        highestToxicScore = toxicityScore
                        toxicWord = textToAnalyze
                    }
                    
                    DispatchQueue.background(delay: 2.0, background: {
                        analyzeNextCombination(combinations: combinations, index: index + 1)
                    }, completion: {
                        // when background job finishes, wait 3 seconds and do something in main thread
                    })
                        
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    
                }
            }
        }
    }

    let allCombinations = generateCombinations(of: words)
   

    analyzeNextCombination(combinations: allCombinations, index: 0)
}
extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            Thread.sleep(forTimeInterval: 3)
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
