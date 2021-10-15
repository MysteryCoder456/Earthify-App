//
//  AboutView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 15/10/2021.
//

import SwiftUI

struct AboutView: View {
    let currentAge: Int

    init() {
        // Dynamically calculate age from birthday
        var components = DateComponents()
        components.day = 25
        components.month = 9
        components.year = 2006
        let birthDate = Calendar.current.date(from: components)!
        currentAge = Int(birthDate.timeIntervalSinceNow / -31_536_000)
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 7) {
                Text("About Earthify")
                    .font(.custom("Montserrat-Bold", size: 25))

                Text(
                    "Earthify is an app where you can share the things you no longer need. " +
                        "Something that is no longer of any use to you might be life changing for " +
                        "someone else!"
                )
            }
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(15)
            .accessibilityElement(children: .combine)

            Spacer()

            VStack(spacing: 7) {
                Text("About The Developer")
                    .font(.custom("Montserrat-Bold", size: 25))

                Text(
                    "Rehatbir Singh is a \(currentAge) year old programmer. He likes to code, " +
                        "play guitar, and play video games. He makes iOS apps and does some game dev too."
                )
            }
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(15)
            .accessibilityElement(children: .combine)

            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 13)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AboutView()
        }
    }
}
