

import SwiftUI
import AxisContribution


struct ContentView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var speechRecognizer = SpeechRecognizer()
    @State private var constant: ACConstant = .init(levelSpacing: 10,axisMode: .horizontal, levelLabel: .number)
    @State private var showFrequentWords = false

    @State private var showModal = false // Add this line
    @State private var lastOpenedDate: Date = Date()

    @State private var number: Int
    @State private var rowSize: CGFloat = 25
    @State private var rowImageName: String = ""
    @State private var dataSet: [Date: ACData] = [:]
    @State private var isRecording: Bool = false
    @State private var badWords: [String] =  []// Array to store bad words
    init() {
        _number = State(initialValue: getInsultCount())
    }
    var body: some View {
        
        
        VStack {
            // Add the following code at the top of VStack:
            HStack {
                Spacer()
                Button("常用词") {
                    showFrequentWords.toggle()
                }
                .padding()
               
                .cornerRadius(12)
            }

            
            Text(formattedDate())
                .font(.title)
                .fontWeight(.semibold)
                .padding()
            Text("骂人：\(speechRecognizer.insultCount)次")
                .font(.title2)
                .padding(.bottom)
            Button(action: { // New recording button
                if isRecording {
                    speechRecognizer.stopRecording()
                } else {
                    speechRecognizer.startRecording()
                }
                isRecording.toggle()
                



            }) {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "record.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isRecording ? .red : .blue)
                    Text(isRecording ? "停止" : "开始")
                        .foregroundColor(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 1)
                        .fill(Color.gray)
                        .opacity(0.5)
                )
            }
            
            AxisContribution(constant: constant, source: getDates()) { indexSet, data in
                if rowImageName.isEmpty {
                    defaultBackground
                }else {
                    background
                }
            } foreground: { indexSet, data in
                if rowImageName.isEmpty {
                    defaultForeground
                }else {
                    foreground
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .fill(Color.gray)
                    .opacity(0.5)
            )
            .frame(maxWidth: 300, maxHeight: 300)
            .sheet(isPresented: $showFrequentWords) {
                    FrequentWordsView()
                }
        }.onAppear {
            saveFirstDayIfNeeded()
            let range = getDaysSinceFirstDay()
            let insultCounts = getInsultCountsForDays(range)
            print(insultCounts)
            observeBadSentences() // Add this line
            let toxicWords = UserDefaults.standard.dictionary(forKey: "toxicWords") as? [String: Int] 
            print(toxicWords)
        }
    }
    
    
    private var defaultBackground: some View {
        Rectangle()
            .fill(Color(hex: colorScheme == .dark ? 0x171B21 : 0xF0F0F0))
            .frame(width: rowSize, height: rowSize)
            .cornerRadius(2)
    }
    
    private var defaultForeground: some View {
        Rectangle()
            .fill(Color(hex: 0xFF0000))
            .frame(width: rowSize, height: rowSize)
            .border(Color.white.opacity(0.2), width: 1)
            .cornerRadius(2)
    }
    
    
    private var background: some View {
        Image(systemName: rowImageName)
            .foregroundColor(Color(hex: colorScheme == .dark ? 0x171B21 : 0xF0F0F0))
            .font(.system(size: rowSize))
            .frame(width: rowSize, height: rowSize)
    }
    
    private var foreground: some View {
        Image(systemName: rowImageName)
            .foregroundColor(Color(hex: 0xFF0000))
            .font(.system(size: rowSize))
            .frame(width: rowSize, height: rowSize)
    }
    
    private func getDates() -> [Date: ACData] {
        let range = getDaysSinceFirstDay()
        let insultCounts = getInsultCountsForDays(range)
        var sequenceDatas = [Date: ACData]()

        // Existing data
        for (day, count) in insultCounts {
            let date = Date.fromInt(day)
            sequenceDatas[date.startOfDay] = ACData(date: date.startOfDay, count: count)
        }



        return sequenceDatas
    }


    private func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        return dateFormatter.string(from: Date())
    }
    private func gradient(for count: Int) -> LinearGradient {
        let startColor = Color.red.opacity(0.2)
        let endColor = Color.red.opacity(1.0)
        let colorFraction = Double(count) / 12.0
        
        let gradientColors = [startColor, endColor].map {
            $0.opacity(colorFraction)
        }
        
        return LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
func observeBadSentences() {
    NotificationCenter.default.addObserver(forName: .badSentenceAdded, object: nil, queue: .main) { notification in
        if let userInfo = notification.userInfo, let sentence = userInfo["sentence"] as? String {
            DispatchQueue.global(qos: .background).async {
                let inputText = sentence
                print("Bad sentence added: \(sentence)")
                let apiKey = "AIzaSyBmHlTTx9DCJzATUpxJTST9_mAMyggFqmg"
                analyzeToxicity(inputText, apiKey: apiKey) { (highestToxicScore, toxicWord) in
                    print("Toxic word: \(toxicWord)")
                    
                    // Save the toxic word in UserDefaults
                    if !toxicWord.isEmpty {
                        DispatchQueue.main.async {
                            saveToxicWord(toxicWord)
                            analyzeFrequentSubstrings()
                        }
                    }
                }
            }
        }
    }
}

func saveToxicWord(_ word: String) {
    let key = "toxicWords"
    if var toxicWords = UserDefaults.standard.dictionary(forKey: key) as? [String: Int] {
        if let count = toxicWords[word] {
            toxicWords[word] = count + 1
        } else {
            toxicWords[word] = 1
        }
        UserDefaults.standard.setValue(toxicWords, forKey: key)
    } else {
        let newToxicWords = [word: 1]
        UserDefaults.standard.setValue(newToxicWords, forKey: key)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension Notification.Name {
    static let badSentenceAdded = Notification.Name("badSentenceAdded")
}
