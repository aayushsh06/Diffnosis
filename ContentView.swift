import SwiftUI

struct ContentView: View {
    @State private var isPressed = false
    @State private var showButton = true
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Text("Diffnosis")
                    .font(.system(size: 50, weight: .bold, design: .serif))
                    .padding()
                    .foregroundColor(.white)

                Image(systemName: "stethoscope")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding()

                Text("Your At Home Health Consultant")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                if showButton {
                    NavigationLink(destination: InputView()) {
                        Text("Get Started")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .scaleEffect(buttonScale)
                            .animation(.easeOut(duration: 0.5), value: buttonScale)
                            .onAppear {
                                withAnimation {
                                    buttonScale = 1.0
                                }
                            }
                    }
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                    .animation(.spring(), value: isPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    isPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isPressed = false
                                }
                            }
                    )
                }

                Spacer()
            }
            .padding(.horizontal)
            .background(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
