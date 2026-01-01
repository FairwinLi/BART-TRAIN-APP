import SwiftUI

struct TrainRow: View {
    let train: Train
    let isDark: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Line Badge
            Text(train.line)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(train.color))
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
                        
                        if let delayMinutes = train.delayMinutes {
                            Text("\(delayMinutes) min delay")
                                .font(.system(size: 14))
                                .foregroundColor(isDark ? .orange : .orange)
                        } else {
                            Text(train.status.rawValue)
                                .font(.system(size: 14))
                                .foregroundColor(isDark ? .orange : .orange)
                        }
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


