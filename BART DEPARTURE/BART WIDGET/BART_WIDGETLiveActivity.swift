//
//  BART_WIDGETLiveActivity.swift
//  BART WIDGET
//
//  Created by Fairwin Li on 12/18/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BART_WIDGETAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BART_WIDGETLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BART_WIDGETAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BART_WIDGETAttributes {
    fileprivate static var preview: BART_WIDGETAttributes {
        BART_WIDGETAttributes(name: "World")
    }
}

extension BART_WIDGETAttributes.ContentState {
    fileprivate static var smiley: BART_WIDGETAttributes.ContentState {
        BART_WIDGETAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BART_WIDGETAttributes.ContentState {
         BART_WIDGETAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BART_WIDGETAttributes.preview) {
   BART_WIDGETLiveActivity()
} contentStates: {
    BART_WIDGETAttributes.ContentState.smiley
    BART_WIDGETAttributes.ContentState.starEyes
}
