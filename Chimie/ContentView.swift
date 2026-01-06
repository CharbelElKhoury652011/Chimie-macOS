import SwiftUI
import UIKit
import CloudKit

let fileName = "resultats_chimie.txt"
let iCloudKey = "resultatsChimie"

struct Element: Identifiable {
    let id = UUID()
    let number: Int
    let symbol: String
    let name: String
}

let first30Elements: [Element] = [
    Element(number: 1, symbol: "H", name: "Hydrogène"),
    Element(number: 2, symbol: "He", name: "Hélium"),
    Element(number: 3, symbol: "Li", name: "Lithium"),
    Element(number: 4, symbol: "Be", name: "Béryllium"),
    Element(number: 5, symbol: "B", name: "Bore"),
    Element(number: 6, symbol: "C", name: "Carbone"),
    Element(number: 7, symbol: "N", name: "Azote"),
    Element(number: 8, symbol: "O", name: "Oxygène"),
    Element(number: 9, symbol: "F", name: "Fluor"),
    Element(number: 10, symbol: "Ne", name: "Néon"),
    Element(number: 11, symbol: "Na", name: "Sodium"),
    Element(number: 12, symbol: "Mg", name: "Magnésium"),
    Element(number: 13, symbol: "Al", name: "Aluminium"),
    Element(number: 14, symbol: "Si", name: "Silicium"),
    Element(number: 15, symbol: "P", name: "Phosphore"),
    Element(number: 16, symbol: "S", name: "Soufre"),
    Element(number: 17, symbol: "Cl", name: "Chlore"),
    Element(number: 18, symbol: "Ar", name: "Argon"),
    Element(number: 19, symbol: "K", name: "Potassium"),
    Element(number: 20, symbol: "Ca", name: "Calcium"),
    Element(number: 21, symbol: "Sc", name: "Scandium"),
    Element(number: 22, symbol: "Ti", name: "Titane"),
    Element(number: 23, symbol: "V", name: "Vanadium"),
    Element(number: 24, symbol: "Cr", name: "Chrome"),
    Element(number: 25, symbol: "Mn", name: "Manganèse"),
    Element(number: 26, symbol: "Fe", name: "Fer"),
    Element(number: 27, symbol: "Co", name: "Cobalt"),
    Element(number: 28, symbol: "Ni", name: "Nickel"),
    Element(number: 29, symbol: "Cu", name: "Cuivre"),
    Element(number: 30, symbol: "Zn", name: "Zinc")
]

enum QuizMode {
    case numberToElement
    case elementToNumber
}

struct ContentView: View {
    init() {
        rendreDossierVisibleDansFichiers()
        let _ = chargerResultats() // charge automatiquement les données sauvegardées
    }
    @State private var mode: QuizMode? = nil
    @State private var showResults = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.15), Color.white]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            if let mode = mode {
                QuizView(mode: mode) {
                    self.mode = nil
                }
            } else if showResults {
                ResultsView(onBack: { showResults = false })
            } else {
                VStack(spacing: 25) {
                    Text("🧠 Quiz des éléments")
                        .font(.largeTitle.bold())
                        .foregroundColor(.pink)
                    
                    Text("Choisis ton mode de jeu :")
                        .font(.title3)
                        .foregroundColor(.black)
                    
                    Button(action: { mode = .numberToElement }) {
                        Text("🔢 Numéro → Élément")
                            .font(.title3.bold())
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(15)
                    }
                    
                    Button(action: { mode = .elementToNumber }) {
                        Text("🧪 Élément → Numéro")
                            .font(.title3.bold())
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(15)
                    }
                    
                    Button(action: { showResults = true }) {
                        Text("📊 Résultats enregistrés")
                            .font(.title3.bold())
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink.opacity(0.15))
                            .cornerRadius(15)
                    }
                }
                .padding()
                .frame(maxWidth: 400)
            }
        }
        // 🔄 Recharge automatiquement les résultats iCloud à chaque ouverture
        .onAppear {
            _ = chargerResultats()
        }
    }
}

struct QuizView: View {
    let mode: QuizMode
    let onQuit: () -> Void
    
    @State private var questions = first30Elements.shuffled()
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var answerOptions: [String] = []
    @State private var selectedAnswer: String? = nil
    
    var currentQuestion: Element { questions[currentIndex] }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.1), Color.white]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("Question \(currentIndex + 1) sur \(questions.count)")
                    .font(.headline)
                    .foregroundColor(.pink)
                
                Group {
                    if mode == .numberToElement {
                        Text("Quel est l'élément n° \(currentQuestion.number) ?")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                    } else {
                        Text("Quel est le numéro atomique de \(currentQuestion.name) ?")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                    }
                }
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding()
                
                ForEach(answerOptions, id: \.self) { answer in
                    Button(action: { selectAnswer(answer) }) {
                        Text(answer)
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(buttonColor(for: answer))
                            .cornerRadius(12)
                    }
                    .disabled(selectedAnswer != nil)
                }
                
                Spacer()
                
                if showResult {
                    VStack {
                        Text("Score final : \(score)/\(questions.count)")
                            .font(.title.bold())
                            .foregroundColor(.pink)
                        
                        Button("Rejouer") {
                            resetQuiz()
                        }
                        .padding()
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(12)
                        
                        Button("🏠 Menu principal") {
                            saveScore()
                            onQuit()
                        }
                        .padding(.top, 10)
                    }
                } else {
                    Button(action: { onQuit() }) {
                        Text("Quitter")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .padding(.horizontal, 30) // largeur du bouton
                            .background(Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.3))
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 150)
                }
            }
            .padding()
            .onAppear(perform: generateAnswers)
        }
    }
    
    func generateAnswers() {
        let correctAnswer = mode == .numberToElement ? currentQuestion.name : String(currentQuestion.number)
        var options = Set([correctAnswer])
        
        while options.count < 4 {
            if mode == .numberToElement {
                options.insert(first30Elements.randomElement()!.name)
            } else {
                options.insert(String(Int.random(in: 1...30)))
            }
        }
        
        answerOptions = Array(options).shuffled()
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        let correctAnswer = mode == .numberToElement ? currentQuestion.name : String(currentQuestion.number)
        if answer == correctAnswer {
            score += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentIndex + 1 < questions.count {
                currentIndex += 1
                selectedAnswer = nil
                generateAnswers()
            } else {
                showResult = true
            }
        }
    }
    
    func buttonColor(for answer: String) -> Color {
        guard let selected = selectedAnswer else { return Color.pink.opacity(0.15) }
        let correctAnswer = mode == .numberToElement ? currentQuestion.name : String(currentQuestion.number)
        if selected == answer {
            return answer == correctAnswer ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
        }
        return Color.pink.opacity(0.15)
    }
    
    func resetQuiz() {
        questions.shuffle()
        currentIndex = 0
        score = 0
        showResult = false
        selectedAnswer = nil
        generateAnswers()
    }
    
    func saveScore() {
        var results = DataManager.shared.loadResults()
        results.append(score)
        DataManager.shared.saveResults(results)
        
        // 🔄 Sauvegarde aussi dans Fichiers et iCloud
        let texte = results.map { "Essai: \($0)/30" }.joined(separator: "\n")
        sauvegarderResultats(texte)
    }
}

struct ResultsView: View {
    let onBack: () -> Void
    
    @State private var scores: [Int] = []
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.15), Color.white]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Text("📊 Résultats enregistrés")
                .font(.largeTitle.bold())
                .foregroundColor(.pink)
                Button(action: {
                    // 🗑️ 1. Efface les données locales
                    DataManager.shared.clearResults()
                    scores.removeAll()
                    
                    // ☁️ 2. Efface aussi les données iCloud
                    let store = NSUbiquitousKeyValueStore.default
                    store.removeObject(forKey: iCloudKey)
                    store.synchronize()
                    print("☁️ Données iCloud effacées.")
                    
                    // 📁 3. Supprime aussi le fichier dans Fichiers
                    let fileManager = FileManager.default
                    if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let fileURL = documentDirectory.appendingPathComponent(fileName)
                        try? fileManager.removeItem(at: fileURL)
                        print("📂 Fichier local supprimé.")
                    }
                }) {
                    Text("🗑️ Effacer les résultats")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.2))
                        .cornerRadius(12)
                }
            .padding(.bottom, 10)
                
                if scores.isEmpty {
                    Text("Aucun résultat pour le moment.")
                        .foregroundColor(.gray)
                        .fontWeight(.heavy)
                        .padding(.bottom, 0)
                } else {
                    List {
                        ForEach(scores.indices, id: \.self) { index in
                            HStack {
                                Text("Essai \(index + 1): \(scores[index])/30")
                                Spacer()
                                if index > 0 {
                                    let previous = Double(scores[index - 1])
                                    let current = Double(scores[index])
                                    let improvement = ((current - previous) / previous) * 100
                                    Text(String(format: "%+.0f%%", improvement))
                                        .foregroundColor(improvement >= 0 ? .green : .red)
                                }
                            }
                        }
                    }
                }
                
                Button("🏠 Retour au menu") {
                    onBack()
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .padding(.horizontal, 30) // largeur du bouton
                .background(Color(red: 1.0, green: 0.0, blue: 1.0).opacity(0.2))
                .cornerRadius(12)
                .padding(.bottom, 200)
            }
            .padding()
            .onAppear {
                // 🔁 Charge d'abord les résultats normaux
                scores = DataManager.shared.loadResults()
                
                // 🔄 Essaie aussi de récupérer depuis iCloud si jamais le fichier local est vide
                let texte = chargerResultats()
                if !texte.isEmpty {
                    let lignes = texte.components(separatedBy: "\n")
                    let valeurs = lignes.compactMap { ligne -> Int? in
                        if let score = ligne.split(separator: "/").first?.split(separator: ":").last {
                            return Int(score.trimmingCharacters(in: .whitespaces))
                        }
                        return nil
                    }
                    if !valeurs.isEmpty {
                        scores = valeurs
                    }
                }
            }
        }
    }
}

func sauvegarderResultats(_ texte: String) {
    // 🧾 1. Sauvegarde locale (dans Fichiers)
    let fileManager = FileManager.default
    if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        do {
            try texte.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ Résultats sauvegardés localement.")
        } catch {
            print("❌ Erreur de sauvegarde locale : \(error)")
        }
    }

    // ☁️ 2. Sauvegarde dans iCloud
    let store = NSUbiquitousKeyValueStore.default
    store.set(texte, forKey: iCloudKey)
    store.synchronize()
    print("☁️ Résultats sauvegardés dans iCloud.")
}

func chargerResultats() -> String {
    // 🔄 1. Vérifie si une version iCloud existe
    let store = NSUbiquitousKeyValueStore.default
    if let texte = store.string(forKey: iCloudKey) {
        print("☁️ Résultats chargés depuis iCloud.")
        return texte
    }

    // 📁 2. Sinon charge la version locale
    let fileManager = FileManager.default
    if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        if let texte = try? String(contentsOf: fileURL, encoding: .utf8) {
            print("📂 Résultats chargés depuis le dossier local.")
            return texte
        }
    }

    print("⚠️ Aucun résultat trouvé.")
    return ""
}

// 🔓 Permet d'afficher le dossier "Documents" dans Fichiers
func rendreDossierVisibleDansFichiers() {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var resources = URLResourceValues()
    resources.isExcludedFromBackup = false
    do {
        var dossierURL = documentsURL
        try dossierURL.setResourceValues(resources)
    } catch {
        print("Erreur pour rendre le dossier visible : \(error)")
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
