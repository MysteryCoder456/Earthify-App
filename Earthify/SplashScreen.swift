//
//  SplashScreen.swift
//  Earthify
//
//  Created by Rehatbir Singh on 08/07/2021.
//

import GoogleSignIn
import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject var env: EnvironmentObjects

    let deviceDimensions = UIScreen.main.bounds.size

    func signIn() {
        GIDSignIn.sharedInstance().presentingViewController = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance().signIn()
    }

    var body: some View {
        ZStack {
            VStack {
                Image("forest")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: deviceDimensions.height * 0.5)
                    .ignoresSafeArea()

                Spacer()
            }

            VStack {
                Spacer()

                VStack {
                    Image(systemName: "globe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55)
                        .foregroundColor(.accentColor)
                        .padding(.bottom)

                    Text("Welcome to Earthify")
                        .font(.custom("Montserrat", size: 31))
                        .bold()
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    Text("Share your things with others\nHelp to reduce resource wastage")
                        .font(.custom("Montserrat", size: 18))

                    // -------- Google Sign In Button --------
                    VStack {
                        Button(action: signIn) {
                            Label(
                                title: {
                                    Text("Sign In With Google")
                                        .font(.custom("Montserrat", size: 20))
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                },
                                icon: {
                                    Image("google_logo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    }
                    .padding(.top, 50)
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
