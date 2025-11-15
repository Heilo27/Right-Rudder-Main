//
//  PDFExportService.swift
//  Right Rudder
//
//  Created by Ryan on 10/2/25.
//

import Combine
import Foundation
import SwiftUI

class PDFExportService {
  static func showStudentRecord(_ student: Student) -> some View {
    StudentRecordWebView(student: student)
  }

}
