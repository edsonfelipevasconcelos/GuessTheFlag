//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by EDSON FELIPE VASCONCELOS on 11/04/23.
//

import SwiftUI

struct FlagImage: View {
    var name: String
    
    let labels = [
        "Estonia": "Flag with three horizontal stripes of equal size. Top stripe blue, middle stripe black, bottom stripe white",
        "France": "Flag with three vertical stripes of equal size. Left stripe blue, middle stripe white, right stripe red",
        "Germany": "Flag with three horizontal stripes of equal size. Top stripe black, middle stripe red, bottom stripe gold",
        "Ireland": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe orange",
        "Italy": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe red",
        "Nigeria": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe green",
        "Poland": "Flag with two horizontal stripes of equal size. Top stripe white, bottom stripe red",
        "Russia": "Flag with three horizontal stripes of equal size. Top stripe white, middle stripe blue, bottom stripe red",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background",
        "US": "Flag with red and white stripes of equal size, with white stars on a blue background in the top-left corner"
    ]
    
    var body: some View {
        Image(name)
            .renderingMode(.original)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
            .shadow(color: .black, radius: 1)
            .accessibility(label: Text(self.labels[name] ?? "Unknown Flag"))
    }
}

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.bold())
            .foregroundColor(Color(red: 0.5, green: 0.9, blue: 0.8))
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Title())
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var userScore = 0
    @State private var questionsAmount = 0
    @State private var flagTapped: Int? = nil
    
    @State private var animationAmount = 0.0
    @State private var animation = false
    
    
    var body: some View {
        ZStack {
            //            LinearGradient(gradient: Gradient(colors: [.green, .black]), startPoint: .top, endPoint: .bottom)
            //                .ignoresSafeArea()
            RadialGradient(stops: [
                .init(color: Color(red: 0.5, green: 0.9, blue: 0.8), location: 0.3),
                .init(color: Color(red: 0.45, green: 0.1, blue: 0.5), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 400)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(red: 0.45, green: 0.1, blue: 0.5))
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(.secondary)
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            withAnimation(.easeOut(duration: 1)) {
                                self.animation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                questionsAmount += 1
                                flagTapped = number
                                self.flagTapped(number)
                            }
                        } label: {
                            FlagImage(name: countries[number])
                                .rotation3DEffect(.degrees(number == self.correctAnswer && self.animation ? 360 : 0.0), axis: (x: 0, y: 1, z: 0))
                                .scaleEffect(number != self.correctAnswer && self.animation ? 0 : 1)
                                .opacity(number != self.correctAnswer && self.animation ? 0.25 : 1)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(userScore)")
                    .titleStyle()
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            if questionsAmount < 8 {
                Button("Continue", action: askQuestion)
            } else {
                if userScore < 5 {
                    Button("Try again", action: reset)
                } else {
                    Button("New game", action: reset)
                }
            }
        } message: {
            if questionsAmount < 8 {
                Text("Your score is \(userScore)")
            } else {
                if userScore < 5 {
                    Text("Game over! Your score is \(userScore).")
                } else {
                    Text("You won! Your score is \(userScore).")
                }
            }
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            userScore += 1
            animation = false
        } else {
            scoreTitle = "Wrong! That’s the flag of \(countries[flagTapped!])"
            userScore -= 1
            animation = false
        }
        
        showingScore = true
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    
    func reset() {
        userScore = 0
        questionsAmount = 0
        askQuestion()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
