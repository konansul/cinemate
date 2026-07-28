import SwiftUI

struct StarRatingView: View {
    let rating: Int
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? .yellow : .secondary)
                    .onTapGesture {
                        onSelect(star == rating ? 0 : star)
                    }
            }
        }
        .font(.title2)
    }
}
