import SwiftUI
import WidgetKit

struct MediumWidget: View {
    let station: Station
    let isDark: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            widgetHeader
            platformsGrid
            warningStatusBar
        }
        .padding(16)
        .frame(width: 342, height: 158)
        .background(isDark ? Color(white: 0.15) : .white)
        .cornerRadius(24)
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
                    .font(.system(size: 9))
                    .foregroundColor(isDark ? .gray : .gray)
                
                Text(Date(), style: .time)
                    .font(.system(size: 9))
                    .foregroundColor(isDark ? .gray : .gray)
            }
        }
    }
    
    private var platformsGrid: some View {
        HStack(spacing: 10) {
            ForEach(station.platforms.prefix(2)) { platform in
                MediumPlatformColumn(platform: platform, isDark: isDark)
            }
        }
    }
    
    private var warningStatusBar: some View {
        MediumWarningBar(warning: station.warning, isDark: isDark)
    }
}

// MARK: - Medium Platform Column

struct MediumPlatformColumn: View {
    let platform: Platform
    let isDark: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(platform.name)
                .font(.system(size: 10))
                .foregroundColor(isDark ? .gray : .gray)
                .lineLimit(1)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(platform.trains.prefix(2)) { train in
                    MediumTrainRow(train: train, isDark: isDark)
                }
            }
        }
    }
}

// MARK: - Medium Train Row

struct MediumTrainRow: View {
    let train: Train
    let isDark: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(train.color))
                .frame(width: 6, height: 6)
            
            Text(train.destination.components(separatedBy: "/").first ?? train.destination)
                .font(.system(size: 10))
                .foregroundColor(isDark ? Color(white: 0.8) : Color(white: 0.3))
                .lineLimit(1)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                Text("\(train.minutes) min")
                    .font(.system(size: 10))
                    .foregroundColor(isDark ? .white : .black)
                
                if train.status != .onTime {
                    Text("Delay")
                        .font(.system(size: 8))
                        .foregroundColor(isDark ? .orange : .orange)
                }
            }
        }
    }
}

// MARK: - Medium Warning Bar

struct MediumWarningBar: View {
    let warning: Warning?
    let isDark: Bool
    
    private var hasWarning: Bool {
        warning?.hasWarning == true
    }
    
    private var warningText: String {
        hasWarning ? (warning?.title ?? "All lines running normally") : "All lines running normally"
    }
    
    private var warningIcon: String {
        hasWarning ? "⚠️" : "✓"
    }
    
    private var warningTextColor: Color {
        hasWarning
        ? (isDark ? Color.orange.opacity(0.8) : Color.orange.opacity(0.8))
        : (isDark ? Color.green.opacity(0.8) : Color.green.opacity(0.8))
    }
    
    private var warningBgColor: Color {
        hasWarning
        ? (isDark ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
        : (isDark ? Color.green.opacity(0.2) : Color.green.opacity(0.1))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(warningIcon)
                .font(.system(size: 10))
            
            Text(warningText)
                .font(.system(size: 10))
                .foregroundColor(warningTextColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(warningBgColor)
        .cornerRadius(8)
    }
}

