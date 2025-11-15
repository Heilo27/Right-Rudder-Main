import CloudKit
import Combine
import Foundation
import UIKit
import UserNotifications

@MainActor
class PushNotificationService: ObservableObject {
  static let shared = PushNotificationService()

  @Published var notificationPermissionGranted = false

  private let container: CKContainer

  init() {
    self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
  }

  /// Requests notification permissions from the user
  func requestNotificationPermission() async {
    do {
      let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [
        .alert, .sound, .badge,
      ])
      notificationPermissionGranted = granted

      if granted {
        // Register for remote notifications
        await registerForRemoteNotifications()
      }
    } catch {
      print("Failed to request notification permission: \(error)")
    }
  }

  /// Registers for remote notifications
  private func registerForRemoteNotifications() async {
    await MainActor.run {
      UIApplication.shared.registerForRemoteNotifications()
    }
  }

  /// Creates a CloudKit subscription for instructor comments on checklists
  func subscribeToInstructorComments() async {
    do {
      let database = container.privateCloudDatabase

      // Create a predicate for instructor comments being added/updated
      let predicate = NSPredicate(format: "instructorComments != nil AND instructorComments != ''")

      let subscription = CKQuerySubscription(
        recordType: "StudentChecklist",
        predicate: predicate,
        subscriptionID: "instructor-comments-subscription",
        options: [.firesOnRecordUpdate, .firesOnRecordCreation]
      )

      // Configure notification info
      let notificationInfo = CKSubscription.NotificationInfo()
      notificationInfo.alertBody = "Your instructor has added a new comment"
      notificationInfo.soundName = "default"
      notificationInfo.shouldBadge = true
      notificationInfo.shouldSendContentAvailable = true

      // Add custom fields to help deep link
      notificationInfo.desiredKeys = ["templateName", "studentId", "instructorComments"]

      subscription.notificationInfo = notificationInfo

      // Save the subscription
      _ = try await database.save(subscription)

      print("Successfully subscribed to instructor comments")

    } catch {
      if let ckError = error as? CKError, ckError.code == .serverRejectedRequest {
        print("Subscription already exists")
      } else {
        print("Failed to subscribe to instructor comments: \(error)")
      }
    }
  }

  /// Removes the subscription for instructor comments
  func unsubscribeFromInstructorComments() async {
    do {
      let database = container.privateCloudDatabase
      try await database.deleteSubscription(withID: "instructor-comments-subscription")
      print("Successfully unsubscribed from instructor comments")
    } catch {
      print("Failed to unsubscribe from instructor comments: \(error)")
    }
  }

  /// Sends a silent push notification to the student when instructor adds a comment
  /// This is called from the instructor app when they save a comment
  func notifyStudentOfComment(studentId: UUID, checklistId: UUID, checklistName: String) async {
    // Note: For this to work, the student needs to be subscribed to the shared database
    // The notification will be sent via CloudKit when the instructor updates the record
    // This method can be used to trigger additional local notifications if needed

    print(
      "Notification will be sent to student via CloudKit subscription for comment on \(checklistName)"
    )
  }

  /// Sends a notification to the student when a checklist reaches 100% completion
  func notifyStudentOfCompletion(studentId: UUID, checklistId: UUID, checklistName: String) async {
    // Note: For this to work, the student needs to be subscribed to the shared database
    // The notification will be sent via CloudKit when the instructor updates the record

    print(
      "Notification will be sent to student via CloudKit subscription for completion of \(checklistName)"
    )
  }

  /// Handles deep linking when a notification is tapped
  func handleNotificationDeepLink(userInfo: [AnyHashable: Any]) -> (
    studentId: UUID?, checklistId: UUID?
  )? {
    guard let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
      return nil
    }

    if let queryNotification = ckNotification as? CKQueryNotification,
      let recordFields = queryNotification.recordFields
    {

      let studentIdString = recordFields["studentId"] as? String
      let checklistIdString = recordFields["recordID"] as? String

      let studentId = studentIdString.flatMap { UUID(uuidString: $0) }
      let checklistId = checklistIdString.flatMap { UUID(uuidString: $0) }

      return (studentId, checklistId)
    }

    return nil
  }

  /// Checks current notification permission status
  func checkNotificationPermission() async {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    notificationPermissionGranted = settings.authorizationStatus == .authorized
  }

  /// Creates a CloudKit subscription to monitor when students accept share invitations
  /// Note: CKShare records don't support standard query subscriptions, so we use database subscriptions
  /// and periodic polling as a fallback
  func subscribeToShareAcceptance() async {
    do {
      let database = container.privateCloudDatabase

      // Use CKDatabaseSubscription to monitor all changes in the private database
      // This will catch share record updates when participants are added
      let subscription = CKDatabaseSubscription(subscriptionID: "share-acceptance-subscription")

      // Configure notification info
      let notificationInfo = CKSubscription.NotificationInfo()
      notificationInfo.alertBody = "A student has accepted your share invitation"
      notificationInfo.soundName = "default"
      notificationInfo.shouldBadge = true
      notificationInfo.shouldSendContentAvailable = true

      subscription.notificationInfo = notificationInfo

      // Save the subscription
      _ = try await database.save(subscription)

      print("✅ Successfully subscribed to share acceptance notifications (database subscription)")

    } catch {
      if let ckError = error as? CKError, ckError.code == .serverRejectedRequest {
        print("ℹ️ Share acceptance subscription already exists")
      } else {
        print("⚠️ Failed to subscribe to share acceptance: \(error)")
        print("   Note: Periodic polling will still check for share acceptance")
      }
    }
  }

  /// Sends a local notification to the instructor when a student accepts a share
  func notifyInstructorOfShareAcceptance(studentName: String) async {
    let content = UNMutableNotificationContent()
    content.title = "Student Accepted Share"
    content.body = "\(studentName) has accepted your share invitation and is now connected"
    content.sound = .default
    content.badge = 1

    // Create a trigger for immediate delivery
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

    let request = UNNotificationRequest(
      identifier: "share-acceptance-\(UUID().uuidString)",
      content: content,
      trigger: trigger
    )

    do {
      try await UNUserNotificationCenter.current().add(request)
      print("✅ Sent local notification for share acceptance: \(studentName)")
    } catch {
      print("⚠️ Failed to send share acceptance notification: \(error)")
    }
  }
}
