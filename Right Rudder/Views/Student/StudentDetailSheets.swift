//
//  StudentDetailSheets.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import SwiftData
import SwiftUI

// MARK: - StudentDetailSheets

/// Student Detail Sheets Modifier
struct StudentDetailSheets: ViewModifier {
  // MARK: - Properties

  @Binding var showingEditStudent: Bool
  @Binding var showingAddChecklist: Bool
  @Binding var showingCamera: Bool
  @Binding var showingPhotoLibrary: Bool
  @Binding var showingStudentRecord: Bool
  @Binding var showingShareSheet: Bool
  @Binding var showingDocuments: Bool
  @Binding var showingConflictResolution: Bool
  @Binding var showingEndorsementDetail: Bool
  @Binding var selectedEndorsement: EndorsementImage?
  let detectedConflicts: [DataConflict]
  let student: Student
  let getTemplates: () -> [ChecklistTemplate]
  let addEndorsementImage: (UIImage) -> Void
  let deleteEndorsement: (EndorsementImage) -> Void

  // MARK: - ViewModifier

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $showingEditStudent) {
        EditStudentView(student: student)
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingAddChecklist) {
        AddChecklistToStudentView(student: student, templates: getTemplates())
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingCamera) {
        CameraView { image in
          addEndorsementImage(image)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingPhotoLibrary) {
        PhotoLibraryView { image in
          addEndorsementImage(image)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingStudentRecord) {
        PDFExportService.showStudentRecord(student)
          .presentationDetents([.large])
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingShareSheet) {
        StudentShareView(student: student)
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingDocuments) {
        NavigationView {
          StudentDocumentsView(student: student)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingConflictResolution) {
        ConflictResolutionView(student: student, conflicts: detectedConflicts)
          .presentationDetents([.medium, .large])
          .presentationDragIndicator(.visible)
      }
      .sheet(isPresented: $showingEndorsementDetail) {
        if let endorsement = selectedEndorsement {
          EndorsementDetailView(endorsement: endorsement) {
            deleteEndorsement(endorsement)
            showingEndorsementDetail = false
          }
          .presentationDetents([.large])
          .presentationDragIndicator(.visible)
          .onAppear {
            print("🎯 Sheet is being presented, selectedEndorsement: \(endorsement.filename)")
          }
        } else {
          Text("No endorsement selected")
            .foregroundColor(.red)
        }
      }
  }
}

