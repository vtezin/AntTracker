//
//  ThanksView.swift
//  AntTracker
//
//  Created by test on 30.09.2021.
//

import SwiftUI
import StoreKit

struct ThanksView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var products: [SKProduct] = []
    @State private var showThanks = false
    
    let gifts = ["🚛", "🥁", "⚽️", "🚁"]
    
    var body: some View {
        
        //NavigationView {
            
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
                        buyPrezentForMe()
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
                Spacer()
            }
        .navigationBarTitle(Text("Say thanks"), displayMode: .inline)
        .onAppear{
                loadProducts()
        }
        
        Spacer()
        
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
    
    func buyPrezentForMe() {
        if products.count > 0 {
            IAPProducts.store.buyProduct(products[0])
        }
        withAnimation {showThanks = true}
    }

}

struct ThanksView_Previews: PreviewProvider {
    static var previews: some View {
        ThanksView()
    }
}
