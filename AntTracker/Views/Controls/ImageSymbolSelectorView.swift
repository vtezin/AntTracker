//
//  FolderImageSelectorView.swift
//  AntTracker
//
//  Created by test on 09.08.2021.
//

import SwiftUI

let folderImages = ["folder", "car", "figure.walk", "bicycle", "ant", "star", "face.smiling"]

struct ImageSymbolSelectorView: View {
    
    @Binding var selectedImage: String
    @Binding var showSelectorOnRequestor: Bool
    
    var body: some View {
        HStack(){
            
            ForEach(folderImages, id: \.self) { image in
                
                Image(systemName: image)
                    .onTapGesture {
                        selectedImage = image
                        showSelectorOnRequestor = false
                    }
                    .font(.title)
                    .foregroundColor(image == selectedImage ? .primary : .secondary)
                    .imageScale(image == selectedImage ? .large : .medium)
                
            }
            
        }
    }
}

//struct FolderImageSelectorView_Previews: PreviewProvider {
//    static var previews: some View {
//        FolderImageSelectorView()
//    }
//}
