//
//  Najla.swift
//  PresentMeTeam8
//
//  Created by Najla Ibrahim Alnaimi on 10/05/1448 AH.
//

import Foundation
import SwiftUI
import Playgrounds

struct Najla1: View {
    var body: some View {
        List{
            HStack{
                Spacer()
                
                    Text("skip")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            VStack{
                
                Image(.flower)
                    .resizable()
                    .frame(width: 280, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 24)
                               )
                    
                Text("Your movement grows your garden!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Each run gives you something\nworth returning to.")
                    .font(.system(size: 16))
            }
            
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
        
            HStack(spacing: 8) {
                Circle().fill(Color.pink.opacity(0.3)).frame(width: 10, height: 10)
                Circle().fill(Color.pink).frame(width: 10, height: 10)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            }
            
        }
        
 
    
        
    }

#Preview {
    Najla1()
}


