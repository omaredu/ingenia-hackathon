import SwiftUI

struct ChatDetailPlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "bubble.left.and.bubble.right")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            Text("Selecciona un chat para comenzar a mensajear")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
}

struct ChatDetailPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailPlaceholderView()
    }
} 