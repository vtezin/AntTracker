//
//  TrackPolyline.swift
//  AntTracker
//
//  Created by test on 19.05.2021.
//

import Foundation
import SwiftUI
import MapKit

class TrackPolyline: MKPolyline {
    
    let track: Track?
    
    init(track: Track?) {
        self.track = track
    }
    
    func setOverlayRenderer() -> MKOverlayRenderer {
        
        let pr = MKPolylineRenderer(overlay: self)
        
        let color = UIColor(Color.getColorFromName(colorName: (subtitle ?? "orange") )).withAlphaComponent(1)
        
        pr.lineWidth = 4
        
        pr.strokeColor = color
        
        return pr
        
    }
    
}

func setTrackOverlayRenderer(trackPolilyne: MKPolyline) -> MKOverlayRenderer {
    
    let pr = MKPolylineRenderer(overlay: trackPolilyne)
    
    let color = UIColor(Color.getColorFromName(colorName: (trackPolilyne.subtitle ?? "orange") )).withAlphaComponent(1)
    
    pr.lineWidth = 4
    
    pr.strokeColor = color
    
    return pr
    
}
