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
            appVariables.editingPoint = nil
            withAnimation{
                activePage = ContentView.pages.editPoint
            }
            showPointsManagment = false
        }) {
            VStack{
                Image(systemName: "star").modifier(ControlButton())
                Text("Add").buttonText()
            }
        }
        
    }
    
    var buttonAddPointFromClipboard: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "arrow.down.to.line")
        }
        
        .modifier(ControlButton())
        
    }
    
    var buttonHideShowPoints: some View {
        
        Button(action: {
            showPointsOnTheMap.toggle()
            appVariables.needRedrawPointsOnMap = true
        }) {
            VStack{
                Image(systemName: showPointsOnTheMap ? "eye.slash" : "eye")
                    .modifier(ControlButton())
                Text(showPointsOnTheMap ? "Hide" : "Show").buttonText()
            }
        }
        
    }
    
}
