//
//  SplashScreen.swift
//  Earthify
//
//  Created by Rehatbir Singh on 08/07/2021.
//

import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject var env: EnvironmentObjects

    let deviceDimensions = UIScreen.main.bounds.size

    var body: some View {
        ZStack {
            VStack {
                Image("forest")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: deviceDimensions.height * 0.5)
                    .ignoresSafeArea()
                    .accessibility(hidden: true)

                Spacer()
            }

            VStack {
                Spacer()

                VStack {
                    Image(systemName: "globe.europe.africa.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55)
                        .foregroundColor(.accentColor)
                        .padding(.bottom)
                        .accessibility(hidden: true)

                    Text("Welcome to Earthify")
                        .font(.custom("Montserrat", size: 31))
                        .bold()
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    Text("Share your things with others\nHelp to reduce resource wastage")
                        .font(.custom("Montserrat", size: 18))
                    
                    Button(action: { env.seenSplashScreen = true }) {
                        Text("Continue")
                            .font(.custom("Montserrat", size: 20))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .padding(.top, 50)
                    .accessibilityLabel("Continue to app")
                }
                .frame(width: deviceDimensions.width, height: deviceDimensions.height * 0.55, alignment: .center)
                .background(Color.primary.colorInvert())
                .cornerRadius(50)
                .multilineTextAlignment(.center)
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
