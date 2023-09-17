import AssetsLibrary
import SwiftUI
import ViewsLibrary

public struct BasicTipView: View {
	let tip: Tip
	let onDismiss: () -> Void

	public init(tip: Tip, onDismiss: @escaping () -> Void) {
		self.tip = tip
		self.onDismiss = onDismiss
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(alignment: .center, spacing: 0) {
				Text(tip.title)
					.font(.headline)
					.frame(maxWidth: .infinity, alignment: .leading)
				Button(action: onDismiss) {
					Image(systemSymbol: .xmark)
						.resizable()
						.scaledToFit()
						.frame(width: .smallIcon, height: .smallSpacing)
						.padding(.vertical)
						.padding(.leading)
				}
				.buttonStyle(TappableElement())
				// TODO: URGENT Remove this so that tips are dismissable again
				.hidden()
			}
			.frame(maxWidth: .infinity)

			if let message = tip.message {
				Text(message)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
	}
}

#if DEBUG
struct BasicTipViewPreview: PreviewProvider {
	static var previews: some View {
		List {
			Section {
				BasicTipView(tip: .init(title: "Title", message: "Message")) { }
			}
		}
	}
}
#endif
