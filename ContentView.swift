import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Welcome to TaskFlow!")
                .font(.largeTitle)
                .padding()
            
            Button("Log Out") {
                authVM.signOut()
            }
            .foregroundColor(.red)
            .padding()
        }
    }
}
