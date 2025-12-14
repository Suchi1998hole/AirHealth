import SwiftUI

struct FeedView: View {

    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text("Welcome to AirHealth 👋")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Button(role: .destructive) {
                    authVM.logout()
                } label: {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Feed")
        }
    }
}
