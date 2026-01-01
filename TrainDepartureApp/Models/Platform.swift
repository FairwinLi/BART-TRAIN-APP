import Foundation

struct Platform: Identifiable, Codable {
    let id: UUID
    let name: String
    let direction: String
    var trains: [Train]
    
    init(id: UUID = UUID(), name: String, direction: String, trains: [Train]) {
        self.id = id
        self.name = name
        self.direction = direction
        self.trains = trains
    }
}

