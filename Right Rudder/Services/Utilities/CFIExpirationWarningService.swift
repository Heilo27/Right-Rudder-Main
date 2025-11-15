//
//  CFIExpirationWarningService.swift
//  Right Rudder
//
//  Created by AI on 10/6/25.
//

import Foundation

// MARK: - CFIExpirationWarningService

struct CFIExpirationWarningService {
  // MARK: - Singleton

  static let shared = CFIExpirationWarningService()

  private init() {}

  // MARK: - Properties

  private var userDefaults: UserDefaults {
    UserDefaults.standard
  }

  private var instructorCFIExpirationDateString: String {
    userDefaults.string(forKey: "instructorCFIExpirationDateString") ?? ""
  }

  private var instructorCFIHasExpiration: Bool {
    userDefaults.bool(forKey: "instructorCFIHasExpiration")
  }

  private var instructorName: String {
    userDefaults.string(forKey: "instructorName") ?? ""
  }

  private var instructorCFINumber: String {
    userDefaults.string(forKey: "instructorCFINumber") ?? ""
  }

  private var lastCFIWarningDate: String {
    userDefaults.string(forKey: "lastCFIWarningDate") ?? ""
  }

  // MARK: - Computed Properties

  private var instructorCFIExpirationDate: Date {
    if instructorCFIExpirationDateString.isEmpty {
      return Date()
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: instructorCFIExpirationDateString) ?? Date()
  }

  // MARK: - Methods

  func shouldShowWarning() -> Bool {
    // Check if instructor info is configured
    guard !instructorName.isEmpty && !instructorCFINumber.isEmpty else {
      return false
    }

    // Check if we've already shown the warning today
    let today = getCurrentDateString()
    if lastCFIWarningDate == today {
      return false
    }

    let now = Date()
    let calendar = Calendar.current

    if instructorCFIHasExpiration {
      // For expiration dates: show warning if less than 2 months away
      let twoMonthsFromNow = calendar.date(byAdding: .month, value: 2, to: now) ?? now
      return instructorCFIExpirationDate <= twoMonthsFromNow
    } else {
      // For recent experience: show warning if 22 months or longer (2 months remaining)
      let twentyTwoMonthsAgo = calendar.date(byAdding: .month, value: -22, to: now) ?? now
      return instructorCFIExpirationDate <= twentyTwoMonthsAgo
    }
  }

  func markWarningShown() {
    userDefaults.set(getCurrentDateString(), forKey: "lastCFIWarningDate")
  }

  // MARK: - Private Helpers

  private func getCurrentDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }
}

