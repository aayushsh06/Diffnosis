import SwiftUI
import UIKit

class UserData: ObservableObject {
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var sex: String = "Male"
    @Published var selectedImage: UIImage? = nil
    @Published var travelLocations: String = ""
}
