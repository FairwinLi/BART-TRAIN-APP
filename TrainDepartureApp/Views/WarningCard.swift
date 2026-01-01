import SwiftUI

struct WarningCard: View {
    let warning: Warning
    let isDark: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isDark ? Color.orange.opacity(0.3) : Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isDark ? .orange : .orange)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(warning.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDark ? Color.orange.opacity(0.9) : Color.orange.opacity(0.9))
                
                Text(warning.description)
                    .font(.system(size: 14))
                    .foregroundColor(isDark ? Color.orange.opacity(0.8) : Color.orange.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            isDark
                ? Color.orange.opacity(0.15)
                : Color.orange.opacity(0.1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isDark
                        ? Color.orange.opacity(0.3)
                        : Color.orange.opacity(0.3),
                    lineWidth: 1
                )
        )
        .cornerRadius(16)
    }
}

