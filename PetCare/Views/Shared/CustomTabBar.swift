import SwiftUI

/// Barra inferior flotante con indicador animado.
struct CustomTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = tab == selection

                Button {
                    withAnimation(.snappy(duration: 0.25)) { selection = tab }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 18))
                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(isSelected ? Theme.primary : Theme.textPrimary.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Theme.primarySoft)
                                .matchedGeometryEffect(id: "tab-indicator", in: namespace)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Theme.surface)
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 6)
        )
    }
}
