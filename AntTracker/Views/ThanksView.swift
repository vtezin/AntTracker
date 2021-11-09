//
//  ThanksView.swift
//  Reminder
//
//  Created by test on 15.10.2021.
//

import SwiftUI
import StoreKit

struct ThanksView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var products: [SKProduct] = []
    @State private var showThanks = false
    
    let gifts = ["🚛", "🥁", "⚽️", "🚁"]
    
    var body: some View {
        
        VStack{
            
            VStack(alignment: .leading){
                Text("  All functionality of this application is provided absolutely free. This is the author's principled approach.")
                Text("  Nevertheless, if you liked the application, then you can make a nice little gift for the author ))")
            }
            .padding()
            
            Spacer()
            
            if showThanks{
                VStack{
                    Text("Thanks!")
                    Text("🙃")
                    Text("(the purchase dialog will open in a couple of seconds)")
                        .modifier(SecondaryInfo())
                }
                .font(.largeTitle)
                .transition(.move(edge: .bottom))
            } else {
                Button(action: {
                    buyPresentForMe()
                }) {
                    VStack{
                        Text("Buy a small")
                        Text("\(gifts.randomElement()!)")
                            .font(.largeTitle)
                        Text("for the author")
                        Text("(it's not expensive)")
                    }
                    .padding()
                }
            }
            
            Spacer()
            VStack{
                Button(action: shareApp) {
                    Text("Share with the world")
                        .modifier(ButtonStyle())
                }
                Button(action: praiseApp) {
                    Text("Praise in the App Store")
                        .modifier(ButtonStyle())
                }
            }.padding()
        }
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                HStack{
                    Image(systemName: "hand.thumbsup")
                }
            }
        })
        .onAppear{
            loadProducts()
        }
        .navigationBarTitle(Text("Say thanks"), displayMode: .inline)
        
        Spacer()
        
    }
    
    
}

extension ThanksView {
    
    func shareApp() {
        
        // Show the share-view
        let av = UIActivityViewController(activityItems: ["https://apps.apple.com/us/app/ant-tracker-gps-tracker/id1562649021"], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        
    }
    
    func praiseApp() {
        
        /* First create a URL, then check whether there is an installed app that can
         open it on the device. */
        if let url = URL(string: "https://apps.apple.com/us/app/ant-tracker-gps-tracker/id1562649021"), UIApplication.shared.canOpenURL(url) {
            // Attempt to open the URL.
            UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                                        if success {
                                            print("Launching \(url) was successful")
                                        }})
        }
        
        
    }
    
    func loadProducts() {
        IAPProducts.store.requestProducts{ [] success, products in
            if success {
                self.products = products!
                //print("\(products!.count)")
            }
            else {
                //print("error")
            }
        }}
    
    func buyPresentForMe() {
        DispatchQueue.main.async {
            if products.count > 0 {
                IAPProducts.store.buyProduct(products[0])
            }
            withAnimation {showThanks = true}
        }
    }
    
}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 1))
    }
}

struct ThanksView_Previews: PreviewProvider {
    static var previews: some View {
        ThanksView()
    }
}

