//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Constantin Lisnic on 19/06/2024.
//

import SwiftUI

struct boldText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .font( /*@START_MENU_TOKEN@*/.title /*@END_MENU_TOKEN@*/.bold())
    }
}

extension View {
    func boldTextStyle() -> some View {
        modifier(boldText())
    }
}

struct FlagImage: View {
    var country: String

    var body: some View {
        Image(country)
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

struct ContentView: View {
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var countries = [
        "Estonia", "France", "Germany", "Ireland", "Italy", "Monaco", "Nigeria",
        "Poland", "Spain", "UK", "Ukraine", "US",
    ].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var score = 0
    @State private var showFinalScore = false
    @State private var attempts = 0
    @State private var rotationDegrees = [0.0, 0.0, 0.0]
    @State private var opaqueAndScaledDownButons = [false, false, false]

    var body: some View {
        ZStack {
            RadialGradient(
                stops: [
                    .init(
                        color: Color(red: 0.1, green: 0.2, blue: 0.45),
                        location: 0.3),
                    .init(
                        color: Color(red: 0.76, green: 0.15, blue: 0.26),
                        location: 0.3),
                ], center: .top, startRadius: 200, endRadius: 400
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                Text("Guess the Flag")
                    .boldTextStyle()

                VStack(spacing: 15) {
                    Text("Tap the flag of")
                        .foregroundStyle(.secondary)
                        .font(.subheadline.weight(.heavy))

                    Text(countries[correctAnswer])
                        .font(.largeTitle.weight(.semibold))

                    ForEach(0..<3) { number in
                        Button {
                            withAnimation {
                                rotationDegrees[number] += 360
                                makeUnselectedAnswersOpaque(number)
                            }
                            flagTapped(number)
                        } label: {
                            FlagImage(country: countries[number])
                        }
                        .rotation3DEffect(
                            .degrees(rotationDegrees[number]),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .opacity(opaqueAndScaledDownButons[number] ? 0.25 : 1)
                        .scaleEffect(
                            opaqueAndScaledDownButons[number] ? 0.8 : 1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))

                Spacer()
                Spacer()

                Text("Score: \(score)")
                    .boldTextStyle()

                Spacer()
            }
            .padding()

        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(score)")
        }
        .alert(scoreTitle, isPresented: $showFinalScore) {
            Button("Restart", action: reset)
        } message: {
            Text("Your final score is \(score)")
        }
    }

    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1

        } else {
            scoreTitle = "Wrong, that's the flag of \(countries[number])"
        }
        attempts += 1

        if attempts == 8 {
            showFinalScore = true
        } else {
            showingScore = true
        }
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        opaqueAndScaledDownButons = [false, false, false]
        
    }

    func reset() {
        askQuestion()
        attempts = 0
        score = 0
    }

    func makeUnselectedAnswersOpaque(_ number: Int) {
        for index in 0..<opaqueAndScaledDownButons.count {
            opaqueAndScaledDownButons[index] = (index != number)
        }
    }
}

#Preview {
    ContentView()
}
