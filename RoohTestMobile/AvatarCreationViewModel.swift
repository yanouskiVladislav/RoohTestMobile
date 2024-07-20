import Combine

class AvatarCreationViewModel: ObservableObject {
    @Published var selectedAge: Int = 0
    @Published var selectedWeight: Int = 0
    @Published var selectedHeight: Int = 0
    @Published var selectedAvatar: String = ""
    
    var avatars = ["avatar-1", "avatar-2", "avatar-3", "avatar-4", "avatar-5", "avatar-6", "avatar-7", "avatar-8", "avatar-9", "avatar-10"]
    
    func selectAvatar(at index: Int) {
        guard index >= 0 && index < avatars.count else { return }
        selectedAvatar = avatars[index]
    }
}



