import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color(red: 254/255, green: 249/255, blue: 243/255)
                .ignoresSafeArea()
            Text("Home")
                .font(.largeTitle)
        }
    }
}

#Preview {
    HomeView()
}
