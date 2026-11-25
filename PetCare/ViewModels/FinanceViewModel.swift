import Foundation
import Observation

struct CategoryTotal: Identifiable {
    let category: ExpenseCategory
    let total: Double
    let share: Double
    var id: String { category.rawValue }
}

struct PetTotal: Identifiable {
    let pet: PetRecord
    let total: Double
    let share: Double
    var id: UUID { pet.id }
}

struct ExpenseMonthSection: Identifiable {
    let id: Date
    let title: String
    let total: Double
    let expenses: [Expense]
}

@MainActor
@Observable
final class FinanceViewModel {
    /// `nil` = todas las mascotas.
    private(set) var selectedPetID: UUID?

    private let store: PetCareStore

    init(store: PetCareStore) {
        self.store = store
    }

    // MARK: - Datos de la vista

    var pets: [PetRecord] { store.pets }
    var selectedPet: PetRecord? { store.pet(withID: selectedPetID) }

    private var expenses: [Expense] {
        (selectedPet.map { [$0] } ?? store.pets).flatMap(\.expenses)
    }

    private var currentMonthExpenses: [Expense] { monthExpenses(offset: 0) }

    var hasExpenses: Bool { !expenses.isEmpty }

    var summaryTitle: String {
        "GASTO DE \(AppFormatters.monthName(.now).uppercased())"
    }

    var summarySubtitle: String {
        selectedPet.map { "Solo \($0.name)" } ?? "Todas tus mascotas"
    }

    var currentMonthTotal: Double { total(of: currentMonthExpenses) }

    var yearTotal: Double {
        guard let year = Calendar.current.dateInterval(of: .year, for: .now) else { return 0 }
        return total(of: expenses.filter { year.contains($0.date) })
    }

    /// "▲ 12% vs mes anterior"
    var monthChange: (text: String, isIncrease: Bool)? {
        let previous = total(of: monthExpenses(offset: -1))
        guard previous > 0 else { return nil }
        let change = (currentMonthTotal - previous) / previous * 100
        let arrow = change >= 0 ? "▲" : "▼"
        return ("\(arrow) \(Int(abs(change).rounded()))% vs mes anterior", change >= 0)
    }

    var categoryTotals: [CategoryTotal] {
        let monthTotal = currentMonthTotal
        guard monthTotal > 0 else { return [] }
        return Dictionary(grouping: currentMonthExpenses, by: \.category)
            .map { category, items in
                let sum = total(of: items)
                return CategoryTotal(category: category, total: sum, share: sum / monthTotal)
            }
            .sorted { $0.total > $1.total }
    }

    /// Solo cuando se ven todas las mascotas y hay más de una.
    var petTotals: [PetTotal] {
        guard selectedPet == nil, store.pets.count > 1 else { return [] }
        let monthTotal = currentMonthTotal
        guard monthTotal > 0, let month = Calendar.current.dateInterval(of: .month, for: .now) else { return [] }
        return store.pets
            .map { pet in
                let sum = total(of: pet.expenses.filter { month.contains($0.date) })
                return PetTotal(pet: pet, total: sum, share: sum / monthTotal)
            }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }

    var monthSections: [ExpenseMonthSection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense in
            calendar.dateInterval(of: .month, for: expense.date)?.start ?? expense.date
        }
        return grouped.keys.sorted(by: >).map { month in
            let items = (grouped[month] ?? []).sorted { $0.date > $1.date }
            return ExpenseMonthSection(
                id: month,
                title: AppFormatters.monthYear(month),
                total: total(of: items),
                expenses: items
            )
        }
    }

    func subtitle(for expense: Expense) -> String {
        let date = AppFormatters.dayMonth(expense.date)
        guard selectedPet == nil, let petName = expense.pet?.name else { return date }
        return "\(petName) · \(date)"
    }

    func title(for expense: Expense) -> String {
        expense.note.isEmpty ? expense.category.displayName : expense.note
    }

    // MARK: - Acciones

    func selectPet(_ id: UUID?) {
        selectedPetID = id
    }

    func makeDraft() -> ExpenseDraft {
        ExpenseDraft(petID: selectedPetID ?? store.pets.first?.id)
    }

    func addExpense(_ draft: ExpenseDraft) {
        store.addExpense(draft)
    }

    func deleteExpense(_ expense: Expense) {
        store.deleteExpense(expense)
    }

    // MARK: - Privado

    private func monthExpenses(offset: Int) -> [Expense] {
        let calendar = Calendar.current
        guard let reference = calendar.date(byAdding: .month, value: offset, to: .now),
              let month = calendar.dateInterval(of: .month, for: reference) else { return [] }
        return expenses.filter { month.contains($0.date) }
    }

    private func total(of items: [Expense]) -> Double {
        items.reduce(0) { $0 + $1.amount }
    }
}
