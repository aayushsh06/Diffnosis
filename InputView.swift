import SwiftUI

struct InputView: View {
    @EnvironmentObject var userData: UserData
    @State private var showImagePicker = false

    var sexes = ["Male", "Female"]

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            VStack {
                ScrollView {
                    VStack {
                        Text("Enter Your Information")
                            .font(.title)
                            .padding()
                            .foregroundColor(.black)

                        Group {
                            TextField("Name", text: $userData.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)

                            TextField("Age", text: $userData.age)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)

                            TextField("Height (cm)", text: $userData.height)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)

                            TextField("Weight (kg)", text: $userData.weight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)

                            Picker("Sex", selection: $userData.sex) {
                                ForEach(sexes, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            
                            TextField("Recently Visited Places", text: $userData.travelLocations)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .id("scrollViewID")
                    
                }

                HStack(spacing: 16) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                      .stroke(Color.black, lineWidth: 1)
                                    )
                    }

                    NavigationLink(destination: ChatbotView()) {
                        Text("Next")
                            .font(.title2)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                      .stroke(Color.black, lineWidth: 1)
                                    )
                    }
                }
                .padding()
                
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
        }
    }
}
