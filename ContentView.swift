import SwiftUI
import UIKit
class UserData: ObservableObject {
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var email: String = ""
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var sex: String = "Male"
    @Published var selectedImage: UIImage? = nil
}
@main
struct DiffnosisApp: App {
    @StateObject private var userData = UserData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userData)
        }
    }
}
struct ContentView: View {
    @State private var isPressed = false
    @State private var showButton = false
    @State private var buttonScale: CGFloat = 0.5
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Diffnosis")
                    .font(.system(size: 50, weight: .bold, design: .serif))
                    .padding()
                    .foregroundColor(.blue)
                Image(systemName: "stethoscope")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding()
                Text("Your At Home Health Consultant")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                Spacer()
                if showButton {
                    NavigationLink(destination: InputView()) {
                        Text("Get Started")
                            .font(.title2)
                            .padding()
                            .background(Color.blue)
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showButton = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
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
                        Group {
                            TextField("Name", text: $userData.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            TextField("Age", text: $userData.age)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding()
                            TextField("Email", text: $userData.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .padding()
                            TextField("Height (cm)", text: $userData.height)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding()
                            TextField("Weight (kg)", text: $userData.weight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding()
                            Picker("Sex", selection: $userData.sex) {
                                ForEach(sexes, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                        }
                        if let image = userData.selectedImage {
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 250, maxHeight: 250)
                                    .cornerRadius(10)
                                    .padding()
                            }
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .padding()
                        }
                    }
                    .padding()
                    .id("scrollViewID")
                }
                .onChange(of: userData.selectedImage) { _ in
                    DispatchQueue.main.async {
                        withAnimation {
                            scrollViewProxy.scrollTo("scrollViewID", anchor: .bottom)
                        }
                    }
                }
                HStack(spacing: 16) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .padding()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: ChatbotView()) {
                        Text("Next")
                            .font(.title2)
                            .padding()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showImagePicker, content: {
                ImagePicker(image: $userData.selectedImage)
            })
        }
    }
}
struct ChatbotView: View {
    @EnvironmentObject var userData: UserData
    @State private var message: String = ""
    @State private var messages: [String] = []
    @State private var isLoading: Bool = false
    private let openAIService = OpenAIService()
    private let scrollViewID = "scrollViewID"
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack {
                        ForEach(messages, id: \.self) { msg in
                            if msg.starts(with: "You: ") {
                                HStack {
                                    Spacer()
                                    Text(String(msg.dropFirst(5)))
                                        .padding()
                                        .background(Color.blue.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            } else {
                                HStack {
                                    Text(String(msg.dropFirst(4)))
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .id(scrollViewID)
                }
                .onChange(of: messages) { _ in
                    withAnimation {
                        scrollViewProxy.scrollTo(scrollViewID, anchor: .bottom)
                    }
                }
            }
            HStack {
                TextField("Type your message...", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: sendMessage) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(message.isEmpty || isLoading)
            }
        }
        .navigationTitle("Chat with AI")
        .navigationBarItems(trailing:
            NavigationLink(destination: ContentView()) {
                Image(systemName: "house.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
        )
        .navigationBarBackButtonHidden(true)
        .padding()
        .onAppear {
            if userData.selectedImage != nil {
                messages.append("AI: Hello! I am your virtual health assistant. I'm here to help you understand your symptoms and provide information based on your input. I have analyzed the image you provided.")
                analyzeImage(userData.selectedImage!)
            } else {
                messages.append("AI: Hello! I am your virtual health assistant. I'm here to help you understand your symptoms and provide information based on your input. Please describe your symptoms:")
            }
        }
        .onDisappear {
            messages.removeAll()
        }
    }
    private func sendMessage() {
        guard !message.isEmpty else { return }
        messages.append("You: \(message)")
        isLoading = true
        // Append user data to the message content
        let userInformation = """
        Here is the user's information:
        Name: \(userData.name)
        Age: \(userData.age)
        Email: \(userData.email)
        Height: \(userData.height) cm
        Weight: \(userData.weight) kg
        Sex: \(userData.sex)
        """
        let messagesToSend = [
            ChatMessage(role: "user", content: "\(message) \n\n\(userInformation)")
        ]
        openAIService.fetchChatCompletion(messages: messagesToSend) { response in
            DispatchQueue.main.async {
                if let response = response {
                    messages.append("AI: \(response)")
                } else {
                    messages.append("AI: Sorry, I couldn't get a response.")
                }
                isLoading = false
                message = ""
            }
        }
    }
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
struct ChatMessage: Codable {
    let role: String
    let content: String
}
class OpenAIService {
    func fetchChatCompletion(messages: [ChatMessage], completion: @escaping (String?) -> Void) {
        guard let message = messages.first?.content else {
            completion(nil)
            return
        }
        getChatbotResponse(for: message) { response in
            completion(response)
        }
    }
    func analyzeImage(imageData: Data, completion: @escaping (String?) -> Void) {
        let imageBase64String = imageData.base64EncodedString()
        let prompt = """
        I have analyzed an image. Here is the Base64 encoding: data:image/jpeg;base64,\(imageBase64String). Please provide a detailed analysis and expected insights based on this data. Limit your response to 50 words, and do not include disclaimers like 'I am not a medical professional.'
        """
        getChatbotResponse(for: prompt) { response in
            completion(response)
        }
    }
    
    private func getChatbotResponse(for input: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": "llama-3.2-11b-vision-preview",
            "messages": [
                ["role": "user", "content": input]
            ],
            "temperature": 0.7,
            "max_tokens": 100,
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    print("Unexpected JSON format")
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(responseString)")
                }
                completion(nil)
            }
        }
        task.resume()
    }
}


