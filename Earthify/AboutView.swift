//
//  AboutView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 15/10/2021.
//

import SwiftUI

struct AboutView: View {
    let currentAge: Int
    
    let l_aboutEarthifyTitle = NSLocalizedString("aboutview.about_earthify_title", comment: "About Earthify Title")
    let l_aboutEarthifyContent = NSLocalizedString("aboutview.about_earthify_content", comment: "About Earthify Content")
    let l_aboutDeveloperTitle = NSLocalizedString("aboutview.about_developer_title", comment: "About The Developer Title")
    let l_aboutDeveloperContent: String

    init() {
        // Dynamically calculate age from birthday
        var components = DateComponents()
        components.day = 25
        components.month = 9
        components.year = 2006
        let birthDate = Calendar.current.date(from: components)!
        currentAge = Int(birthDate.timeIntervalSinceNow / -31_536_000)
        
        l_aboutDeveloperContent = NSLocalizedString("aboutview.about_developer_content \(currentAge)", comment: "About The Developer Content")
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 7) {
                Text(l_aboutEarthifyTitle)
                    .font(.custom("Montserrat-Bold", size: 25))

                Text(l_aboutEarthifyContent)
            }
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(15)
            .accessibilityElement(children: .combine)

            Spacer()

            VStack(spacing: 7) {
                Text(l_aboutDeveloperTitle)
                    .font(.custom("Montserrat-Bold", size: 25))

                Text(l_aboutDeveloperContent)
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
