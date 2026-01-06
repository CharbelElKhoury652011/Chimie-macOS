import Foundation

class DataManager {
    static let shared = DataManager()
    private init() {}

    private var resultsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("resultats.json")
    }

    func saveResults(_ results: [Int]) {
        do {
            let data = try JSONEncoder().encode(results)
            try data.write(to: resultsFileURL, options: .atomic)
            print("✅ Résultats sauvegardés : \(resultsFileURL)")
        } catch {
            print("❌ Erreur de sauvegarde : \(error)")
        }
    }

    func loadResults() -> [Int] {
        do {
            let data = try Data(contentsOf: resultsFileURL)
            let results = try JSONDecoder().decode([Int].self, from: data)
            return results
        } catch {
            print("ℹ️ Aucun fichier trouvé, liste vide.")
            return []
        }
    }

    func clearResults() {
        saveResults([])
        print("🧹 Fichier vidé.")
    }
}
