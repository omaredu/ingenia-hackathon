import SwiftUI

struct AvatarView: View {
    let avatarName: String?
    let placeholderName: String = "Avatar" // This is used as a system image name, not translated

    var body: some View {
        if let name = avatarName, !name.isEmpty {
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
        } else {
            Image(systemName: placeholderName)
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .foregroundColor(.gray) // Optional: give placeholder a distinct color
        }
    }
}

// Optional Preview
// struct AvatarView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            AvatarView(avatarName: "Aldo", placeholderName: "person.crop.circle.fill") // Assuming "Aldo" is an asset
//            AvatarView(avatarName: nil, placeholderName: "person.crop.circle.fill")
//            AvatarView(avatarName: "", placeholderName: "person.crop.circle")
//            AvatarView(avatarName: "NonExistent", placeholderName: "person.crop.circle") // Test with a non-existent asset name
//        }
//        .padding()
//    }
// } 
