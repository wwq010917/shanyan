import Foundation

func analyzeComment(withText text: String, apiKey: String, completion: @escaping (Result<Double, Error>) -> Void) {
    let urlString = "https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=\(apiKey)"
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    let commentData: [String: Any] = [
        "comment": ["text": text],
        "languages": ["zh"],
        "requestedAttributes": ["TOXICITY": [:]]
    ]
    
    do {
        let requestData = try JSONSerialization.data(withJSONObject: commentData, options: [])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
              
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let attributeScores = jsonResult["attributeScores"] as? [String: Any],
                   let toxicity = attributeScores["TOXICITY"] as? [String: Any],
                   let summaryScore = toxicity["summaryScore"] as? [String: Any],
                   let value = summaryScore["value"] as? Double {
                    completion(.success(value))
                } else {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print(jsonResult)
                    print("Invalid JSON format")
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    } catch {
        print("Error serializing JSON")
    }
}
public func saveInsultCount(_ count: Int) {
    let today = Date().startOfDay.toInt()
    UserDefaults.standard.set(count, forKey: "\(today)")
}

public func getInsultCount() -> Int {
    let today = Date().startOfDay.toInt()
    return UserDefaults.standard.integer(forKey:"\(today)")
}
public func getInsultCountsForDays(_ days: Int) -> [Int: Int] {
    var counts: [Int: Int] = [:]
    
    for dayOffset in 0..<days {
        let dayDate = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date().startOfDay)!
        let dayInt = dayDate.toInt()
        
        let count = UserDefaults.standard.integer(forKey: "\(dayInt)")
        counts[dayInt] = count
    }
    
    return counts
}
public func saveFirstDayIfNeeded() {
    let firstDayKey = "firstDay"
    if UserDefaults.standard.object(forKey: firstDayKey) == nil {
        let today = Date().startOfDay.toInt()
        UserDefaults.standard.set(today, forKey: firstDayKey)
    }
}
public func saveBadSentence(_ sentence: String) {
    // Key for the array in UserDefaults
    let badSentencesKey = "badSentencesArrayKey"

    // Check if an array exists in UserDefaults
    if let retrievedArray = UserDefaults.standard.array(forKey: badSentencesKey) as? [String] {
        // If the array exists, append the bad sentence and save it back
        var updatedArray = retrievedArray
        updatedArray.append(sentence)
        UserDefaults.standard.set(updatedArray, forKey: badSentencesKey)
    } else {
        // If the array doesn't exist, create a new array with the bad sentence and save it
        let newArray = [sentence]
        UserDefaults.standard.set(newArray, forKey: badSentencesKey)
    }
    NotificationCenter.default.post(name: .badSentenceAdded, object: nil, userInfo: ["sentence": sentence])
}

public func getDaysSinceFirstDay() -> Int {
    let firstDayKey = "firstDay"
    if let firstDayInt = UserDefaults.standard.object(forKey: firstDayKey) as? Int {
        let firstDay = Date.fromInt(firstDayInt).startOfDay
        let today = Date().startOfDay
        let components = Calendar.current.dateComponents([.day], from: firstDay, to: today)
        return components.day! + 1 // Add 1 to include the first day itself
    }
    return 0
}
