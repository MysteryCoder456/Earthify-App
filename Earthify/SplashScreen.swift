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
    
    let l_title = NSLocalizedString("splashscreen.title", comment: "Welcome to Earthify")
    let l_subtitle = NSLocalizedString("splashscreen.subtitle", comment: "Share your things with others\nHelp to reduce resource wastage")
    let l_continueButton = NSLocalizedString("splashscreen.continue", comment: "Continue")
    let l_continueAccessibility = NSLocalizedString("splashscreen_acc.continue", comment: "Continue to app")

    var body: some View {
        ZStack {
            VStack {
                Image(decorative: "forest")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: deviceDimensions.height * 0.5)
                    .ignoresSafeArea()

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

                    Text(l_title)
                        .font(.custom("Montserrat", size: 31))
                        .bold()
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    Text(l_subtitle)
                        .font(.custom("Montserrat", size: 18))

                    Button(action: { env.seenSplashScreen = true }) {
                        Text(l_continueButton)
                            .font(.custom("Montserrat", size: 20))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .padding(.top, 50)
                    .accessibility(label: Text(l_continueAccessibility))
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
