import SwiftUI
import Playgrounds

struct Dhay22: View {
    var body: some View {
        
        
           
        List{
            
            VStack{
                
                Image(.garden)
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
    Dhay22()
}

#Playground {
    _ = 1 + 2
}
