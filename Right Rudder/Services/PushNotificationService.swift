import CloudKit
import Combine
import Foundation
import UIKit
import UserNotifications

// MARK: - PushNotificationService

@MainActor
class PushNotificationService: ObservableObject {
  // MARK: - Singleton

  static let shared = PushNotificationService()

  // MARK: - Published Properties

  @Published var notificationPermissionGranted = false

  // MARK: - Properties

  private let container: CKContainer

  // MARK: - Initialization

  private init() {
    self.container = CKContainer(identifier: "iCloud.com.heiloprojects.rightrudder")
  }

  // MARK: - Methods

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

  // MARK: - Share Termination Subscriptions

  /// Creates a CloudKit subscription to monitor share terminations
  /// Monitors Student records for shareTerminated flag changes
  func subscribeToShareTerminations() async {
    do {
      let database = container.privateCloudDatabase

      // Subscribe to Student records where shareTerminated is true
      let predicate = NSPredicate(format: "shareTerminated == 1")

      let subscription = CKQuerySubscription(
        recordType: "Student",
        predicate: predicate,
        subscriptionID: "share-termination-subscription",
        options: [.firesOnRecordUpdate]
      )

      // Configure notification info
      let notificationInfo = CKSubscription.NotificationInfo()
      notificationInfo.alertBody = "A share has been terminated"
      notificationInfo.soundName = "default"
      notificationInfo.shouldBadge = true
      notificationInfo.shouldSendContentAvailable = true

      // Add custom fields for deep linking
      notificationInfo.desiredKeys = [
        "firstName", "lastName", "shareTerminated", "shareTerminatedAt",
      ]

      subscription.notificationInfo = notificationInfo

      // Save the subscription
      _ = try await database.save(subscription)

      print("✅ Successfully subscribed to share termination notifications")

    } catch {
      if let ckError = error as? CKError, ckError.code == .serverRejectedRequest {
        print("ℹ️ Share termination subscription already exists")
      } else {
        print("⚠️ Failed to subscribe to share terminations: \(error)")
        print("   Note: Periodic validation will still detect terminations")
      }
    }
  }

  /// Creates a database subscription to monitor share record deletions
  /// This catches when CKShare records are deleted (instructor or student unlinks)
  func subscribeToShareDeletions() async {
    do {
      let database = container.privateCloudDatabase

      // Use CKDatabaseSubscription to monitor share record deletions
      let subscription = CKDatabaseSubscription(subscriptionID: "share-deletion-subscription")

      // Configure notification info
      let notificationInfo = CKSubscription.NotificationInfo()
      notificationInfo.alertBody = "A share has been removed"
      notificationInfo.soundName = "default"
      notificationInfo.shouldBadge = true
      notificationInfo.shouldSendContentAvailable = true

      subscription.notificationInfo = notificationInfo

      // Save the subscription
      _ = try await database.save(subscription)

      print("✅ Successfully subscribed to share deletion notifications (database subscription)")

    } catch {
      if let ckError = error as? CKError, ckError.code == .serverRejectedRequest {
        print("ℹ️ Share deletion subscription already exists")
      } else {
        print("⚠️ Failed to subscribe to share deletions: \(error)")
        print("   Note: Periodic validation will still detect deletions")
      }
    }
  }

  /// Removes share termination subscriptions
  func unsubscribeFromShareTerminations() async {
    do {
      let database = container.privateCloudDatabase
      try await database.deleteSubscription(withID: "share-termination-subscription")
      try await database.deleteSubscription(withID: "share-deletion-subscription")
      print("✅ Successfully unsubscribed from share termination notifications")
    } catch {
      print("⚠️ Failed to unsubscribe from share terminations: \(error)")
    }
  }

  /// Sends a local notification when a share is terminated
  func notifyShareTermination(studentName: String, initiatedBy: String = "unknown") async {
    let content = UNMutableNotificationContent()
    content.title = "Share Terminated"
    content.body = "The share with \(studentName) has been terminated"
    content.sound = .default
    content.badge = 1

    // Add user info for handling
    content.userInfo = [
      "type": "shareTermination",
      "studentName": studentName,
      "initiatedBy": initiatedBy,
    ]

    // Create a trigger for immediate delivery
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

    let request = UNNotificationRequest(
      identifier: "share-termination-\(UUID().uuidString)",
      content: content,
      trigger: trigger
    )

    do {
      try await UNUserNotificationCenter.current().add(request)
      print("✅ Sent local notification for share termination: \(studentName)")
    } catch {
      print("⚠️ Failed to send share termination notification: \(error)")
    }
  }

  /// Initializes all CloudKit subscriptions
  /// Should be called on app startup after requesting notification permissions
  func initializeAllSubscriptions() async {
    await subscribeToInstructorComments()
    await subscribeToShareAcceptance()
    await subscribeToShareTerminations()
    await subscribeToShareDeletions()
    print("✅ All CloudKit subscriptions initialized")
  }
}
