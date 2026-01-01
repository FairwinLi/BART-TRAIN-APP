import SwiftUI

struct PlatformCard: View {
    let platform: Platform
    let isDark: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Platform Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(platform.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isDark ? .white : .black)
                    
                    Text(platform.direction)
                        .font(.system(size: 14))
                        .foregroundColor(isDark ? .gray : .gray)
                }
                
                Spacer()
                
                Text("\(platform.trains.count) trains")
                    .font(.system(size: 12))
                    .foregroundColor(isDark ? .gray : .gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isDark ? Color(white: 0.2) : Color(white: 0.9))
                    .cornerRadius(16)
            }
            
            // Trains List
            VStack(spacing: 8) {
                ForEach(platform.trains) { train in
                    TrainRow(train: train, isDark: isDark)
                }
            }
        }
        .padding(16)
        .background(isDark ? Color(white: 0.15) : .white)
        .cornerRadius(16)
    }
}

