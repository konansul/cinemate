import WidgetKit
import SwiftUI

@main
struct CinemateWidgetBundle: WidgetBundle {
    var body: some Widget {
        CinemateTrendingWidget()
        CinemateForYouWidget()
    }
}
