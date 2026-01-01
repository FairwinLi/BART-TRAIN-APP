import SwiftUI

struct TrainRow: View {
    let train: Train
    let isDark: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Line Badge
            Text(train.line)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(hex: train.color))
                .cornerRadius(8)
            
            // Destination & Time
            VStack(alignment: .leading, spacing: 4) {
                Text(train.destination)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDark ? .white : .black)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(isDark ? .gray : .gray)
                    
                    Text(train.time, style: .time)
                        .font(.system(size: 14))
                        .foregroundColor(isDark ? .gray : .gray)
                    
                    if train.status != .onTime {
                        Text("•")
                            .foregroundColor(isDark ? .gray : .gray)
                        
                        Text(train.status.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(isDark ? .orange : .orange)
                    }
                }
            }
            
            Spacer()
            
            // Minutes Until Arrival
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(train.minutes)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDark ? .white : .black)
                
                Text("min")
                    .font(.system(size: 14))
                    .foregroundColor(isDark ? .gray : .gray)
            }
        }
        .padding(12)
        .background(isDark ? Color(white: 0.2) : Color(white: 0.95))
        .cornerRadius(12)
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

