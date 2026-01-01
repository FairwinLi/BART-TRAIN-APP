import AppIntents
import Foundation

// MARK: - Widget Configuration Intent
// This is the default App Intent file that Xcode generates for Widget Extensions.
// Since we're using StaticConfiguration (automatic location-based station detection),
// this intent is not actively used, but it's here to prevent build errors.

struct BARTDepartureWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "BART Departures"
    static var description = IntentDescription("Shows real-time BART train departures from your nearest station.")
    
    // Default configuration - no user-configurable parameters needed
    // The widget automatically uses location to find the nearest station
}

