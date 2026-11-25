import SwiftUI
import PhotosUI

/// Alta / edición de mascota.
struct PetFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PetFormViewModel
    @State private var isConfirmingDelete = false

    init(viewModel: PetFormViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    photoPicker
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)

                Section("Datos básicos") {
                    TextField("Nombre", text: $viewModel.draft.name)
                        .textInputAutocapitalization(.words)
                    Picker("Especie", selection: $viewModel.draft.species) {
                        ForEach(Species.allCases) { species in
                            Text(species.displayName).tag(species)
                        }
                    }
                    TextField("Raza", text: $viewModel.draft.breed)
                        .textInputAutocapitalization(.words)
                    Picker("Sexo", selection: $viewModel.draft.sex) {
                        ForEach(PetSex.allCases) { sex in
                            Text(sex.displayName).tag(sex)
                        }
                    }
                    DatePicker("Nacimiento", selection: $viewModel.draft.birthDate,
                               in: ...Date.now, displayedComponents: .date)
                        .environment(\.locale, AppFormatters.locale)
                }

                Section("Identificación") {
                    HStack {
                        TextField("Peso", text: $viewModel.weightText)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundStyle(Theme.textSecondary)
                    }
                    TextField("Microchip (opcional)", text: $viewModel.draft.microchip)
                        .keyboardType(.numbersAndPunctuation)
                }

                Section("Color de la credencial") {
                    HStack(spacing: 16) {
                        ForEach(PetCardStyle.allCases) { style in
                            Button {
                                viewModel.draft.cardStyle = style
                            } label: {
                                Circle()
                                    .fill(style.color)
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        if viewModel.draft.cardStyle == style {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if viewModel.isEditing {
                    Section {
                        Button("Eliminar mascota", role: .destructive) {
                            isConfirmingDelete = true
                        }
                    }
                }
            }
            .appFormStyle()
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if viewModel.save() { dismiss() }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave)
                }
            }
            .onChange(of: viewModel.photoItem) {
                Task { await viewModel.loadSelectedPhoto() }
            }
            .confirmationDialog(
                "¿Eliminar a \(viewModel.draft.name)?",
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button("Eliminar", role: .destructive) {
                    dismiss()
                    viewModel.delete()
                }
            } message: {
                Text("También se borrarán sus eventos, registros de salud y gastos.")
            }
        }
        .tint(Theme.primary)
    }

    private var photoPicker: some View {
        VStack(spacing: 10) {
            PhotosPicker(selection: $viewModel.photoItem, matching: .images) {
                PetPhotoView(
                    photoData: viewModel.draft.photoData,
                    species: viewModel.draft.species,
                    style: viewModel.draft.cardStyle
                )
                .frame(width: 112, height: 112)
                .clipShape(Circle())
                .overlay(Circle().stroke(viewModel.draft.cardStyle.color, lineWidth: 3))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Theme.primary))
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
                .overlay {
                    if viewModel.isLoadingPhoto { ProgressView() }
                }
            }
            .buttonStyle(.plain)

            if viewModel.draft.photoData != nil {
                Button("Quitar foto", role: .destructive) { viewModel.removePhoto() }
                    .font(.footnote)
            } else {
                Text("Toca para agregar una foto")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

#Preview {
    PetFormView(viewModel: PetFormViewModel(store: PreviewData.store, pet: nil))
}
