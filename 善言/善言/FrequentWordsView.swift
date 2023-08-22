import SwiftUI

struct FrequentWordsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var frequentWords: [String: Int] = [:]

    var body: some View {
        VStack {
            Text("常用词")
                .font(.title)
                .padding()

            List {
                ForEach(frequentWords.sorted(by: { $0.value > $1.value }), id: \.key) { word, count in
                    HStack {
                        Text(word)
                            .font(.body)
                        Spacer()
                        Text("\(count)")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }
            }

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("关闭")
                    .padding()
                    
                    .cornerRadius(12)
            }
            .padding(.bottom)
        }
        .onAppear {
            loadFrequentWords()
        }
    }

    private func loadFrequentWords() {
        if let storedFrequentWords = UserDefaults.standard.dictionary(forKey: "frequentSubstrings") as? [String: Int] {
            frequentWords = storedFrequentWords
        }
    }
}

struct FrequentWordsView_Previews: PreviewProvider {
    static var previews: some View {
        FrequentWordsView()
    }
}
