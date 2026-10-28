import SwiftUI

struct MyGardensView: View {

    @ObservedObject var gardenManager: GardenProgressManager

    var body: some View {
        VStack(spacing: 20) {

            Text("My Gardens")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(BloomoveColors.darkGreen)

            if gardenManager.completedGardens.isEmpty {

                Text("Your completed gardens will appear here.")
                    .foregroundStyle(BloomoveColors.secondaryText)

            } else {

                ScrollView {
                    LazyVStack(spacing: 16) {

                        ForEach(
                            Array(gardenManager.completedGardens.enumerated()),
                            id: \.element.id
                        ) { index, garden in
                            NavigationLink {
                                CompletedGardenDetailView(garden: garden)
                            } label: {
                                
                                HStack {
                                    Image(systemName: "leaf.fill")
                                        .foregroundStyle(BloomoveColors.darkGreen)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Garden \(index + 1)")
                                            .font(.headline)
                                        
                                        Text("\(garden.flowers.count) Flowers")
                                            .font(.subheadline)
                                            .foregroundStyle(BloomoveColors.secondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(BloomoveColors.primaryPink)
                                }
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer()
        }
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BloomoveColors.background)
    }
}

#Preview {
    MyGardensView(
        gardenManager: GardenProgressManager()
    )
}
