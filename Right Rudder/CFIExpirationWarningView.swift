//
//  CFIExpirationWarningView.swift
//  Right Rudder
//
//  Created by AI on 10/6/25.
//

import SwiftUI

struct CFIExpirationWarningView: View {
  @Environment(\.dismiss) private var dismiss
  @AppStorage("instructorCFIExpirationDateString") private var instructorCFIExpirationDateString:
    String = ""
  @AppStorage("instructorCFIHasExpiration") private var instructorCFIHasExpiration: Bool = false
  @AppStorage("instructorName") private var instructorName: String = ""
  @AppStorage("instructorCFINumber") private var instructorCFINumber: String = ""

  let onDismiss: () -> Void

  private var instructorCFIExpirationDate: Date {
    if instructorCFIExpirationDateString.isEmpty {
      return Date()
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: instructorCFIExpirationDateString) ?? Date()
  }

  var body: some View {
    ZStack {
      // Background
      Color.black.opacity(0.4)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        // Header
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 60))
            .foregroundColor(.orange)

          Text("CFI Certificate Warning")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)

          Text(getWarningMessage())
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding(.top, 40)
        .padding(.horizontal, 20)

        // Content
        VStack(spacing: 20) {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Image(systemName: "person.circle")
                .foregroundColor(.blue)
                .font(.title2)
              VStack(alignment: .leading) {
                Text("Instructor: \(instructorName.isEmpty ? "Not Set" : instructorName)")
                  .font(.headline)
                Text("CFI Number: \(instructorCFINumber.isEmpty ? "Not Set" : instructorCFINumber)")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
              Spacer()
            }

            HStack {
              Image(
                systemName: instructorCFIHasExpiration
                  ? "calendar.badge.exclamationmark" : "clock.badge.exclamationmark"
              )
              .foregroundColor(getStatusColor())
              .font(.title2)
              VStack(alignment: .leading) {
                Text(getStatusTitle())
                  .font(.headline)
                Text(getStatusDescription())
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
              Spacer()
            }
          }
          .padding()
          .background(Color.appAdaptiveMutedBox)
          .cornerRadius(12)

          VStack(alignment: .leading, spacing: 8) {
            Text("Important Reminders:")
              .font(.headline)
              .fontWeight(.semibold)

            ForEach(getReminders(), id: \.self) { reminder in
              HStack(alignment: .top) {
                Text("•")
                  .fontWeight(.bold)
                  .foregroundColor(.blue)
                Text(reminder)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
            }
          }
          .padding()
          .background(Color.appAdaptiveMutedBox)
          .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)

        Spacer()

        // Action Buttons
        VStack(spacing: 12) {
          Button(action: {
            CFIExpirationWarningService.shared.markWarningShown()
            onDismiss()
            dismiss()
          }) {
            HStack {
              Image(systemName: "gear")
              Text("Update in Settings")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
          }

          Button(action: {
            CFIExpirationWarningService.shared.markWarningShown()
            onDismiss()
            dismiss()
          }) {
            Text("Dismiss for Today")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.appAdaptiveMutedBox)
              .foregroundColor(.primary)
              .cornerRadius(12)
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
      }
      .background(Color(.systemBackground))
      .cornerRadius(20)
      .padding(.horizontal, 20)
      .shadow(radius: 20)
    }
  }

  private func getWarningMessage() -> String {
    if instructorCFIHasExpiration {
      return "Your CFI certificate will expire soon!"
    } else {
      return "Your CFI Recent Experience is expiring soon!"
    }
  }

  private func getStatusTitle() -> String {
    if instructorCFIHasExpiration {
      return "Certificate Expiration"
    } else {
      return "Recent Experience Expiration"
    }
  }

  private func getStatusDescription() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM dd, yyyy"
    let dateString = formatter.string(from: instructorCFIExpirationDate)

    if instructorCFIHasExpiration {
      return "Expires on \(dateString)"
    } else {
      return "Valid until \(dateString)"
    }
  }

  private func getStatusColor() -> Color {
    let now = Date()
    let calendar = Calendar.current
    let daysUntilExpiration =
      calendar.dateComponents([.day], from: now, to: instructorCFIExpirationDate).day ?? 0

    if daysUntilExpiration <= 0 {
      return .red
    } else if daysUntilExpiration <= 30 {
      return .orange
    } else {
      return .yellow
    }
  }

  private func getReminders() -> [String] {
    var reminders: [String] = []

    if instructorCFIHasExpiration {
      reminders.append("Renew your CFI certificate before the expiration date")
      reminders.append("Complete required training and submit renewal application")
      reminders.append("Check with your local FSDO for specific requirements")
    } else {
      reminders.append("Complete required recent experience requirements")
      reminders.append("Ensure you meet the 24-month recent experience rule")
      reminders.append("Consider completing additional training or endorsements")
    }

    reminders.append("Update your instructor information in Settings when renewed")
    reminders.append("This warning will appear daily until your information is updated")

    return reminders
  }
}

struct CFIExpirationWarningService {
  @AppStorage("instructorCFIExpirationDateString") private var instructorCFIExpirationDateString:
    String = ""
  @AppStorage("instructorCFIHasExpiration") private var instructorCFIHasExpiration: Bool = false
  @AppStorage("instructorName") private var instructorName: String = ""
  @AppStorage("instructorCFINumber") private var instructorCFINumber: String = ""
  @AppStorage("lastCFIWarningDate") private var lastCFIWarningDate: String = ""

  static let shared = CFIExpirationWarningService()

  private init() {}

  private var instructorCFIExpirationDate: Date {
    if instructorCFIExpirationDateString.isEmpty {
      return Date()
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: instructorCFIExpirationDateString) ?? Date()
  }

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
    lastCFIWarningDate = getCurrentDateString()
  }

  private func getCurrentDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }
}

#Preview {
  CFIExpirationWarningView {
    print("Warning dismissed")
  }
}
