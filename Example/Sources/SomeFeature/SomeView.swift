import AppUI
import SwiftUI

public struct SomeView: View {
	@SwiftUI.State
	private var tapsCount: Int = 0

	public init() {}

	public var body: some View {
		Section {
			Button(action: { tapsCount += 1 }) {
				Text(localized: .localizable.common.tap)
					.foregroundStyle(Color.accentColor)
			}
			Button(role: .destructive, action: { tapsCount = 0 }) {
				Text(localized: .localizable.common.reset)
			}
		} header: {
			Label(
				title: { Text(localized: .some.taps.count(tapsCount)) },
				icon: { Image(systemName: "number.square.fill") }
			)
		}
	}
}
