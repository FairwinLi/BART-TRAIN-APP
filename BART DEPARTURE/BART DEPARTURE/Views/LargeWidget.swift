import SwiftUI
import WidgetKit

struct LargeWidget: View {
    let station: Station
    let isDark: Bool
    
    private var trainsPerPlatform: Int {
        station.platforms.count >= 3 ? 2 : 3
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            widgetHeader
            platformsSection
            warningCard
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isDark ? Color(white: 0.15) : .white)
        .cornerRadius(16)
    }
    
    // MARK: - Sub-views
    
    private var widgetHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(station.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isDark ? .white : .black)
                    .lineLimit(1)
                
                Text("Nearest station • \(station.system)")
                    .font(.system(size: 9))
                    .foregroundColor(isDark ? .gray : .gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 8))
                    .foregroundColor(isDark ? .gray : .gray)
                
                Text(Date(), style: .time)
                    .font(.system(size: 9))
                    .foregroundColor(isDark ? .gray : .gray)
            }
        }
    }
    
    private var platformsSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(station.platforms.prefix(4)) { platform in
                PlatformWidgetRow(
                    platform: platform,
                    isDark: isDark,
                    trainsToShow: trainsPerPlatform
                )
            }
        }
    }
    
    private var warningCard: some View {
        WarningCardWidget(
            warning: station.warning,
            isDark: isDark
        )
    }
    
}

// MARK: - Warning Card Widget

struct WarningCardWidget: View {
    let warning: Warning?
    let isDark: Bool
    
    private var hasWarning: Bool {
        warning?.hasWarning == true
    }
    
    private var warningTitle: String {
        hasWarning ? (warning?.title ?? "All lines running normally") : "All lines running normally"
    }
    
    private var warningTextColor: Color {
        hasWarning ? Color.orange.opacity(0.8) : Color.green.opacity(0.8)
    }
    
    private var warningBgColor: Color {
        if hasWarning {
            return isDark ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1)
        } else {
            return isDark ? Color.green.opacity(0.2) : Color.green.opacity(0.1)
        }
    }
    
    private var warningBorderColor: Color {
        if hasWarning {
            return isDark ? Color.orange.opacity(0.3) : Color.orange.opacity(0.3)
        } else {
            return isDark ? Color.green.opacity(0.3) : Color.green.opacity(0.3)
        }
    }
    
    var body: some View {
        HStack(spacing: 5) {
            Text(hasWarning ? "⚠️" : "✓")
                .font(.system(size: 9))
            
            VStack(alignment: .leading, spacing: 1) {
                Text(warningTitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(warningTextColor)
                    .lineLimit(1)
                
                if let warning = warning, warning.hasWarning {
                    Text(warning.description)
                        .font(.system(size: 8))
                        .foregroundColor(isDark ? Color.orange.opacity(0.7) : Color.orange.opacity(0.7))
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(warningBgColor)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(warningBorderColor, lineWidth: 1)
        )
        .cornerRadius(5)
    }
}

// MARK: - Platform Widget Row

struct PlatformWidgetRow: View {
    let platform: Platform
    let isDark: Bool
    let trainsToShow: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            platformHeader
            trainsList
        }
    }
    
    private var platformHeader: some View {
        HStack {
            Text(platform.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(isDark ? Color(white: 0.7) : Color(white: 0.3))
                .lineLimit(1)
            
            Spacer()
            
            Text(platform.direction)
                .font(.system(size: 8))
                .foregroundColor(isDark ? .gray : .gray)
        }
        .padding(.bottom, 1)
    }
    
    private var trainsList: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(platform.trains.prefix(trainsToShow)) { train in
                TrainWidgetRow(train: train, isDark: isDark)
            }
        }
    }
}

// MARK: - Train Widget Row

struct TrainWidgetRow: View {
    let train: Train
    let isDark: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            lineBadge
            destinationInfo
            Spacer()
            arrivalTime
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(isDark ? Color(white: 0.2) : Color(white: 0.95))
        .cornerRadius(5)
    }
    
    private var lineBadge: some View {
        Text(train.line)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(.black)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(hexColor(from: train.color))
            .cornerRadius(4)
    }
    
    // Helper function to convert hex string to Color (since ColorExtension might not be in widget target)
    private func hexColor(from hexString: String) -> Color {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    private var destinationInfo: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(train.destination)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isDark ? .white : .black)
                .lineLimit(1)
            
            Text(train.time, style: .time)
                .font(.system(size: 8))
                .foregroundColor(isDark ? .gray : .gray)
        }
    }
    
    private var arrivalTime: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text("\(train.minutes) min")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isDark ? .white : .black)
            
            if train.status != .onTime {
                Text("Delay")
                    .font(.system(size: 7))
                    .foregroundColor(isDark ? .orange : .orange)
            }
        }
    }
}

