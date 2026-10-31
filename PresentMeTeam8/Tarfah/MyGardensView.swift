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
                                            .foregroundStyle(BloomoveColors.darkGreen)
                                        
                                        Text("\(garden.flowers.count) Flowers")
                                            .foregroundStyle(BloomoveColors.darkGreen)
                                            .font(.subheadline)
                                            .foregroundStyle(BloomoveColors.secondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(BloomoveColors.darkGreen)
                                }
                                .padding()
                                .background(
                                    Color(red: 234/255, green: 239/255, blue: 225/255),
                                    in: RoundedRectangle(cornerRadius: 20)
                                )
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
