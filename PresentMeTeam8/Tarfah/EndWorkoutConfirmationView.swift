//
//  EndWorkoutConfirmationView.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 13/05/1448 AH.
//

import SwiftUI

struct EndWorkoutConfirmationView: View {
    
    
    let totalMinutes: Int
    let completedMinutes: Int

    var remainingMinutes: Int {
        max(0, totalMinutes - completedMinutes)
    }
 
    
   

    
    
    var onKeepExercising: () -> Void = {}
    var onEndWorkout: () -> Void = {}


    var body: some View {
        ZStack {
            BloomoveColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 16)  {
                
               
                Image("earlyWorkoutBud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                
                
                Text("You're Doing Great!")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(BloomoveColors.darkGreen)
                    .multilineTextAlignment(.center)
// Green Card
                VStack(spacing: 12) {
                    Text("You've Completed")
                        .font(.system(size: 18))
                        .foregroundStyle(BloomoveColors.secondaryText)

                    Text("\(completedMinutes) Min")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(BloomoveColors.darkGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(BloomoveColors.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
// Pink Card
                VStack(spacing: 12) {
                    Text("Time Remaining")
                        .font(.system(size: 18))
                        .foregroundStyle(BloomoveColors.secondaryText)

                    Text("\(remainingMinutes) Min")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(BloomoveColors.primaryPink)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(red: 0.98, green: 0.93, blue: 0.94))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
                
                
                Spacer(minLength: 20)

    // Keepgoing button
                
                Button {
                    onKeepExercising()
                } label: {
                    Text("Keep Exercising")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(BloomoveColors.primaryPink)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 24)
                
                
                
// End buttom
                Button {
                    onEndWorkout()
                } label: {
                    Text("End Anyway")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(BloomoveColors.primaryPink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    BloomoveColors.primaryPink,
                                    lineWidth: 1.5
                                )
                        }
                }
                .padding(.horizontal, 24)




            }

        }
    }
}

#Preview {
    EndWorkoutConfirmationView(
        totalMinutes: 10,
        completedMinutes: 6
    )
}
