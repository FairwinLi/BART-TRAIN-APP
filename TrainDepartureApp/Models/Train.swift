import Foundation

struct Train: Identifiable, Codable {
    let id: UUID
    let line: String
    let destination: String
    let minutes: Int
    let time: Date
    let status: TrainStatus
    let color: String
    
    enum TrainStatus: String, Codable {
        case onTime = "On time"
        case delayed = "Delayed"
        case cancelled = "Cancelled"
    }
    
    init(id: UUID = UUID(), line: String, destination: String, minutes: Int, time: Date, status: TrainStatus, color: String) {
        self.id = id
        self.line = line
        self.destination = destination
        self.minutes = minutes
        self.time = time
        self.status = status
        self.color = color
    }
}

