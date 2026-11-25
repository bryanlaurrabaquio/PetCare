import SwiftUI

// Seguros para mascotas: tarjeta en Servicios, aseguradoras, planes,
// contratación y detalle de la póliza.

// MARK: - Tarjeta en Servicios

struct InsuranceSummaryCard: View {
    let summary: String
    let activeCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white.opacity(0.18))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Seguro para tu mascota")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                    Text(summary)
                        .font(.footnote)
                        .opacity(0.85)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(.white)

                Spacer(minLength: 4)

                Text(activeCount > 0 ? "Mis pólizas" : "Cotizar")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.primary)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.white))
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Theme.heroGradient)
                    .overlay(alignment: .bottomTrailing) {
                        PawWatermark(size: 80, opacity: 0.08)
                            .offset(x: 10, y: 18)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .softShadow(Theme.dark, opacity: 0.3, radius: 14, y: 8)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityHint("Abre seguros para mascotas")
    }
}

// MARK: - Inicio de seguros

struct InsuranceHubView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: InsuranceViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    if !viewModel.policies.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Mis pólizas")
                            ForEach(viewModel.policies) { policy in
                                NavigationLink {
                                    PolicyDetailView(viewModel: viewModel, policy: policy)
                                } label: {
                                    PolicyCard(policy: policy)
                                }
                                .buttonStyle(PressableButtonStyle())
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Aseguradoras")
                        ForEach(viewModel.companies) { company in
                            NavigationLink {
                                InsurerDetailView(viewModel: viewModel, company: company)
                            } label: {
                                InsurerCard(company: company)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }

                    DemoNote(text: "Aseguradoras, planes y precios de ejemplo para demostración.")
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(AppBackground())
            .navigationTitle("Seguros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
        .tint(Theme.primary)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Protege a tus mascotas")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text(viewModel.summaryText)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.trailing, 70)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .topTrailing) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 58))
                .foregroundStyle(
                    LinearGradient(colors: [Theme.primaryLight.opacity(0.5), Theme.primary.opacity(0.25)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .rotationEffect(.degrees(8))
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Tarjetas de lista

struct InsurerLogo: View {
    let company: InsuranceCompany
    var size: CGFloat = 52

    var body: some View {
        Image(systemName: company.symbol)
            .font(.system(size: size * 0.46, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                    .fill(company.style.gradient)
            )
            .softShadow(company.style.color, opacity: 0.3, radius: 8, y: 4)
            .accessibilityHidden(true)
    }
}

struct InsurerCard: View {
    let company: InsuranceCompany

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            InsurerLogo(company: company, size: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(company.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(company.tagline)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Theme.yellow)
                    Text(String(format: "%.1f", company.rating))
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.textPrimary)
                    Text("(\(company.reviewCount.formatted()) opiniones) · \(company.plans.count) planes")
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
                .font(.caption)
                Text("Desde \(AppFormatters.wholeCurrency(company.lowestMonthlyPremium)) al mes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Theme.primarySoft))
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.textSecondary.opacity(0.7))
                .padding(.top, 4)
        }
        .padding(14)
        .cardBackground(cornerRadius: 22)
    }
}

struct PolicyCard: View {
    let policy: InsurancePolicy

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                if let pet = policy.pet {
                    PetPhotoView(pet: pet)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(pet.cardStyle.gradient, lineWidth: 2))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(policy.pet?.name ?? "Mascota")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(policy.displayTitle)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                PolicyStatusChip(status: policy.status)
            }

            if policy.isInForce {
                GradientProgressBar(
                    value: policy.elapsedFraction,
                    gradient: policy.company?.style.gradient ?? Theme.primaryGradient,
                    height: 6
                )
            }

            HStack {
                Label(policy.remainingText, systemImage: "calendar")
                Spacer()
                Text(policy.premiumText)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.textPrimary)
            }
            .font(.caption)
            .foregroundStyle(Theme.textSecondary)
        }
        .padding(16)
        .cardBackground(cornerRadius: 22)
    }
}

struct PolicyStatusChip: View {
    let status: PolicyStatus
    var onColor = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.systemImage)
                .font(.caption2.weight(.bold))
            Text(status.text)
                .lineLimit(1)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(status.tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(onColor ? Color.white : status.tint.opacity(0.13)))
    }
}

// MARK: - Aseguradora y planes

struct InsurerDetailView: View {
    let viewModel: InsuranceViewModel
    let company: InsuranceCompany
    @State private var contractingPlan: InsurancePlan? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                eligibilityCard

                SectionHeader(title: "Planes")
                ForEach(company.plans) { plan in
                    PlanCard(
                        plan: plan,
                        company: company,
                        canContract: !viewModel.eligiblePets(for: company).isEmpty
                    ) {
                        contractingPlan = plan
                    }
                }

                DemoNote(text: "Precios de ejemplo. Pagando anual tienes 10 % de descuento.")
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .background(AppBackground())
        .navigationTitle(company.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $contractingPlan) { plan in
            ContractPolicySheet(viewModel: viewModel, company: company, plan: plan)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: company.symbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(company.style.gradient)
                    .frame(width: 60, height: 60)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white))
                VStack(alignment: .leading, spacing: 3) {
                    Text(company.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(company.tagline)
                        .font(.subheadline)
                        .opacity(0.9)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                Text(String(format: "%.1f", company.rating))
                    .fontWeight(.bold)
                Text("· \(company.reviewCount.formatted()) opiniones")
                    .opacity(0.85)
            }
            .font(.footnote)

            FlowChips(items: company.highlights)
        }
        .foregroundStyle(.white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(company.style.gradient)
                .overlay(alignment: .bottomTrailing) {
                    PawWatermark(size: 110, opacity: 0.10)
                        .offset(x: 20, y: 26)
                }
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .softShadow(company.style.color, opacity: 0.3, radius: 14, y: 8)
    }

    private var eligibilityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Requisitos")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            LabeledFact(systemImage: "pawprint.fill", title: "Especies",
                        value: company.acceptedSpecies.map(\.displayName).joined(separator: ", "))
            LabeledFact(systemImage: "birthday.cake.fill", title: "Edad máxima al contratar",
                        value: "\(company.maxEntryAge) años")

            if !viewModel.pets.isEmpty {
                Divider().overlay(Theme.stroke)
                ForEach(viewModel.pets) { pet in
                    let reason = viewModel.ineligibilityReason(for: pet, company: company)
                    HStack(spacing: 10) {
                        PetPhotoView(pet: pet)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 1) {
                            Text(pet.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text(reason ?? "Puede contratar")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: reason == nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(reason == nil ? Theme.green : Theme.gray)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .padding(16)
        .cardBackground(cornerRadius: 22)
    }
}

struct PlanCard: View {
    let plan: InsurancePlan
    let company: InsuranceCompany
    let canContract: Bool
    let onContract: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if plan.isPopular {
                        Label("Más popular", systemImage: "star.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(company.style.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(company.style.color.opacity(0.12)))
                    }
                    Text(plan.name)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Suma asegurada \(AppFormatters.wholeCurrency(plan.sumInsured))")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(AppFormatters.wholeCurrency(plan.monthlyPremium))
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(company.style.color)
                    Text("al mes")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            HStack(spacing: 8) {
                PlanFact(title: "Deducible", value: AppFormatters.wholeCurrency(plan.deductible))
                PlanFact(title: "Coaseguro", value: plan.coinsuranceText)
                PlanFact(title: "Espera", value: plan.waitingDays == 0 ? "Sin espera" : "\(plan.waitingDays) días")
            }

            CoverageList(plan: plan, tint: company.style.color)

            Button("Contratar plan \(plan.name)", action: onContract)
                .buttonStyle(FilledButtonStyle(gradient: company.style.gradient, glow: company.style.color))
                .disabled(!canContract)
        }
        .padding(18)
        .cardBackground(cornerRadius: 24)
        .overlay {
            if plan.isPopular {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(company.style.color.opacity(0.45), lineWidth: 1.5)
            }
        }
    }
}

/// Lista de coberturas: primero las incluidas, luego las no incluidas.
struct CoverageList: View {
    let plan: InsurancePlan
    var tint: Color = Theme.primary

    var body: some View {
        VStack(spacing: 10) {
            ForEach(plan.coverages, id: \.kind) { item in
                CoverageRow(kind: item.kind, item: item, tint: tint)
            }
            ForEach(CoverageKind.allCases.filter { plan.coverage(for: $0) == nil }) { kind in
                CoverageRow(kind: kind, item: nil, tint: tint)
            }
        }
    }
}

struct CoverageRow: View {
    let kind: CoverageKind
    let item: CoverageItem?
    var tint: Color = Theme.primary

    private var isIncluded: Bool { item != nil }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isIncluded ? "checkmark" : "xmark")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(isIncluded ? Color.white : Theme.gray)
                .frame(width: 20, height: 20)
                .background(Circle().fill(isIncluded ? tint : Theme.chip))
            Image(systemName: kind.systemImage)
                .font(.footnote)
                .foregroundStyle(isIncluded ? tint : Theme.gray)
                .frame(width: 20)
            Text(kind.displayName)
                .font(.subheadline)
                .foregroundStyle(isIncluded ? Theme.textPrimary : Theme.textSecondary)
            Spacer(minLength: 8)
            Text(detail)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isIncluded ? Theme.textSecondary : Theme.gray)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }

    private var detail: String {
        guard let item else { return "No incluida" }
        if let limit = item.limit {
            let amount = "Hasta \(AppFormatters.wholeCurrency(limit))"
            return item.note.isEmpty ? amount : "\(amount) · \(item.note)"
        }
        return item.note.isEmpty ? "Incluida" : item.note
    }
}

struct PlanFact: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(.footnote.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.field))
    }
}

/// Ícono + título + valor en una fila.
struct LabeledFact: View {
    let systemImage: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.primary)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Theme.primarySoft))
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
            Spacer(minLength: 8)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Etiquetas blancas translúcidas que bajan de renglón si no caben.
struct FlowChips: View {
    let items: [String]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) { chips }
            VStack(alignment: .leading, spacing: 6) { chips }
        }
    }

    private var chips: some View {
        ForEach(items, id: \.self) { item in
            Text(item)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(.white.opacity(0.2)))
        }
    }
}

struct DemoNote: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "info.circle")
            .font(.caption)
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Contratación

struct ContractPolicySheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: InsuranceViewModel
    let company: InsuranceCompany
    let plan: InsurancePlan
    @State private var draft: PolicyDraft
    @State private var contracted: InsurancePolicy? = nil

    init(viewModel: InsuranceViewModel, company: InsuranceCompany, plan: InsurancePlan) {
        self.viewModel = viewModel
        self.company = company
        self.plan = plan
        _draft = State(initialValue: viewModel.makeDraft(company: company, plan: plan))
    }

    private var eligiblePets: [PetRecord] { viewModel.eligiblePets(for: company) }
    private var selectedPet: PetRecord? { eligiblePets.first { $0.id == draft.petID } }
    private var excludedPets: [PetRecord] { viewModel.pets.filter { company.ineligibilityReason(for: $0) != nil } }

    var body: some View {
        NavigationStack {
            Group {
                if let contracted {
                    ContractSuccessView(policy: contracted) { dismiss() }
                } else {
                    form
                }
            }
            .navigationTitle(contracted == nil ? "Contratar seguro" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if contracted == nil {
                        Button("Cancelar") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if contracted == nil {
                        Button("Contratar") {
                            withAnimation(.snappy) { contracted = viewModel.contract(draft) }
                        }
                        .fontWeight(.semibold)
                        .disabled(!draft.isValid)
                    }
                }
            }
        }
        .tint(Theme.primary)
    }

    private var form: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    InsurerLogo(company: company, size: 48)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(company.name)
                            .font(.headline)
                        Text("Plan \(plan.name) · Suma asegurada \(AppFormatters.wholeCurrency(plan.sumInsured))")
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                if eligiblePets.isEmpty {
                    Text("Ninguna de tus mascotas cumple los requisitos de \(company.name).")
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Picker("Mascota", selection: $draft.petID) {
                        ForEach(eligiblePets) { pet in
                            Text(pet.name).tag(Optional(pet.id))
                        }
                    }
                    if let pet = selectedPet, let current = pet.activePolicy {
                        Label("\(pet.name) ya tiene una póliza vigente (\(current.displayTitle)).",
                              systemImage: "info.circle")
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            } header: {
                Text("Mascota asegurada")
            } footer: {
                if !excludedPets.isEmpty {
                    Text("No pueden contratar: " + excludedPets.map(\.name).joined(separator: ", ") + ".")
                }
            }

            Section("Vigencia y pago") {
                DatePicker("Inicio", selection: $draft.startDate,
                           in: Calendar.current.startOfDay(for: .now)..., displayedComponents: .date)
                    .environment(\.locale, AppFormatters.locale)
                LabeledContent("Fin", value: AppFormatters.shortDate(draft.endDate))
                Picker("Forma de pago", selection: $draft.paymentFrequency) {
                    ForEach(PaymentFrequency.allCases) { frequency in
                        Text(frequency.displayName).tag(frequency)
                    }
                }
                .pickerStyle(.segmented)
                LabeledContent(
                    "Pago",
                    value: AppFormatters.currency(plan.premium(for: draft.paymentFrequency)) + draft.paymentFrequency.shortSuffix
                )
                if draft.paymentFrequency == .annual {
                    Text("Ahorras \(AppFormatters.currency(plan.monthlyPremium * 12 - plan.annualPremium)) al año.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.green)
                }
            }

            Section("Resumen de cobertura") {
                LabeledContent("Suma asegurada", value: AppFormatters.wholeCurrency(plan.sumInsured))
                LabeledContent("Deducible", value: AppFormatters.wholeCurrency(plan.deductible))
                LabeledContent("Coaseguro", value: plan.coinsuranceText)
                LabeledContent("Periodo de espera", value: plan.waitingDays == 0 ? "Sin espera" : "\(plan.waitingDays) días")
                LabeledContent("Coberturas", value: "\(plan.coverages.count) de \(CoverageKind.allCases.count)")
            }

            Section {
                Toggle("Registrar el pago en Finanzas", isOn: $draft.registersExpense)
                Toggle("Acepto los términos y condiciones", isOn: $draft.acceptsTerms)
            } footer: {
                Text("Contratación de demostración: no se hace ningún cobro real.")
            }
        }
        .appFormStyle()
    }
}

private struct ContractSuccessView: View {
    let policy: InsurancePolicy
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 0)

            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 116, height: 116)
                .background(Circle().fill(policy.company?.style.gradient ?? Theme.primaryGradient))
                .overlay(Circle().stroke(.white, lineWidth: 5))
                .softShadow(policy.company?.style.color ?? Theme.primary, opacity: 0.4, radius: 18, y: 10)

            VStack(spacing: 6) {
                Text("¡Póliza contratada!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text("Puedes consultarla cuando quieras en Servicios → Seguro para tu mascota.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                LabeledFact(systemImage: "number", title: "Póliza", value: policy.policyNumber)
                LabeledFact(systemImage: "pawprint.fill", title: "Asegurado", value: policy.pet?.name ?? "—")
                LabeledFact(systemImage: "checkmark.shield.fill", title: "Plan", value: policy.displayTitle)
                LabeledFact(systemImage: "calendar", title: "Vigencia", value: policy.validityText)
                LabeledFact(systemImage: "creditcard.fill", title: "Pago", value: policy.premiumText)
            }
            .padding(16)
            .cardBackground(cornerRadius: 22)

            Spacer(minLength: 0)

            Button("Listo", action: onDone)
                .buttonStyle(.primaryFilled)
        }
        .padding(24)
        .background(AppBackground())
    }
}

// MARK: - Detalle de la póliza

struct PolicyDetailView: View {
    let viewModel: InsuranceViewModel
    let policy: InsurancePolicy
    @State private var isConfirmingCancel = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                policyCard
                validityCard

                if let plan = policy.plan {
                    coverageSummary(plan)

                    VStack(alignment: .leading, spacing: 14) {
                        cardTitle("Coberturas", systemImage: "list.bullet.clipboard.fill")
                        CoverageList(plan: plan, tint: policy.company?.style.color ?? Theme.primary)
                    }
                    .padding(16)
                    .cardBackground(cornerRadius: 22)
                }

                paymentCard
                howToUseCard
                actions
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .background(AppBackground())
        .navigationTitle("Mi póliza")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "¿Cancelar la póliza \(policy.policyNumber)?",
            isPresented: $isConfirmingCancel,
            titleVisibility: .visible
        ) {
            Button("Cancelar póliza", role: .destructive) {
                withAnimation { viewModel.cancel(policy) }
            }
            Button("Conservar", role: .cancel) {}
        } message: {
            Text("La cobertura termina hoy y la póliza queda en tu historial.")
        }
    }

    // MARK: Tarjeta principal

    private var policyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PÓLIZA DE SEGURO")
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .opacity(0.85)
                    Text(policy.company?.name ?? "Aseguradora")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Plan \(policy.plan?.name ?? "—")")
                        .font(.subheadline)
                        .opacity(0.9)
                }
                Spacer()
                if let company = policy.company {
                    Image(systemName: company.symbol)
                        .font(.system(size: 26, weight: .semibold))
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(.white.opacity(0.2)))
                }
            }

            HStack(spacing: 12) {
                if let pet = policy.pet {
                    PetPhotoView(pet: pet)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("ASEGURADO")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.8)
                        .opacity(0.75)
                    Text(policy.pet?.name ?? "—")
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("NÚMERO")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.8)
                        .opacity(0.75)
                    Text(policy.policyNumber)
                        .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                        .textSelection(.enabled)
                }
            }

            PolicyStatusChip(status: policy.status, onColor: true)
        }
        .foregroundStyle(.white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(policy.company?.style.gradient ?? Theme.primaryGradient)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 180, height: 180)
                        .offset(x: 70, y: -90)
                }
                .overlay(alignment: .bottomTrailing) {
                    PawWatermark(size: 110, opacity: 0.10)
                        .offset(x: 20, y: 26)
                }
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .softShadow(policy.company?.style.color ?? Theme.primary, opacity: 0.3, radius: 14, y: 8)
    }

    // MARK: Vigencia

    private var validityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardTitle("Vigencia", systemImage: "calendar")
            HStack(alignment: .top) {
                dateBlock(title: "Inicio", date: policy.startDate, alignment: .leading)
                Spacer()
                dateBlock(title: "Fin", date: policy.endDate, alignment: .trailing)
            }
            GradientProgressBar(
                value: policy.elapsedFraction,
                gradient: policy.company?.style.gradient ?? Theme.primaryGradient
            )
            Text(policy.remainingText)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(policy.status.tint)
        }
        .padding(16)
        .cardBackground(cornerRadius: 22)
    }

    private func dateBlock(title: String, date: Date, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            Text(AppFormatters.shortDate(date))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    // MARK: Cobertura

    private func coverageSummary(_ plan: InsurancePlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            cardTitle("Resumen de cobertura", systemImage: "shield.lefthalf.filled")
            HStack(spacing: 8) {
                PlanFact(title: "Suma asegurada", value: AppFormatters.wholeCurrency(plan.sumInsured))
                PlanFact(title: "Deducible", value: AppFormatters.wholeCurrency(plan.deductible))
            }
            HStack(spacing: 8) {
                PlanFact(title: "Coaseguro", value: plan.coinsuranceText)
                PlanFact(title: "Coberturas", value: "\(plan.coverages.count) de \(CoverageKind.allCases.count)")
            }
            LabeledFact(systemImage: "hourglass", title: "Periodo de espera", value: policy.waitingPeriodText)
        }
        .padding(16)
        .cardBackground(cornerRadius: 22)
    }

    // MARK: Pago

    private var paymentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardTitle("Pago", systemImage: "creditcard.fill")
            LabeledFact(systemImage: "arrow.triangle.2.circlepath", title: "Forma de pago",
                        value: policy.paymentFrequency.displayName)
            LabeledFact(systemImage: "dollarsign", title: "Monto", value: policy.premiumText)
            LabeledFact(systemImage: "calendar.badge.clock", title: "Próximo pago", value: nextPaymentText)
        }
        .padding(16)
        .cardBackground(cornerRadius: 22)
    }

    private var nextPaymentText: String {
        if let date = policy.nextPaymentDate { return AppFormatters.shortDate(date) }
        if policy.paymentFrequency == .annual && policy.isInForce { return "Pagado por el año" }
        return "—"
    }

    // MARK: Cómo usarla

    private var howToUseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardTitle("¿Cómo uso mi seguro?", systemImage: "questionmark.circle.fill")
            step(1, "Lleva a tu mascota a cualquier veterinario o a una clínica de la red.")
            step(2, "Guarda la factura y el diagnóstico de la consulta.")
            step(3, "Solicita tu reembolso con tu número de póliza \(policy.policyNumber).")
        }
        .padding(16)
        .cardBackground(cornerRadius: 22)
    }

    private func step(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Theme.primaryGradient))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Acciones

    private var actions: some View {
        VStack(spacing: 12) {
            ShareLink(item: policy.shareText) {
                Label("Compartir póliza", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.softFilled)

            if policy.isInForce || policy.status == .scheduled {
                Button("Cancelar póliza", role: .destructive) {
                    isConfirmingCancel = true
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
    }

    private func cardTitle(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(Theme.textPrimary)
    }
}
