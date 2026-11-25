import SwiftUI
import Charts

/// Finanzas: gastos por mascota, resumen del mes y desglose por categoría.
struct FinanceView: View {
    @Bindable var viewModel: FinanceViewModel
    @State private var isAddingExpense = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "Finanzas", subtitle: "Controla y planea los gastos de su cuidado") {
                    CircleIconButton(systemImage: "plus", label: "Agregar gasto") {
                        isAddingExpense = true
                    }
                    .disabled(viewModel.pets.isEmpty)
                }

                PetFilterBar(
                    pets: viewModel.pets,
                    selectedPetID: viewModel.selectedPetID,
                    onSelect: { viewModel.selectPet($0) }
                )

                summaryCard

                if !viewModel.categoryTotals.isEmpty {
                    categoryCard
                }

                if !viewModel.petTotals.isEmpty {
                    petTotalsCard
                }

                if viewModel.hasExpenses {
                    ForEach(viewModel.monthSections) { section in
                        monthSection(section)
                    }
                } else {
                    EmptyStateCard(
                        systemImage: "creditcard",
                        title: "Sin gastos registrados",
                        message: "Registra consultas, alimento, accesorios y más para saber cuánto inviertes en tus mascotas.",
                        actionTitle: viewModel.pets.isEmpty ? nil : "Registrar gasto",
                        action: { isAddingExpense = true }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(AppBackground())
        .sheet(isPresented: $isAddingExpense) {
            ExpenseFormView(pets: viewModel.pets, draft: viewModel.makeDraft()) { draft in
                viewModel.addExpense(draft)
            }
        }
    }

    // MARK: - Resumen

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.summaryTitle)
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(Theme.primary)

                    Text(AppFormatters.currency(viewModel.currentMonthTotal))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                }
                Spacer(minLength: 8)
                GradientIconTile(systemImage: "creditcard.fill", tint: Theme.primary, size: 50, cornerRadius: 16)
            }

            if let change = viewModel.monthChange {
                let tint = change.isIncrease ? Theme.red : Theme.green
                Text(change.text)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(tint.opacity(0.12)))
            }

            Divider()
                .overlay(Theme.stroke)
                .padding(.vertical, 2)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("En el año")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(AppFormatters.currency(viewModel.yearTotal))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                Text(viewModel.summarySubtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.primarySoft))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .bottomTrailing) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 70))
                .foregroundStyle(Theme.primary.opacity(0.05))
                .rotationEffect(.degrees(-18))
                .offset(x: -70, y: -6)
                .accessibilityHidden(true)
        }
        .cardBackground(cornerRadius: 24)
    }

    // MARK: - Por categoría

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gastos por categoría")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            HStack(alignment: .center, spacing: 18) {
                ZStack {
                    Chart(viewModel.categoryTotals) { item in
                        SectorMark(
                            angle: .value("Monto", item.total),
                            innerRadius: .ratio(0.66),
                            angularInset: 2
                        )
                        .cornerRadius(5)
                        .foregroundStyle(item.category.tint)
                    }

                    VStack(spacing: 0) {
                        Text(AppFormatters.currency(viewModel.currentMonthTotal))
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text("Gastado")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(width: 76)
                }
                .frame(width: 130, height: 130)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.categoryTotals.prefix(5)) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.category.tint)
                                .frame(width: 8, height: 8)
                            Text(item.category.displayName)
                                .font(.footnote)
                                .foregroundStyle(Theme.textPrimary)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text("\(Int((item.share * 100).rounded()))%")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .cardBackground(cornerRadius: 24)
    }

    // MARK: - Por mascota

    private var petTotalsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Por mascota este mes")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            ForEach(viewModel.petTotals) { item in
                HStack(spacing: 12) {
                    PetPhotoView(pet: item.pet)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(item.pet.cardStyle.color.opacity(0.4), lineWidth: 2))
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.pet.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Text(AppFormatters.currency(item.total))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        GradientProgressBar(value: item.share, gradient: item.pet.cardStyle.gradient)
                    }
                }
            }
        }
        .padding(18)
        .cardBackground(cornerRadius: 24)
    }

    // MARK: - Movimientos

    private func monthSection(_ section: ExpenseMonthSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(section.title.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text(AppFormatters.currency(section.total))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primary)
            }

            VStack(spacing: 0) {
                ForEach(Array(section.expenses.enumerated()), id: \.element.id) { index, expense in
                    if index > 0 { Divider().overlay(Theme.stroke).padding(.leading, 72) }
                    ExpenseRow(
                        title: viewModel.title(for: expense),
                        subtitle: viewModel.subtitle(for: expense),
                        amount: expense.amount,
                        category: expense.category
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation { viewModel.deleteExpense(expense) }
                        } label: {
                            Label("Eliminar gasto", systemImage: "trash")
                        }
                    }
                }
            }
            .cardBackground(cornerRadius: 22)
        }
    }
}

/// Barra de progreso redondeada con degradado.
struct GradientProgressBar: View {
    let value: Double
    var gradient: LinearGradient = Theme.primaryGradient
    var height: CGFloat = 8

    var body: some View {
        Capsule()
            .fill(Theme.chip)
            .frame(height: height)
            .overlay(alignment: .leading) {
                GeometryReader { geometry in
                    Capsule()
                        .fill(gradient)
                        .frame(width: max(height, geometry.size.width * min(max(value, 0), 1)))
                }
            }
            .accessibilityElement()
            .accessibilityValue(Text("\(Int((min(max(value, 0), 1) * 100).rounded()))%"))
    }
}

struct ExpenseRow: View {
    let title: String
    let subtitle: String
    let amount: Double
    let category: ExpenseCategory

    var body: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: category.systemImage, tint: category.tint)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 8)
            Text("-\(AppFormatters.currency(amount))")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(14)
        .contentShape(Rectangle())
    }
}

// MARK: - Formulario de gasto

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    let pets: [PetRecord]
    let onSave: (ExpenseDraft) -> Void
    @State private var draft: ExpenseDraft

    init(pets: [PetRecord], draft: ExpenseDraft, onSave: @escaping (ExpenseDraft) -> Void) {
        self.pets = pets
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Monto") {
                    HStack(spacing: 6) {
                        Text("$")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Theme.textSecondary)
                        TextField("0.00", text: $draft.amountText)
                            .font(.title2.weight(.bold))
                            .keyboardType(.decimalPad)
                        Text("MXN")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Section("Detalles") {
                    Picker("Mascota", selection: $draft.petID) {
                        ForEach(pets) { pet in
                            Text(pet.name).tag(Optional(pet.id))
                        }
                    }
                    Picker("Categoría", selection: $draft.category) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.systemImage).tag(category)
                        }
                    }
                    DatePicker("Fecha", selection: $draft.date, displayedComponents: .date)
                        .environment(\.locale, AppFormatters.locale)
                    TextField("Nota (ej. Croquetas 15 kg)", text: $draft.note)
                }
            }
            .appFormStyle()
            .navigationTitle("Nuevo gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!draft.isValid)
                }
            }
        }
        .tint(Theme.primary)
    }
}

#Preview {
    FinanceView(viewModel: FinanceViewModel(store: PreviewData.store))
}
