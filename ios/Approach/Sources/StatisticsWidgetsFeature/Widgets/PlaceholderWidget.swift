import AssetsLibrary
import StringsLibrary
import SwiftUI

public struct PlaceholderWidget: View {
	let size: WidgetSize

	public init(size: WidgetSize) {
		self.size = size
	}

	public var body: some View {
		WidgetContainer(size: size) {
			VStack(alignment: .leading, spacing: .smallSpacing) {
				Text(Strings.Statistics.Placeholder.title)
					.font(.title)
					.foregroundColor(.white)

				Text(Strings.Statistics.Placeholder.message)
					.foregroundColor(.white)
			}
			.padding(.horizontal)
			.background(alignment: .bottomTrailing) {
				Image(uiImage: .iconAnalytics)
					.resizable()
					.scaledToFit()
					.opacity(0.4)
			}
		}
	}
}