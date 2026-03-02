import SwiftUI

@main
struct FoodAppApp: App {
    @StateObject private var repository = FoodRepository()
    @StateObject private var profile = UserProfile()

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("홈")
                    }

                HistoryView()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("기록")
                    }

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("설정")
                    }
            }
            .tint(Color(red: 1.0, green: 0.42, blue: 0.42))
            .environmentObject(repository)
            .environmentObject(profile)
        }
    }
}
