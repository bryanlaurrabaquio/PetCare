import SwiftUI

/// Inicio: solo los eventos próximos, filtrables por mascota.
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    let onSignOut: () -> Void

    @State private var isAddingEvent = false
    @State private var editingEvent: PetEvent?
    @State private var detailItem: UpcomingItem?
    @State private var pendingEditEvent: PetEvent?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HomeHeader(
                    greeting: viewModel.greeting,
                    userName: viewModel.userName,
                    email: viewModel.userEmail,
                    onSignOut: onSignOut
                )

                PetFilterBar(
                    pets: viewModel.pets,
                    selectedPetID: viewModel.selectedPet?.id,
                    onSelect: { viewModel.selectPet($0) }
                )

                if let featured = viewModel.featuredItem {
                    NextEventCard(
                        item: featured,
                        pet: viewModel.pet(for: featured),
                        onDetail: { detailItem = featured },
                        onReschedule: editAction(for: featured)
                    )

                    SectionHeader(title: "Próximos eventos", actionTitle: "Agregar") {
                        isAddingEvent = true
                    }

                    if viewModel.sections.isEmpty {
                        Text("No hay más eventos después de este.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    ForEach(viewModel.sections) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title.uppercased())
                                .font(.caption.weight(.bold))
                                .tracking(0.8)
                                .foregroundStyle(Theme.textSecondary)

                            ForEach(section.items) { item in
                                Button {
                                    detailItem = item
                                } label: {
                                    UpcomingEventRow(item: item, showsPetName: viewModel.showsPetNames)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .contextMenu { contextMenu(for: item) }
                            }
                        }
                    }
                } else {
                    EmptyStateCard(
                        systemImage: "calendar.badge.plus",
                        title: viewModel.emptyTitle,
                        message: "Agenda consultas, baños, paseos o recordatorios y aparecerán aquí.",
                        actionTitle: "Agendar evento",
                        action: { isAddingEvent = true }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(AppBackground())
        .sheet(isPresented: $isAddingEvent) {
            EventFormView(
                title: "Nuevo evento",
                pets: viewModel.pets,
                draft: viewModel.makeNewEventDraft()
            ) { draft in
                viewModel.saveEvent(draft, editing: nil)
            }
        }
        .sheet(item: $editingEvent) { event in
            EventFormView(
                title: "Editar evento",
                pets: viewModel.pets,
                draft: EventDraft(event: event)
            ) { draft in
                viewModel.saveEvent(draft, editing: event)
            }
        }
        .sheet(item: $detailItem, onDismiss: { openPendingEdit() }) { item in
            EventDetailSheet(
                item: item,
                onEdit: pendingEditAction(for: item),
                onDelete: deleteAction(for: item)
            )
        }
    }

    @ViewBuilder
    private func contextMenu(for item: UpcomingItem) -> some View {
        if let event = item.event {
            Button {
                editingEvent = event
            } label: {
                Label("Editar", systemImage: "pencil")
            }
            Button(role: .destructive) {
                viewModel.deleteEvent(event)
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }

    private func editAction(for item: UpcomingItem) -> (() -> Void)? {
        guard let event = item.event else { return nil }
        return { editingEvent = event }
    }

    private func pendingEditAction(for item: UpcomingItem) -> (() -> Void)? {
        guard let event = item.event else { return nil }
        return { pendingEditEvent = event }
    }

    private func deleteAction(for item: UpcomingItem) -> (() -> Void)? {
        guard let event = item.event else { return nil }
        return { viewModel.deleteEvent(event) }
    }

    /// Abre la edición después de cerrar el detalle (dos hojas no pueden abrirse a la vez).
    private func openPendingEdit() {
        guard let pendingEditEvent else { return }
        editingEvent = pendingEditEvent
        self.pendingEditEvent = nil
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(store: PreviewData.store), onSignOut: {})
}
