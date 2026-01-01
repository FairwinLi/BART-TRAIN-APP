import SwiftUI
import WidgetKit

struct MediumWidget: View {
    let station: Station
    let isDark: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
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
            
            // Platforms Grid
            HStack(spacing: 10) {
                ForEach(station.platforms.prefix(2)) { platform in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(platform.name)
                            .font(.system(size: 10))
                            .foregroundColor(isDark ? .gray : .gray)
                            .lineLimit(1)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(platform.trains.prefix(2)) { train in
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color(hex: train.color))
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
                    }
                }
            }
            
            // Warning/Status Bar
            HStack(spacing: 8) {
                Text(station.warning?.hasWarning == true ? "⚠️" : "✓")
                    .font(.system(size: 10))
                
                Text(station.warning?.hasWarning == true
                     ? (station.warning?.title ?? "All lines running normally")
                     : "All lines running normally")
                    .font(.system(size: 10))
                    .foregroundColor(
                        station.warning?.hasWarning == true
                        ? (isDark ? Color.orange.opacity(0.8) : Color.orange.opacity(0.8))
                        : (isDark ? Color.green.opacity(0.8) : Color.green.opacity(0.8))
                    )
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                station.warning?.hasWarning == true
                ? (isDark ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                : (isDark ? Color.green.opacity(0.2) : Color.green.opacity(0.1))
            )
            .cornerRadius(8)
        }
        .padding(16)
        .frame(width: 342, height: 158)
        .background(isDark ? Color(white: 0.15) : .white)
        .cornerRadius(24)
    }
}

