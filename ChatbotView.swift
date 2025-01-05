import SwiftUI
import UIKit

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
                                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            } else {
                                HStack {
                                    Text(String(msg.dropFirst(4)))
                                        .padding()
                                        .background(Color.white.opacity(0.7))
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
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                Button(action: sendMessage) {
                    Text("Send")
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(message.isEmpty || isLoading)
            }
        }
        .navigationTitle("Chat with AI")
        .navigationBarItems(trailing:
            NavigationLink(destination: ContentView().navigationBarHidden(true)) {
                Image(systemName: "house.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
        )
        .navigationBarBackButtonHidden(true)
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
        .onAppear {
            if userData.selectedImage != nil {
                messages.append("AI: Hello! I am your virtual health assistant. Based on your uploaded image, here are some insights and suggestions.")
                analyzeImage(userData.selectedImage!)
            } else {
                messages.append("AI: Hello! I am your virtual health assistant. Please describe any symptoms you're experiencing.")
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

        let travelLocations = userData.travelLocations.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        
        let userInformation = """
        User Information:

        Age: \(userData.age)
        Height: \(userData.height) cm
        Weight: \(userData.weight) kg
        Sex: \(userData.sex)
        Recently Visited Places: \(userData.travelLocations)
        """

        let contentToSend = """
        \(message)
        
        \(userInformation)
        
        Take all of this information into account when analyzing the user, but only focus on this data if it is relevant to the user. Only focus on travel history if it has been specified, if not do not worry about it. Additionally, focus on using general medical advice available to you to diagnose, and if you believe the user statistics to be relevant, then only refer to them and use them. Lastly, make sure your messages are concise and don't abruptly cut off due to the 100 token limit, so make sure to be well under that.".
        """

        let messagesToSend = [
            ChatMessage(role: "user", content: contentToSend)
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

    private func analyzeImage(_ image: UIImage) {
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            self.messages.append("AI: Unable to process the image. Please try again with a different image.")
            return
        }

        // Convert image data to Base64
        let base64Image = imageData.base64EncodedString()

        // API Request Parameters
        let requestBody: [String: Any] = [
            "model": "llama-3.2-11b-vision-preview",
            "messages": [
                ["role": "user", "content": "Analyze this medical image."],
                ["role": "system", "content": "data:image/jpeg;base64,\(base64Image)"]
            ],
            "temperature": 0.7,
            "max_tokens": 200
        ]

        // API URL
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            self.messages.append("AI: Unable to process the request. Invalid API URL.")
            return
        }

        // Create API Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode request body as JSON
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        // Perform API Call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.messages.append("AI: Error analyzing the image: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.messages.append("AI: No data received from the server.")
                }
                return
            }

            // Parse the API Response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.messages.append("AI: \(content)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.messages.append("AI: Unable to interpret the server's response.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.messages.append("AI: Error parsing the server's response: \(error.localizedDescription)")
                }
            }
        }.resume()
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
        I have analyzed an image. Here is the Base64 encoding: data:image/jpeg;base64,\(imageBase64String). Please provide a detailed analysis and expected insights based on this data. Limit your response to 50 words.'
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
        request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "llama-3.2-11b-vision-preview",
            "messages": [
                ["role": "user", "content": input]
            ],
            "temperature": 0.7,
            "max_tokens": 400,
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

