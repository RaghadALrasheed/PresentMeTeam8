//
//  CompletionView.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 11/05/1448 AH.
//



import SwiftUI

struct CompletionView: View {
    let completedMinutes: Int
    let flowerProgressMinutes: Int
    
    let onViewGarden: () -> Void
    let onBackHome: () -> Void
  
    var body: some View {
        ZStack {
            BloomoveColors.background
                .ignoresSafeArea()
    // Image
            VStack(spacing: 24) {
                Image("completionFlower")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)
                
   // Great job
                Text("Well done!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(BloomoveColors.darkGreen)

// Green Card
                VStack(spacing: 12) {
                    Text("You completed")
                        .font(.system(size: 18))
                        .foregroundStyle(BloomoveColors.secondaryText)

                    Text("\(completedMinutes) Min")                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(BloomoveColors.darkGreen)

                    Text("of movement")
                        .font(.system(size: 18))
                        .foregroundStyle(BloomoveColors.secondaryText)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(BloomoveColors.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
                
                
                VStack(spacing: 8) {
                    Text("Your flower is growing! 🌱")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(BloomoveColors.darkGreen)

                    Text("Flower Growth: \(flowerProgressMinutes) / 30 min")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(BloomoveColors.darkGreen)
                }
                .multilineTextAlignment(.center)
                
                
                Spacer(minLength: 20)
            
    //Buttom
                
                Button {
                    onViewGarden()
                } label: {                    Text("View My Garden")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(BloomoveColors.primaryPink)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal, 20)
//Second Buttom
                Button {
                    onBackHome()
                } label: {
                    Text("Return home")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(BloomoveColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .padding(.horizontal, 20)

            }
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
    }
}
#Preview {
    CompletionView (
        completedMinutes: 10,
        flowerProgressMinutes: 23,
        onViewGarden: {},
        onBackHome: {}
    )
}
