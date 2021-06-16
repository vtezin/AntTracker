//
//  PointControls.swift
//  AntTracker
//
//  Created by test on 22.05.2021.
//

import SwiftUI

extension MainView {
    
    var buttonAddPoint: some View {
        
        Button(action: {
            constants.editingPoint = nil
            withAnimation{
                activePage = ContentView.pages.editPoint
            }
            showPointsManagment = false
        }) {
            Image(systemName: "star")
        }
        
        .modifier(ControlButton())
        
    }
    
    var buttonAddPointFromClipboard: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "arrow.down.to.line")
        }
        
        .modifier(ControlButton())
        
    }
    
}
