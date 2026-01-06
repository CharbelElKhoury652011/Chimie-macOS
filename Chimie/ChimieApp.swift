import SwiftUI
import UserNotifications

@main
struct ChimieApp: App {
    init() {
        requestNotificationPermission()
        scheduleDailyNotification()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("✅ Autorisation des notifications accordée")
            } else {
                print("❌ Autorisation refusée")
            }
        }
    }

    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()

        // Supprime les anciennes notifications pour éviter les doublons
        center.removeAllPendingNotificationRequests()

        // Messages possibles
        let messages = [
            "Venez vous entraîner, le labo vous attend 🧪",
            "Qu’est-ce qu’il y a de plus joli que quelques minutes d’entraînement de Chimie ? ⚗️"
        ]
        let randomMessage = messages.randomElement()!

        // Contenu de la notification
        let content = UNMutableNotificationContent()
        content.title = "Chimie"
        content.body = randomMessage
        content.sound = .default

        // Définir l’heure : 17h00
        var dateComponents = DateComponents()
        dateComponents.hour = 17
        dateComponents.minute = 0

        // Déclencheur tous les jours à 17h
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Crée la requête
        let request = UNNotificationRequest(identifier: "dailyChimieNotification", content: content, trigger: trigger)

        // Ajoute la notification
        center.add(request) { error in
            if let error = error {
                print("Erreur de notification : \(error.localizedDescription)")
            } else {
                print("✅ Notification quotidienne programmée à 17h")
            }
        }
    }
}
