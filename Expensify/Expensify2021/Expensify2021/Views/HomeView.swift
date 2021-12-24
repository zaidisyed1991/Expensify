//
//  HomeView.swift
//  Expensify2021
//
//  Created by Ryan on 11/15/21.
//

import SwiftUI
import CoreData
import Firebase
import Charts

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("Hello \(User.me.fname)!").font(.title)
                Text("\(viewModel.rank)").fontWeight(.bold)
                
                HStack {
                    Text("\(Date(), style: .date) ")
                    Text("\(Date(), style: .time)")
                }
                
                Group {
                    Spacer().frame(height: 12)
                    Text("Spendings by status")
                    PieChart(entries: viewModel.statuses, colors: ([.green, .red, .orange] as [Color]).map { $0.uiColor })
                        .frame(height: UIScreen.main.bounds.width)
                }
                
                Group {
                    Spacer().frame(height: 12)
                    Text("Expenses by category").fontWeight(.bold)
                    PieChart(entries: viewModel.categories)
                        .frame(height: UIScreen.main.bounds.width)
                }
                
                Group {
                    Spacer().frame(height: 12)
                    if User.me.isManager {
                        Text("Spendings by employee").fontWeight(.bold)
                        BarChart(axis: .horizontal, entries: viewModel.users, numberStyle: .currency)
                            .frame(height: UIScreen.main.bounds.width)
                    } else {
                        Text("Spendings this week").fontWeight(.bold)
                        BarChart(axis: .vertical, entries: viewModel.expensesThisWeek, numberStyle: .currency)
                            .frame(height: UIScreen.main.bounds.width)
                    }
                }
            }
        }.background (Image("background")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        )
    }
}

class HomeViewModel: ObservableObject {
    
    struct Status {
        let label: String
        let value: Double
    }
    
    @Published fileprivate var statuses: [PieChartDataEntry] = []
    @Published fileprivate var categories: [PieChartDataEntry] = []
    @Published fileprivate var users: [(label: String, value: Double)] = []
    @Published fileprivate var expensesThisWeek: [(label: String, value: Double)] = []

    var rank = User.me.isManager ? "Manager" : "Regular Employee"

    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
        listener = nil
    }
    
    init() {
        if User.me.isManager {
            listener = collectionExpenses
                .addSnapshotListener(parse)
        } else {
            listener = collectionExpenses
                .whereField("userId", isEqualTo: User.me.id)
                .addSnapshotListener(parse)
        }
    }
    
    func parse(snapshot: QuerySnapshot?, error: Error?) {
        guard User.isLoggedIn else { return }
        
        let expenses = snapshot?.documents.compactMap { Expense($0) } ?? []

        let approved = expenses.filter { $0.approval == "approved" }.count
        let rejected = expenses.filter { $0.approval == "rejected" }.count
        let underReview = expenses.count - approved - rejected
        if [approved, rejected, underReview].allSatisfy({ $0 == 0 }) {
            statuses = []
        } else {
            statuses = [
                .init(value: Double(approved), label: "Approved"),
                .init(value: Double(rejected), label: "Rejected"),
                .init(value: Double(underReview), label: "Under review")
            ]
        }
        
        let expensesByCategories = expenses.reduce([String: Double](), { partialResult, expense in
            var partialResult = partialResult
            if partialResult[expense.category] == nil {
                partialResult[expense.category] = Double(expenses.filter { $0.category == expense.category }.count)
            }
            return partialResult
        })
        categories = expensesByCategories.enumerated().map { item in
            PieChartDataEntry(value: item.element.value, label: item.element.key)
        }
        
        if User.me.isManager {
            users.removeAll()
            let expensesByUsers = expenses.reduce([String: Double](), { partialResult, expense in
                var partialResult = partialResult
                if partialResult[expense.userId] == nil {
                    partialResult[expense.userId] = expenses.filter { $0.userId == expense.userId }.reduce(0, { Double($1.expense) ?? 0 })
                }
                return partialResult
            })
            for userId in expensesByUsers.keys {
                collectionUsers.document(userId).getDocument { [weak self] snapshot, error in
                    self?.users.append((label: snapshot?.data()?["email"] as? String ?? "", value: expensesByUsers[userId]!))
                }
            }
        } else {
            expensesThisWeek.removeAll()
            for day in Date.currentWeek {
                self.expensesThisWeek.append((label: day.string("EEE"), value: expenses.filter { $0.createdAt.isInSameDay(with: day) }.reduce(Double(0), { $0 + (Double($1.expense) ?? 0) })))
            }
        }
    }
}

extension Date {
    static var currentWeek: [Date] {
        var calendar = Calendar.autoupdatingCurrent
        calendar.firstWeekday = 2 // Start on Monday (or 1 for Sunday)
        let today = calendar.startOfDay(for: Date())
        var week = [Date]()
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
            for i in 0...6 {
                if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                    week += [day]
                }
            }
        }
        return week
    }
    
    func isInSameDay(with: Date) -> Bool {
        string("dMy") == with.string("dMy")
    }
    
    func string(_ format: String = "dd-MM-yyyy") -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}
