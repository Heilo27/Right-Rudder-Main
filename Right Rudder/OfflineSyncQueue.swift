import Foundation
import SwiftData
import CloudKit
import Combine
import Network

/// Represents a pending sync operation that needs to be retried when connectivity is restored
@Model
class OfflineSyncOperation {
    var id: UUID = UUID()
    var operationType: String = "" // "checklist_update", "checklist_add", "comment_add", "completion_change"
    var studentId: UUID = UUID()
    var checklistId: UUID?
    var checklistItemId: UUID?
    var operationData: Data = Data() // JSON encoded operation data
    var createdAt: Date = Date()
    var retryCount: Int = 0
    var maxRetries: Int = 5
    var lastAttemptedAt: Date?
    var isCompleted: Bool = false
    
    init(operationType: String, studentId: UUID, checklistId: UUID? = nil, checklistItemId: UUID? = nil, operationData: Data) {
        self.operationType = operationType
        self.studentId = studentId
        self.checklistId = checklistId
        self.checklistItemId = checklistItemId
        self.operationData = operationData
    }
}

/// Manages offline sync operations and retries
@MainActor
class OfflineSyncManager: ObservableObject {
    @Published var isOfflineMode = false
    @Published var pendingOperationsCount = 0
    @Published var lastSyncAttempt: Date?
    
    private var modelContext: ModelContext?
    private let networkMonitor = NetworkMonitor()
    
    init() {
        setupNetworkMonitoring()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.onConnectivityChange = { [weak self] isConnected in
            Task { @MainActor in
                self?.isOfflineMode = !isConnected
                if isConnected {
                    await self?.processPendingOperations()
                }
            }
        }
    }
    
    /// Queues a sync operation for later retry when connectivity is restored
    func queueSyncOperation(
        operationType: String,
        studentId: UUID,
        checklistId: UUID? = nil,
        checklistItemId: UUID? = nil,
        operationData: Data
    ) async {
        guard let modelContext = modelContext else { return }
        
        let operation = OfflineSyncOperation(
            operationType: operationType,
            studentId: studentId,
            checklistId: checklistId,
            checklistItemId: checklistItemId,
            operationData: operationData
        )
        
        modelContext.insert(operation)
        
        do {
            try modelContext.save()
            await updatePendingOperationsCount()
        } catch {
            print("Failed to queue sync operation: \(error)")
        }
    }
    
    /// Processes all pending sync operations when connectivity is restored
    func processPendingOperations() async {
        guard let modelContext = modelContext else { return }
        
        let request = FetchDescriptor<OfflineSyncOperation>(
            predicate: #Predicate<OfflineSyncOperation> { operation in
                !operation.isCompleted && operation.retryCount < operation.maxRetries
            }
        )
        
        do {
            let pendingOperations = try modelContext.fetch(request)
            print("Processing \(pendingOperations.count) pending sync operations")
            
            for operation in pendingOperations {
                await processOperation(operation)
            }
            
            await updatePendingOperationsCount()
        } catch {
            print("Failed to fetch pending operations: \(error)")
        }
    }
    
    private func processOperation(_ operation: OfflineSyncOperation) async {
        guard let modelContext = modelContext else { return }
        
        operation.lastAttemptedAt = Date()
        operation.retryCount += 1
        
        do {
            let success = await executeOperation(operation)
            
            if success {
                operation.isCompleted = true
                print("Successfully processed offline operation: \(operation.operationType)")
            } else {
                print("Failed to process operation: \(operation.operationType), retry count: \(operation.retryCount)")
            }
            
            try modelContext.save()
        } catch {
            print("Failed to process operation: \(error)")
        }
    }
    
    private func executeOperation(_ operation: OfflineSyncOperation) async -> Bool {
        switch operation.operationType {
        case "checklist_update":
            return await executeChecklistUpdate(operation)
        case "checklist_add":
            return await executeChecklistAdd(operation)
        case "comment_add":
            return await executeCommentAdd(operation)
        case "completion_change":
            return await executeCompletionChange(operation)
        default:
            print("Unknown operation type: \(operation.operationType)")
            return false
        }
    }
    
    private func executeChecklistUpdate(_ operation: OfflineSyncOperation) async -> Bool {
        guard let modelContext = modelContext,
              let checklistId = operation.checklistId else { return false }
        
        do {
            // Find the checklist assignment and student
            let checklistRequest = FetchDescriptor<ChecklistAssignment>()
            let allChecklists = try modelContext.fetch(checklistRequest)
            let checklist = allChecklists.first { $0.id == checklistId }
            
            guard let foundChecklist = checklist,
                  let student = foundChecklist.student else { return false }
            
            // Sync to CloudKit
            let shareService = CloudKitShareService()
            await shareService.syncStudentChecklistAssignmentsToSharedZone(student, modelContext: modelContext)
            
            return true
        } catch {
            print("Failed to execute checklist update: \(error)")
            return false
        }
    }
    
    private func executeChecklistAdd(_ operation: OfflineSyncOperation) async -> Bool {
        guard let modelContext = modelContext else { return false }
        
        do {
            // Find the student
            let studentRequest = FetchDescriptor<Student>()
            let allStudents = try modelContext.fetch(studentRequest)
            let student = allStudents.first { $0.id == operation.studentId }
            
            guard let foundStudent = student else { return false }
            
            // Sync to CloudKit
            let shareService = CloudKitShareService()
            await shareService.syncStudentChecklistAssignmentsToSharedZone(foundStudent, modelContext: modelContext)
            
            return true
        } catch {
            print("Failed to execute checklist add: \(error)")
            return false
        }
    }
    
    private func executeCommentAdd(_ operation: OfflineSyncOperation) async -> Bool {
        return await executeChecklistUpdate(operation)
    }
    
    private func executeCompletionChange(_ operation: OfflineSyncOperation) async -> Bool {
        return await executeChecklistUpdate(operation)
    }
    
    private func updatePendingOperationsCount() async {
        guard let modelContext = modelContext else { return }
        
        let request = FetchDescriptor<OfflineSyncOperation>(
            predicate: #Predicate<OfflineSyncOperation> { operation in
                !operation.isCompleted
            }
        )
        
        do {
            let pendingOperations = try modelContext.fetch(request)
            pendingOperationsCount = pendingOperations.count
        } catch {
            print("Failed to update pending operations count: \(error)")
        }
    }
    
    /// Cleans up completed operations older than 7 days
    func cleanupCompletedOperations() async {
        guard let modelContext = modelContext else { return }
        
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let request = FetchDescriptor<OfflineSyncOperation>(
            predicate: #Predicate<OfflineSyncOperation> { operation in
                operation.isCompleted && operation.createdAt < sevenDaysAgo
            }
        )
        
        do {
            let completedOperations = try modelContext.fetch(request)
            for operation in completedOperations {
                modelContext.delete(operation)
            }
            try modelContext.save()
            print("Cleaned up \(completedOperations.count) completed operations")
        } catch {
            print("Failed to cleanup completed operations: \(error)")
        }
    }
}

/// Monitors network connectivity
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    
    var onConnectivityChange: ((Bool) -> Void)?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? false
                self?.isConnected = path.status == .satisfied
                
                if wasConnected != self?.isConnected {
                    self?.onConnectivityChange?(self?.isConnected ?? false)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
