//
//  FAAEndorsement.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation

// MARK: - FAAEndorsement

struct FAAEndorsement: Identifiable, Hashable {
  // MARK: - Properties

  let id = UUID()
  let code: String
  let title: String
  let template: String
  let requiredFields: [String]

  // MARK: - Hashable

  static func == (lhs: FAAEndorsement, rhs: FAAEndorsement) -> Bool {
    lhs.code == rhs.code
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(code)
  }

  // MARK: - Static Data

  static let allEndorsements: [FAAEndorsement] = [
    // Prerequisites for the Practical Test Endorsement
    FAAEndorsement(
      code: "A.1",
      title: "Prerequisites for practical test: § 61.39(a)(6)(i) and (ii)",
      template:
        "I certify that [First name, MI, Last name] has received and logged training time within 2 calendar months preceding the month of application in preparation for the practical test and they are prepared for the required practical test for the issuance of [applicable] certificate.",
      requiredFields: ["applicable"]
    ),

    FAAEndorsement(
      code: "A.2",
      title: "Review of deficiencies identified on airman knowledge test: § 61.39(a)(6)(iii)",
      template:
        "I certify that [First name, MI, Last name] has demonstrated satisfactory knowledge of the subject areas in which they were deficient on the [applicable] airman knowledge test.",
      requiredFields: ["applicable"]
    ),

    // Student Pilot Endorsements
    FAAEndorsement(
      code: "A.3",
      title: "Pre-solo aeronautical knowledge: § 61.87(b)",
      template:
        "I certify that [First name, MI, Last name] has satisfactorily completed the pre-solo knowledge test of § 61.87(b) for the [make and model (M/M)] aircraft.",
      requiredFields: ["make and model (M/M)"]
    ),

    FAAEndorsement(
      code: "A.4",
      title: "Pre-solo flight training: § 61.87(c)(1) and (2)",
      template:
        "I certify that [First name, MI, Last name] has received and logged pre-solo flight training for the maneuvers and procedures that are appropriate to the [M/M] aircraft. I have determined they have demonstrated satisfactory proficiency and safety on the maneuvers and procedures required by § 61.87 in this or similar make and model of aircraft to be flown.",
      requiredFields: ["M/M"]
    ),

    FAAEndorsement(
      code: "A.5",
      title: "Pre-solo flight training at night: § 61.87(o)",
      template:
        "I certify that [First name, MI, Last name] has received flight training at night on night flying procedures that include takeoffs, approaches, landings, and go-arounds at night at the [airport name] airport where the solo flight will be conducted; navigation training at night in the vicinity of the [airport name] airport where the solo flight will be conducted. This endorsement expires 90 calendar days from the date the flight training at night was received.",
      requiredFields: ["airport name"]
    ),

    FAAEndorsement(
      code: "A.6",
      title: "Solo flight (first 90-calendar-day period): § 61.87(n)",
      template:
        "I certify that [First name, MI, Last name] has received the required training to qualify for solo flying. I have determined they meet the applicable requirements of § 61.87(n) and are proficient to make solo flights in [M/M].",
      requiredFields: ["M/M"]
    ),

    FAAEndorsement(
      code: "A.7",
      title: "Solo flight (each additional 90-calendar-day period): § 61.87(p)",
      template:
        "I certify that [First name, MI, Last name] has received the required training to qualify for solo flying. I have determined that they meet the applicable requirements of § 61.87(p) and are proficient to make solo flights in [M/M].",
      requiredFields: ["M/M"]
    ),

    FAAEndorsement(
      code: "A.8",
      title: "Solo takeoffs and landings at another airport within 25 NM: § 61.93(b)(1)",
      template:
        "I certify that [First name, MI, Last name] has received the required training of § 61.93(b)(1). I have determined that they are proficient to practice solo takeoffs and landings at [airport name]. The takeoffs and landings at [airport name] are subject to the following conditions: [List any applicable conditions or limitations.]",
      requiredFields: ["airport name", "List any applicable conditions or limitations"]
    ),

    FAAEndorsement(
      code: "A.9",
      title: "Solo cross-country flight: § 61.93(c)(1) and (2)",
      template:
        "I certify that [First name, MI, Last name] has received the required solo cross-country training. I find they have met the applicable requirements of § 61.93 and are proficient to make solo cross-country flights in a [M/M] aircraft, [aircraft category].",
      requiredFields: ["M/M", "aircraft category"]
    ),

    FAAEndorsement(
      code: "A.10",
      title: "Solo cross-country flight: § 61.93(c)(3)",
      template:
        "I have reviewed the cross-country planning of [First name, MI, Last name]. I find the planning and preparation to be correct to make the solo flight from [origination airport] to [origination airport] via [route of flight] with landings at [names of the airports] in a [M/M] aircraft on [date]. [List any applicable conditions or limitations.]",
      requiredFields: [
        "origination airport", "route of flight", "names of the airports", "M/M", "date",
        "List any applicable conditions or limitations",
      ]
    ),

    // Additional Student Pilot Endorsements
    FAAEndorsement(
      code: "A.11",
      title: "Repeated solo cross-country flights not more than 50 NM: § 61.93(b)(2)",
      template:
        "I certify that [First name, MI, Last name] has received the required training in both directions between and at both [airport names]. I have determined that they are proficient of § 61.93(b)(2) to conduct repeated solo cross-country flights over that route, subject to the following conditions: [List any applicable conditions or limitations.]",
      requiredFields: ["airport names", "List any applicable conditions or limitations"]
    ),

    FAAEndorsement(
      code: "A.12",
      title: "Solo flight in Class B airspace: § 61.95(a)",
      template:
        "I certify that [First name, MI, Last name] has received the required training of § 61.95(a). I have determined they are proficient to conduct solo flights in [name of Class B] airspace. [List any applicable conditions or limitations.]",
      requiredFields: ["name of Class B", "List any applicable conditions or limitations"]
    ),

    FAAEndorsement(
      code: "A.13",
      title:
        "Solo flight to, from, or at an airport located in Class B airspace: § 61.95(b) and § 91.131(b)(1)",
      template:
        "I certify that [First name, MI, Last name] has received the required training of § 61.95(b)(1). I have determined that they are proficient to conduct solo flight operations at [name of airport]. [List any applicable conditions or limitations.]",
      requiredFields: ["name of airport", "List any applicable conditions or limitations"]
    ),

    FAAEndorsement(
      code: "A.14",
      title: "Endorsement of U.S. citizenship recommended by TSA: 49 CFR part 1552, § 1552.15(c)",
      template:
        "I certify that [First name, MI, Last name] has presented me a [type of document presented, such as a U.S. birth certificate or U.S. passport, and the relevant control or sequential number on the document, if any] establishing that they are a U.S. citizen or national in accordance with 49 CFR § 1552.15(c).",
      requiredFields: [
        "type of document presented, such as a U.S. birth certificate or U.S. passport, and the relevant control or sequential number on the document, if any"
      ]
    ),

    // Sport Pilot Endorsements
    FAAEndorsement(
      code: "A.17",
      title: "Sport Pilot - Aeronautical knowledge test: §§ 61.35(a)(1) and 61.309",
      template:
        "I certify that [First name, MI, Last name] has received the required aeronautical knowledge training of § 61.309. I have determined that they are prepared for the [name of] knowledge test.",
      requiredFields: ["name of"]
    ),

    FAAEndorsement(
      code: "A.20",
      title: "Sport Pilot - Taking sport pilot practical test: §§ 61.309, 61.311, and 61.313",
      template:
        "I certify that [First name, MI, Last name] has received the training required in accordance with §§ 61.309 and 61.311 and met the aeronautical experience requirements of § 61.313. I have determined that they are prepared for the [type of] practical test.",
      requiredFields: ["type of"]
    ),

    // Private Pilot Endorsements
    FAAEndorsement(
      code: "A.32",
      title: "Private Pilot - Aeronautical knowledge test: §§ 61.35(a)(1), 61.103(d), and 61.105",
      template:
        "I certify that [First name, MI, Last name] has received the required training in accordance with § 61.105. I have determined they are prepared for the [name of] knowledge test.",
      requiredFields: ["name of"]
    ),

    FAAEndorsement(
      code: "A.33",
      title:
        "Private Pilot - Flight proficiency/practical test: §§ 61.103(f), 61.107(b), and 61.109",
      template:
        "I certify that [First name, MI, Last name] has received the required training in accordance with §§ 61.107 and 61.109. I have determined they are prepared for the [name of] practical test.",
      requiredFields: ["name of"]
    ),

    // Commercial Pilot Endorsements
    FAAEndorsement(
      code: "A.34",
      title:
        "Commercial Pilot - Aeronautical knowledge test: §§ 61.35(a)(1), 61.123(c), and 61.125",
      template:
        "I certify that [First name, MI, Last name] has received the required training of § 61.125. I have determined that they are prepared for the [name of] knowledge test.",
      requiredFields: ["name of"]
    ),

    FAAEndorsement(
      code: "A.35",
      title:
        "Commercial Pilot - Flight proficiency/practical test: §§ 61.123(e), 61.127, and 61.129",
      template:
        "I certify that [First name, MI, Last name] has received the required training of §§ 61.127 and 61.129. I have determined that they are prepared for the [name of] practical test.",
      requiredFields: ["name of"]
    ),

    // Instrument Rating Endorsements
    FAAEndorsement(
      code: "A.38",
      title: "Instrument Rating - Aeronautical knowledge test: §§ 61.35(a)(1) and 61.65(a) and (b)",
      template:
        "I certify that [First name, MI, Last name] has received the required training of § 61.65(b). I have determined that they are prepared for the Instrument–[airplane, helicopter, or powered-lift] knowledge test.",
      requiredFields: ["airplane, helicopter, or powered-lift"]
    ),

    FAAEndorsement(
      code: "A.39",
      title: "Instrument Rating - Flight proficiency/practical test: § 61.65(a)(6)",
      template:
        "I certify that [First name, MI, Last name] has received the required training of § 61.65(c) and (d). I have determined they are prepared for the Instrument–[airplane, helicopter, or powered-lift] practical test.",
      requiredFields: ["airplane, helicopter, or powered-lift"]
    ),

    FAAEndorsement(
      code: "A.40",
      title: "Instrument Rating - Prerequisites for instrument practical tests: § 61.39(a)",
      template:
        "I certify that [First name, MI, Last name] has received and logged the required flight time/training of § 61.39(a) in preparation for the practical test within 2 calendar months preceding the date of the test and has satisfactory knowledge of the subject areas in which they were shown to be deficient by the FAA Airman Knowledge Test Report. I have determined they are prepared for the Instrument–[airplane, helicopter, or powered-lift] practical test.",
      requiredFields: ["airplane, helicopter, or powered-lift"]
    ),

    // Flight Instructor Endorsements
    FAAEndorsement(
      code: "A.41",
      title: "Flight Instructor - Fundamentals of instructing knowledge test: § 61.183(d)",
      template:
        "I certify that [First name, MI, Last name] has received the required fundamentals of instruction training of § 61.185(a)(1). I have determined that they are prepared for the Fundamentals of Instructing knowledge test.",
      requiredFields: []
    ),

    FAAEndorsement(
      code: "A.42",
      title: "Flight Instructor - Aeronautical knowledge test: § 61.183(f)",
      template:
        "I certify that [First name, MI, Last name] has received the required training of § 61.185(a)[(2) or (3) (as appropriate to the flight instructor rating sought)]. I have determined that they are prepared for the [name of] knowledge test.",
      requiredFields: ["name of"]
    ),

    FAAEndorsement(
      code: "A.43",
      title: "Flight Instructor - Ground and flight proficiency/practical test: § 61.183(g)",
      template:
        "I certify that [First name, MI, Last name] has received the required training of § 61.187(b). I have determined that they are prepared for the CFI – [aircraft category and class] practical test.",
      requiredFields: ["aircraft category and class"]
    ),

    // Additional Endorsements
    FAAEndorsement(
      code: "A.65",
      title: "Completion of a flight review: § 61.56(a) and (c)",
      template:
        "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has satisfactorily completed a flight review of § 61.56(a) on [date].",
      requiredFields: ["grade of pilot certificate", "certificate number", "date"]
    ),

    FAAEndorsement(
      code: "A.67",
      title: "Completion of an instrument proficiency check (IPC): § 61.57(d)",
      template:
        "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has satisfactorily completed the instrument proficiency check of § 61.57(d) in a [M/M] aircraft on [date].",
      requiredFields: ["grade of pilot certificate", "certificate number", "M/M", "date"]
    ),

    FAAEndorsement(
      code: "A.68",
      title: "To act as PIC in a complex airplane: § 61.31(e)",
      template:
        "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training of § 61.31(e) in a [M/M] complex airplane. I have determined that they are proficient in the operation and systems of a complex airplane.",
      requiredFields: ["grade of pilot certificate", "certificate number", "M/M"]
    ),

    FAAEndorsement(
      code: "A.69",
      title: "To act as PIC in a high-performance airplane: § 61.31(f)",
      template:
        "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training of § 61.31(f) in a [M/M] high-performance airplane. I have determined that they are proficient in the operation and systems of a high-performance airplane.",
      requiredFields: ["grade of pilot certificate", "certificate number", "M/M"]
    ),

    FAAEndorsement(
      code: "A.70",
      title: "To act as PIC in a pressurized aircraft: § 61.31(g)",
      template:
        "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training of § 61.31(g) in a [M/M] pressurized aircraft. I have determined that they are proficient in the operation and systems of a pressurized aircraft.",
      requiredFields: ["grade of pilot certificate", "certificate number", "M/M"]
    ),

    FAAEndorsement(
      code: "A.71",
      title: "To act as PIC in a tailwheel airplane: § 61.31(i)",
      template:
        "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training of § 61.31(i) in a [M/M] of tailwheel airplane. I have determined that they are proficient in the operation of a tailwheel airplane.",
      requiredFields: ["grade of pilot certificate", "certificate number", "M/M"]
    ),

    FAAEndorsement(
      code: "A.73",
      title: "Retesting after failure of a knowledge or practical test: § 61.49",
      template:
        "I certify that [First name, MI, Last name] has received the additional [flight and/or ground, as appropriate] training as required by § 61.49. I have determined that they are proficient to pass the [name of] knowledge/practical test.",
      requiredFields: ["flight and/or ground, as appropriate", "name of"]
    ),

    FAAEndorsement(
      code: "A.74",
      title: "Additional aircraft category or class rating (other than ATP): § 61.63(b) or (c)",
      template:
        "I certify that [First name, MI, Last name], [grade of pilot certificate], [certificate number], has received the required training for an additional [aircraft category/class rating]. I have determined that they are prepared for the [name of] practical test for the addition of a [name of specific aircraft category/class/type] type rating.",
      requiredFields: [
        "grade of pilot certificate", "certificate number", "aircraft category/class rating",
        "name of", "name of specific aircraft category/class/type",
      ]
    ),

    FAAEndorsement(
      code: "A.82",
      title: "Review of a home-study curriculum: § 61.35(a)(1)",
      template:
        "I certify I have reviewed the home-study curriculum of [First name, MI, Last name]. I have determined that they are prepared for the [name of] knowledge test.",
      requiredFields: ["name of"]
    ),

    // Note: This includes the most commonly used endorsements from the complete A.1-A.92 list
    // Additional endorsements can be added as needed for specific use cases
  ]
}

