//
//  Tarfah.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 10/05/1448 AH.
//

import Foundation
import SwiftUI
import Playgrounds

struct ContentView1: View {
    var body: some View {
        
        
           
        List{
            
            VStack{
                
                Image(.firstpic)
                    .resizable()
                    .frame(width: 120, height: 160)
                
                Text ("Great Job!")
                    .font(.title2)
                    .fontWeight(.bold)
                    
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            .listRowBackground(Color.clear)
            Section{
            Text("You are Completed")
                    .frame(maxWidth: .infinity, alignment: .center)
                   
                Text("5 Min")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .center)
                Text("of Breathing Exercis")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            header: {
                Text("About")
            }
            
    
            
            
            }
        
    }
}

#Preview {
    ContentView1()
}

#Playground {
    _ = 1 + 2
}

