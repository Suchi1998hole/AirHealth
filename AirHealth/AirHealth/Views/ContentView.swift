import SwiftUI

struct ContentView: View {

    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                if authVM.needsOnboarding {
                    OnboardingView()
                } else {
                    FeedView()
                }
            } else {
                LoginView()
            }
        }
    }
}
