import SwiftUI

struct ReviewCard: View {
    let review: Review
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.author)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                if let rating = review.ratingText {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption2)
                        Text(rating)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let date = review.dateText {
                Text(date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(review.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(expanded ? nil : 6)

            if review.content.count > 280 {
                Button(expanded ? "Show less" : "Read more") {
                    withAnimation(.easeInOut) { expanded.toggle() }
                }
                .font(.caption.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
