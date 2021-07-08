//
//  SplashScreen.swift
//  Earthify
//
//  Created by Rehatbir Singh on 08/07/2021.
//

import SwiftUI

struct SplashScreen: View {
    let deviceDimensions = UIScreen.main.bounds.size
    
    var body: some View {
        ZStack {
            VStack {
                Image("forest")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: deviceDimensions.height * 0.44)
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
                        .foregroundColor(Color(.sRGB, red: 0.39, green: 0.77, blue: 0.21, opacity: 1.0))
                        .padding(.top, 5)
                    
                    Text("Welcome to Earthify")
                        .font(.custom("Montserrat", size: 31))
                        .bold()
                        .foregroundColor(Color(.sRGB, red: 0.07, green: 0.23, blue: 0.0, opacity: 1.0))
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    
                    Text("Share your things with others\nHelp to reduce resource wastage")
                        .font(.custom("Montserrat", size: 18))
                    
                    
                    // -------- Authentication Buttons --------
                    
                    VStack(spacing: 15) {
                        Button(action: {}) {
                            HStack {
                                Spacer()
                                
                                Text("Sign Up")
                                    .font(.custom("Montserrat", size: 20))
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.sRGB, red: 0.39, green: 0.77, blue: 0.21, opacity: 1.0))
                        .clipShape(RoundedRectangle(cornerRadius: 12.0, style: .circular))
                        
                        Button(action: {}) {
                            HStack {
                                Spacer()
                                
                                Text("Login")
                                    .font(.custom("Montserrat", size: 20))
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                        }
                        .padding(.vertical)
                        .background(Color.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12.0, style: .circular))
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 40)
                    
                }
                .frame(width: deviceDimensions.width, height: deviceDimensions.height * 0.56, alignment: .center)
                .background(Color.primary.colorInvert())
                .clipShape(RoundedRectangle(cornerRadius: 30))
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
