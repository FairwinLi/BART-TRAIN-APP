import SwiftUI
import WidgetKit

struct LargeWidget: View {
    let station: Station
    let isDark: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
                        .font(.system(size: 8))
                        .foregroundColor(isDark ? .gray : .gray)
                    
                    Text(Date(), style: .time)
                        .font(.system(size: 9))
                        .foregroundColor(isDark ? .gray : .gray)
                }
            }
            
            // Platforms
            VStack(alignment: .leading, spacing: 6) {
                ForEach(station.platforms.prefix(4)) { platform in
                    VStack(alignment: .leading, spacing: 2) {
                        // Platform Header
                        HStack {
                            Text(platform.name)
                                .font(.system(size: 9))
                                .foregroundColor(isDark ? Color(white: 0.7) : Color(white: 0.3))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(platform.direction)
                                .font(.system(size: 8))
                                .foregroundColor(isDark ? .gray : .gray)
                        }
                        
                        // Trains List
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(platform.trains.prefix(station.platforms.count >= 3 ? 2 : 3)) { train in
                                HStack(spacing: 4) {
                                    // Line Badge
                                    Text(train.line)
                                        .font(.system(size: 8))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 3)
                                        .padding(.vertical, 1)
                                        .background(Color(hex: train.color))
                                        .cornerRadius(4)
                                    
                                    // Destination
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(train.destination)
                                            .font(.system(size: 10))
                                            .foregroundColor(isDark ? .white : .black)
                                            .lineLimit(1)
                                        
                                        Text(train.time, style: .time)
                                            .font(.system(size: 8))
                                            .foregroundColor(isDark ? .gray : .gray)
                                    }
                                    
                                    Spacer()
                                    
                                    // Arrival Time
                                    VStack(alignment: .trailing, spacing: 0) {
                                        Text("\(train.minutes) min")
                                            .font(.system(size: 10))
                                            .foregroundColor(isDark ? .white : .black)
                                        
                                        if train.status != .onTime {
                                            Text("Delay")
                                                .font(.system(size: 7))
                                                .foregroundColor(isDark ? .orange : .orange)
                                        }
                                    }
                                }
                                .padding(.horizontal, 3)
                                .padding(.vertical, 2)
                                .background(isDark ? Color(white: 0.2) : Color(white: 0.95))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
            // Warning/Status Card
            HStack(spacing: 4) {
                Text(station.warning?.hasWarning == true ? "⚠️" : "✓")
                    .font(.system(size: 10))
                
                VStack(alignment: .leading, spacing: 0) {
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
                    
                    if let warning = station.warning, warning.hasWarning {
                        Text(warning.description)
                            .font(.system(size: 8))
                            .foregroundColor(isDark ? Color.orange.opacity(0.7) : Color.orange.opacity(0.7))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                station.warning?.hasWarning == true
                ? (isDark ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                : (isDark ? Color.green.opacity(0.2) : Color.green.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        station.warning?.hasWarning == true
                        ? (isDark ? Color.orange.opacity(0.3) : Color.orange.opacity(0.3))
                        : (isDark ? Color.green.opacity(0.3) : Color.green.opacity(0.3)),
                        lineWidth: 1
                    )
            )
            .cornerRadius(8)
        }
        .padding(8)
        .frame(width: 342, height: 354)
        .background(isDark ? Color(white: 0.15) : .white)
        .cornerRadius(24)
    }
}

