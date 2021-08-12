//
//  FolderImageSelectorView.swift
//  AntTracker
//
//  Created by test on 09.08.2021.
//

import SwiftUI

struct ImageSymbolSelectorView: View {
    
    @Binding var selectedImage: String
    
    let imageSymbolSet: [String]
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: 20){
                
                ForEach(imageSymbolSet, id: \.self) { image in
                    
                    Image(systemName: image)
                        .onTapGesture {
                            selectedImage = image
                        }
                        .font(.title2)
                        .foregroundColor(image == selectedImage ? .primary : .secondary)
                        .imageScale(image == selectedImage ? .large : .medium)
                    
                }
                
            }
            .padding()
            
        }
        
    }
}

//struct FolderImageSelectorView_Previews: PreviewProvider {
//    static var previews: some View {
//        FolderImageSelectorView()
//    }
//}
