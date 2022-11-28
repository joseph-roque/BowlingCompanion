import SharedModelsLibrary
import StringsLibrary
import SwiftUI
import ThemesLibrary
import ViewsLibrary

struct BallPickerView: View {
	@Binding var ballRolled: Gear?

	var body: some View {
		Button { } label: {
			HStack(alignment: .center, spacing: .standardSpacing) {
				Color.red
					.frame(width: .standardIcon, height: .standardIcon)
					.cornerRadius(.standardIcon)

				VStack(alignment: .leading, spacing: .unitSpacing) {
					Text(Strings.Game.Editor.BallDetails.BallRolled.title)
					Text(ballRolled?.name ?? Strings.Game.Editor.BallDetails.BallRolled.none)
						.font(.caption)
				}

				Image(systemName: "chevron.up.chevron.down")
					.resizable()
					.frame(width: .tinyIcon, height: .tinyIcon)
					.foregroundColor(.appAction)
			}
			.contentShape(Rectangle())
		}
		.buttonStyle(TappableElement())
	}
}

#if DEBUG
struct BallPickerViewPreviews: PreviewProvider {
	static var previews: some View {
		BallPickerView(ballRolled: .constant(nil))
	}
}
#endif
