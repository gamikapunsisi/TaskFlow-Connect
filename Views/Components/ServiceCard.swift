import SwiftUI

struct ServiceCard: View {
    let service: ServiceItem
    @State private var isPressed = false

    var body: some View {
        Button {
            print("Selected: \(service.title)")
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(service.color)
                    .frame(height: 120)

                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: service.imageName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)

                    Text(service.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding()
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: service.color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 10, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
