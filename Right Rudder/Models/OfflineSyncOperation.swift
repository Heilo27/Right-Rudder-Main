//
//  OfflineSyncOperation.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

// MARK: - OfflineSyncOperation

/// Represents a pending sync operation that needs to be retried when connectivity is restored
@Model
class OfflineSyncOperation {
  // MARK: - Properties

  var id: UUID = UUID()
  var operationType: String = ""  // "checklist_update", "checklist_add", "comment_add", "completion_change"
  var studentId: UUID = UUID()
  var checklistId: UUID?
  var checklistItemId: UUID?
  var operationData: Data = Data()  // JSON encoded operation data
  var createdAt: Date = Date()
  var retryCount: Int = 0
  var maxRetries: Int = 5
  var lastAttemptedAt: Date?
  var isCompleted: Bool = false

  // MARK: - Initialization

  init(
    operationType: String, studentId: UUID, checklistId: UUID? = nil, checklistItemId: UUID? = nil,
    operationData: Data
  ) {
    self.operationType = operationType
    self.studentId = studentId
    self.checklistId = checklistId
    self.checklistItemId = checklistItemId
    self.operationData = operationData
  }
}

