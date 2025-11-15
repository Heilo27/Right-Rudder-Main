//
//  DefaultTemplatesReview.swift
//  Right Rudder
//
//  Review default checklist templates
//

import Foundation
import SwiftData

// MARK: - DefaultTemplates + Review

extension DefaultTemplates {
  // MARK: - Review Templates

  static let biAnnualFlightReview = ChecklistTemplate(
    name: "BiAnnual Flight Review",
    category: "Reviews",
    phase: "Flight Reviews",
    templateIdentifier: "default_bi_annual_flight_review",
    items: [
      // MARK: - Pre-Review Considerations
      ChecklistItem(
        title: "1.1 Pre-Review - Pilot Preparation",
        notes: "Pilot has reviewed current regulations, AIM, and appropriate handbooks", order: 0),
      ChecklistItem(
        title: "1.2 Pre-Review - Recent Experience",
        notes: "Verify pilot meets recent flight experience requirements per 14 CFR 61.57", order: 1
      ),
      ChecklistItem(
        title: "1.3 Pre-Review - Medical Certificate",
        notes: "Verify current medical certificate and any limitations", order: 2),
      ChecklistItem(
        title: "1.4 Pre-Review - Aircraft Selection",
        notes: "Select appropriate aircraft for pilot's certificate level and intended operations",
        order: 3),
      ChecklistItem(
        title: "1.5 Pre-Review - Weather Planning",
        notes: "Plan for appropriate weather conditions and have backup plans", order: 4),
      ChecklistItem(
        title: "1.6 Pre-Review - Personal Currency Program",
        notes: "Review pilot's personal currency program and proficiency goals", order: 5),

      // MARK: - Ground Review - Pilot Knowledge
      ChecklistItem(
        title: "2.1. Ground - Pilot Responsibilities",
        notes: "Review PIC authority and responsibilities per 14 CFR 91.3", order: 6),
      ChecklistItem(
        title: "2.2. Ground - Preflight Actions",
        notes: "Review preflight planning requirements per 14 CFR 91.103", order: 7),
      ChecklistItem(
        title: "2.3. Ground - Medical Facts",
        notes: "Review medical factors affecting flight safety (AIM Chapter 8)", order: 8),
      ChecklistItem(
        title: "2.4. Ground - Recent Experience",
        notes: "Verify compliance with recent flight experience requirements", order: 9),
      ChecklistItem(
        title: "2.5. Ground - Currency Requirements",
        notes: "Review currency requirements for privileges exercised", order: 10),

      // MARK: - Ground Review - Aircraft Systems
      ChecklistItem(
        title: "3.1. Ground - Fuel Requirements",
        notes: "Review fuel requirements and planning per 14 CFR 91.167", order: 11),
      ChecklistItem(
        title: "3.2. Ground - Equipment Requirements",
        notes: "Review required instruments and equipment per 14 CFR 91.205", order: 12),
      ChecklistItem(
        title: "3.3. Ground - Navigation Equipment",
        notes: "Review VOR equipment check requirements per 14 CFR 91.171", order: 13),
      ChecklistItem(
        title: "3.4. Ground - Communication Equipment",
        notes: "Review two-way radio communication requirements per 14 CFR 91.183", order: 14),
      ChecklistItem(
        title: "3.5. Ground - Emergency Equipment",
        notes: "Review ELT requirements per 14 CFR 91.207 and emergency procedures", order: 15),
      ChecklistItem(
        title: "3.6. Ground - Aircraft Lights",
        notes: "Review aircraft lighting requirements per 14 CFR 91.209", order: 16),
      ChecklistItem(
        title: "3.7. Ground - Inoperative Equipment",
        notes: "Review procedures for inoperative instruments per 14 CFR 91.213", order: 17),
      ChecklistItem(
        title: "3.8. Ground - Altimeter Tests",
        notes: "Review altimeter and pitot-static system test requirements per 14 CFR 91.411",
        order: 18),
      ChecklistItem(
        title: "3.9. Ground - Transponder Tests",
        notes: "Review ATC transponder test requirements per 14 CFR 91.413", order: 19),
      ChecklistItem(
        title: "3.10. Ground - Malfunction Reports",
        notes: "Review malfunction reporting requirements per 14 CFR 91.187", order: 20),

      // MARK: - Ground Review - Environment and Procedures
      ChecklistItem(
        title: "4.1. Ground - ATC Instructions",
        notes: "Review compliance with ATC instructions per 14 CFR 91.123", order: 21),
      ChecklistItem(
        title: "4.2. Ground - Flight Plans",
        notes: "Review IFR flight plan requirements per 14 CFR 91.169", order: 22),
      ChecklistItem(
        title: "4.3. Ground - ATC Clearances",
        notes: "Review ATC clearance and flight plan requirements per 14 CFR 91.173", order: 23),
      ChecklistItem(
        title: "4.4. Ground - IFR Operations",
        notes: "Review IFR takeoff and landing requirements per 14 CFR 91.175", order: 24),
      ChecklistItem(
        title: "4.5. Ground - Minimum IFR Altitudes",
        notes: "Review minimum IFR altitude requirements per 14 CFR 91.177", order: 25),
      ChecklistItem(
        title: "4.6. Ground - IFR Cruising Altitudes",
        notes: "Review IFR cruising altitude requirements per 14 CFR 91.179", order: 26),
      ChecklistItem(
        title: "4.7. Ground - Course Requirements",
        notes: "Review course to be flown requirements per 14 CFR 91.181", order: 27),
      ChecklistItem(
        title: "4.8. Ground - Navigation Aids",
        notes: "Review navigation aid procedures and limitations (AIM Chapter 1)", order: 28),
      ChecklistItem(
        title: "4.9. Ground - ATC Procedures",
        notes: "Review ATC procedures and communications (AIM Chapter 4)", order: 29),
      ChecklistItem(
        title: "4.10. Ground - Air Traffic Procedures",
        notes: "Review air traffic procedures (AIM Chapter 5)", order: 30),

      // MARK: - Ground Review - External Pressures and Emergencies
      ChecklistItem(
        title: "5.1. Ground - Communication Failures",
        notes: "Review IFR two-way radio communication failure procedures per 14 CFR 91.185",
        order: 31),
      ChecklistItem(
        title: "5.2. Ground - Emergency Procedures",
        notes: "Review emergency procedures (AIM Chapter 6)", order: 32),
      ChecklistItem(
        title: "5.3. Ground - National Security",
        notes: "Review national security and interception procedures (AIM Chapter 5, Section 6)",
        order: 33),
      ChecklistItem(
        title: "5.4. Ground - Risk Management",
        notes: "Review risk management and aeronautical decision making", order: 34),
      ChecklistItem(
        title: "5.5. Ground - Personal Minimums",
        notes: "Review and update personal minimums and safety margins", order: 35),

      // MARK: - Flight Activities - Preflight
      ChecklistItem(
        title: "1.1. Flight - Preflight Preparation",
        notes: "Demonstrate proper preflight planning and weather analysis", order: 36),
      ChecklistItem(
        title: "1.2. Flight - Weather Information",
        notes: "Obtain and interpret weather information for flight", order: 37),
      ChecklistItem(
        title: "1.3. Flight - Cross-Country Planning",
        notes: "Demonstrate cross-country flight planning skills", order: 38),
      ChecklistItem(
        title: "1.4. Flight - Preflight Procedures",
        notes: "Demonstrate proper preflight inspection procedures", order: 39),
      ChecklistItem(
        title: "1.5. Flight - Aircraft Systems",
        notes: "Demonstrate knowledge of aircraft systems and limitations", order: 40),
      ChecklistItem(
        title: "1.6. Flight - Flight Instruments",
        notes: "Demonstrate knowledge of flight instruments and navigation equipment", order: 41),
      ChecklistItem(
        title: "1.7. Flight - Cockpit Check", notes: "Demonstrate proper cockpit check procedures",
        order: 42),

      // MARK: - Flight Activities - Ground Operations
      ChecklistItem(
        title: "2.1. Flight - ATC Clearances", notes: "Demonstrate proper ATC clearance procedures",
        order: 43),
      ChecklistItem(
        title: "2.2. Flight - Departure Procedures",
        notes: "Demonstrate proper departure procedures and clearances", order: 44),
      ChecklistItem(
        title: "2.3. Flight - Taxi Operations",
        notes: "Demonstrate safe taxi operations and runway safety", order: 45),
      ChecklistItem(
        title: "2.4. Flight - Runway Incursion Avoidance",
        notes: "Demonstrate runway incursion avoidance procedures", order: 46),
      ChecklistItem(
        title: "2.5. Flight - Pre-Takeoff Checks",
        notes: "Demonstrate proper pre-takeoff checks and procedures", order: 47),

      // MARK: - Flight Activities - Takeoff and Departure
      ChecklistItem(
        title: "3.1. Flight - Normal Takeoff", notes: "Demonstrate normal takeoff procedures",
        order: 48),
      ChecklistItem(
        title: "3.2. Flight - Short Field Takeoff",
        notes: "Demonstrate short field takeoff procedures", order: 49),
      ChecklistItem(
        title: "3.3. Flight - Soft Field Takeoff",
        notes: "Demonstrate soft field takeoff procedures", order: 50),
      ChecklistItem(
        title: "3.4. Flight - Crosswind Takeoff", notes: "Demonstrate crosswind takeoff procedures",
        order: 51),
      ChecklistItem(
        title: "3.5. Flight - Engine Failure on Takeoff",
        notes: "Demonstrate engine failure on takeoff procedures", order: 52),
      ChecklistItem(
        title: "3.6. Flight - Rejected Takeoff", notes: "Demonstrate rejected takeoff procedures",
        order: 53),

      // MARK: - Flight Activities - En Route Operations
      ChecklistItem(
        title: "4.1. Flight - Climb Procedures",
        notes: "Demonstrate proper climb procedures and performance", order: 54),
      ChecklistItem(
        title: "4.2. Flight - Cruise Operations",
        notes: "Demonstrate cruise operations and performance", order: 55),
      ChecklistItem(
        title: "4.3. Flight - Navigation", notes: "Demonstrate navigation skills and procedures",
        order: 56),
      ChecklistItem(
        title: "4.4. Flight - Communication", notes: "Demonstrate proper communication procedures",
        order: 57),
      ChecklistItem(
        title: "4.5. Flight - Weather Avoidance",
        notes: "Demonstrate weather avoidance and decision making", order: 58),
      ChecklistItem(
        title: "4.6. Flight - Fuel Management", notes: "Demonstrate fuel management and planning",
        order: 59),
      ChecklistItem(
        title: "4.7. Flight - Holding Procedures",
        notes: "Demonstrate holding procedures (if applicable)", order: 60),

      // MARK: - Flight Activities - Approach and Landing
      ChecklistItem(
        title: "5.1. Flight - Approach Planning",
        notes: "Demonstrate approach planning and briefing", order: 61),
      ChecklistItem(
        title: "5.2. Flight - Traffic Pattern",
        notes: "Demonstrate proper traffic pattern procedures", order: 62),
      ChecklistItem(
        title: "5.3. Flight - Normal Landing", notes: "Demonstrate normal landing procedures",
        order: 63),
      ChecklistItem(
        title: "5.4. Flight - Short Field Landing",
        notes: "Demonstrate short field landing procedures", order: 64),
      ChecklistItem(
        title: "5.5. Flight - Soft Field Landing",
        notes: "Demonstrate soft field landing procedures", order: 65),
      ChecklistItem(
        title: "5.6. Flight - Crosswind Landing", notes: "Demonstrate crosswind landing procedures",
        order: 66),
      ChecklistItem(
        title: "5.7. Flight - Go-Around Procedures", notes: "Demonstrate go-around procedures",
        order: 67),
      ChecklistItem(
        title: "5.8. Flight - Stabilized Approaches",
        notes: "Demonstrate stabilized approach procedures", order: 68),

      // MARK: - Flight Activities - Emergency Operations
      ChecklistItem(
        title: "6.1. Flight - Emergency Procedures",
        notes: "Demonstrate emergency procedures knowledge", order: 69),
      ChecklistItem(
        title: "6.2. Flight - Communication Failures",
        notes: "Demonstrate communication failure procedures", order: 70),
      ChecklistItem(
        title: "6.3. Flight - Engine Failures", notes: "Demonstrate engine failure procedures",
        order: 71),
      ChecklistItem(
        title: "6.4. Flight - Electrical Failures",
        notes: "Demonstrate electrical failure procedures", order: 72),
      ChecklistItem(
        title: "6.5. Flight - Instrument Failures",
        notes: "Demonstrate instrument failure procedures", order: 73),
      ChecklistItem(
        title: "6.6. Flight - Automation Failures",
        notes: "Demonstrate automation failure and manual flight procedures", order: 74),
      ChecklistItem(
        title: "6.7. Flight - Emergency Landings",
        notes: "Demonstrate emergency landing procedures", order: 75),

      // MARK: - Flight Activities - Advanced Maneuvers
      ChecklistItem(
        title: "7.1. Flight - Steep Turns", notes: "Demonstrate steep turn procedures", order: 76),
      ChecklistItem(
        title: "7.2. Flight - Slow Flight", notes: "Demonstrate slow flight procedures", order: 77),
      ChecklistItem(
        title: "7.3. Flight - Stalls", notes: "Demonstrate stall recognition and recovery",
        order: 78),
      ChecklistItem(
        title: "7.4. Flight - Spins",
        notes: "Demonstrate spin recognition and recovery (if applicable)", order: 79),
      ChecklistItem(
        title: "7.5. Flight - Unusual Attitudes", notes: "Demonstrate unusual attitude recovery",
        order: 80),
      ChecklistItem(
        title: "7.6. Flight - Ground Reference Maneuvers",
        notes: "Demonstrate ground reference maneuvers", order: 81),

      // MARK: - Post-Flight Activities
      ChecklistItem(
        title: "1.1. Post-Flight - After Landing",
        notes: "Demonstrate proper after landing procedures", order: 82),
      ChecklistItem(
        title: "1.2. Post-Flight - Taxi to Parking",
        notes: "Demonstrate safe taxi to parking procedures", order: 83),
      ChecklistItem(
        title: "1.3. Post-Flight - Securing Aircraft",
        notes: "Demonstrate proper aircraft securing procedures", order: 84),
      ChecklistItem(
        title: "1.4. Post-Flight - Equipment Check",
        notes: "Demonstrate post-flight equipment check", order: 85),

      // MARK: - Post-Review Considerations
      ChecklistItem(
        title: "2.1. Post-Review - Performance Assessment",
        notes: "Assess pilot performance and identify areas for improvement", order: 86),
      ChecklistItem(
        title: "2.2. Post-Review - Strengths Identified",
        notes: "Identify pilot strengths and areas of proficiency", order: 87),
      ChecklistItem(
        title: "2.3. Post-Review - Recommendations",
        notes: "Provide recommendations for continued proficiency", order: 88),
      ChecklistItem(
        title: "2.4. Post-Review - Personal Currency Program",
        notes: "Update personal currency program and goals", order: 89),
      ChecklistItem(
        title: "2.5. Post-Review - Training Plan",
        notes: "Develop or update training plan for continued proficiency", order: 90),
      ChecklistItem(
        title: "2.6. Post-Review - Safety Culture",
        notes: "Discuss safety culture and continuous improvement", order: 91),
      ChecklistItem(
        title: "2.7. Post-Review - Logbook Entry",
        notes: "Make appropriate logbook entry for flight review completion", order: 92),
      ChecklistItem(
        title: "2.8. Post-Review - Endorsement",
        notes:
          "I certify that [Pilot's Full Name], [Pilot Certificate, e.g., Private Pilot], [Certificate Number], has satisfactorily completed the flight review required in §61.56(a) on [Date].",
        order: 93),
    ]
  )

  static let instrumentProficiencyCheck = ChecklistTemplate(
    name: "Instrument Proficiency Check",
    category: "Reviews",
    phase: "Flight Reviews",
    templateIdentifier: "default_instrument_proficiency_check",
    items: [
      // MARK: - Step 1: Preparation
      ChecklistItem(
        title: "1.1 Preparation - Expectations",
        notes: "Plan at least 90 minutes ground time and 2 hours flight time minimum", order: 0),
      ChecklistItem(
        title: "1.2 Preparation - Regulatory Review",
        notes:
          "Pilot reviewed: Instrument Procedures Handbook, Instrument Flying Handbook, Aviation Weather and Weather Services",
        order: 1),
      ChecklistItem(
        title: "1.3 Preparation - Documents Brought",
        notes: "Pilot brought: PTS, FAR/AIM, charts, A/FD, POH/AFM for aircraft", order: 2),
      ChecklistItem(
        title: "1.4 Preparation - IPC Prep Course",
        notes: "Pilot completed IPC Prep Course at faasafety.gov", order: 3),
      ChecklistItem(
        title: "1.5 Preparation - Cross-Country Assignment",
        notes: "Assigned representative IFR cross-country route with published approaches", order: 4
      ),
      ChecklistItem(
        title: "1.6 Preparation - Weather Briefing",
        notes: "Standard weather briefing obtained for assigned route and date", order: 5),

      // MARK: - Step 2: Ground Review - Preflight
      ChecklistItem(
        title: "2.1 Ground Review - Weather Analysis",
        notes: "METARs, TAFs, winds aloft, radar, freezing levels, personal minimums compliance",
        order: 6),
      ChecklistItem(
        title: "2.2 Ground Review - Flight Planning",
        notes: "Route selection, alternates, fuel planning, terrain avoidance, passenger planning",
        order: 7),
      ChecklistItem(
        title: "2.3 Ground Review - Aircraft Systems",
        notes:
          "Pitot-static, gyroscopic instruments, magnetic compass, electrical, navigation, communication",
        order: 8),
      ChecklistItem(
        title: "2.4 Ground Review - Performance",
        notes: "Takeoff distance, climb performance, cruise performance, landing distance", order: 9
      ),
      ChecklistItem(
        title: "2.5 Ground Review - Taxi/Takeoff/Departure",
        notes:
          "Taxi procedures, takeoff procedures, departure procedures, obstacle clearance, communication",
        order: 10),
      ChecklistItem(
        title: "2.6 Ground Review - En Route",
        notes:
          "Navigation procedures, altitude selection, airspace compliance, weather avoidance, fuel management",
        order: 11),
      ChecklistItem(
        title: "2.7 Ground Review - Arrival/Approach",
        notes:
          "Arrival procedures, approach briefing, minimums, missed approach procedures, decision points",
        order: 12),
      ChecklistItem(
        title: "2.8 Ground Review - Missed Approach",
        notes:
          "Missed approach procedures, climb procedures, navigation after missed, communication",
        order: 13),

      // MARK: - Step 3: Flight Activities - Aircraft Control
      ChecklistItem(
        title: "3.1 Flight - Basic Attitude Instrument Flying",
        notes: "Straight and level flight, standard rate turns, climbs and descents", order: 14),
      ChecklistItem(
        title: "3.2 Flight - Unusual Attitudes",
        notes: "Recovery from unusual attitudes, partial panel operations", order: 15),
      ChecklistItem(
        title: "3.3 Flight - Systems Knowledge",
        notes: "Pitot-static system, gyroscopic instruments, magnetic compass, electrical system",
        order: 16),
      ChecklistItem(
        title: "3.4 Flight - Navigation Equipment",
        notes: "Navigation equipment operation, autopilot systems, communication procedures",
        order: 17),
      ChecklistItem(
        title: "3.5 Flight - Aeronautical Decision Making",
        notes: "Weather decision making, risk management, emergency procedures", order: 18),

      // MARK: - Step 4: Post-Flight Debriefing
      ChecklistItem(
        title: "4.1 Post-Flight - Performance Review",
        notes: "Review pilot performance, identify areas for improvement", order: 19),
      ChecklistItem(
        title: "4.2 Post-Flight - Strengths Identified",
        notes: "Identify pilot strengths and areas of proficiency", order: 20),
      ChecklistItem(
        title: "4.3 Post-Flight - Recommendations",
        notes: "Provide recommendations for continued proficiency", order: 21),
      ChecklistItem(
        title: "4.4 Post-Flight - Next Steps", notes: "Discuss next steps and practice plan",
        order: 22),

      // MARK: - Step 5: Instrument Flying Practice Plan
      ChecklistItem(
        title: "5.1 Practice Plan - Personal Minimums",
        notes: "Develop weather minimums, wind limits, performance limits", order: 23),
      ChecklistItem(
        title: "5.2 Practice Plan - Proficiency Goals",
        notes: "Set monthly IFR hours, approaches, annual goals, cross-country flights", order: 24),
      ChecklistItem(
        title: "5.3 Practice Plan - Training Plan",
        notes: "Establish goals, timeline, instructor qualifications, additional training",
        order: 25),

      // MARK: - 3-P Risk Management Process
      ChecklistItem(
        title: "6.1 Risk Management - Perceive Hazards",
        notes: "Identify pilot, aircraft, environment, and external pressure factors", order: 26),
      ChecklistItem(
        title: "6.2 Risk Management - Process Risk",
        notes: "Evaluate consequences, alternatives, reality, external pressures", order: 27),
      ChecklistItem(
        title: "6.3 Risk Management - Perform",
        notes: "Mitigate or eliminate risks, make risk management decisions", order: 28),

      // MARK: - Weather Analysis Process
      ChecklistItem(
        title: "7.1 Weather - Big Picture Overview",
        notes: "Review overall weather pattern and trends", order: 29),
      ChecklistItem(
        title: "7.2 Weather - TAFs and METARs",
        notes: "Analyze terminal aerodrome forecasts and meteorological reports", order: 30),
      ChecklistItem(
        title: "7.3 Weather - Winds and Temps Aloft",
        notes: "Review winds and temperatures aloft for route planning", order: 31),
      ChecklistItem(
        title: "7.4 Weather - Radar and Freezing Levels",
        notes: "Check radar returns and freezing level information", order: 32),
      ChecklistItem(
        title: "7.5 Weather - Personal Minimums Compliance",
        notes: "Verify weather meets established personal minimums", order: 33),
      ChecklistItem(
        title: "7.6 Weather - Flight Service Briefing",
        notes: "Obtain standard briefing from Flight Service or DUATS", order: 34),
      ChecklistItem(
        title: "7.7 Weather - IFR Flight Plan",
        notes: "File IFR flight plan and verify information", order: 35),

      // MARK: - Regional/Seasonal Considerations
      ChecklistItem(
        title: "8.1 Regional - Topography",
        notes: "Consider mountains, bodies of water, and other terrain features", order: 36),
      ChecklistItem(
        title: "8.2 Regional - Seasonal Weather",
        notes: "Review seasonal weather characteristics and local knowledge", order: 37),
      ChecklistItem(
        title: "8.3 Regional - Local Factors",
        notes: "Apply local knowledge and regional weather patterns", order: 38),

      // MARK: - Instrument Training and Proficiency Plan
      ChecklistItem(
        title: "9.1 Training - Certificate Level",
        notes: "Document certificate level, ratings, and endorsements", order: 39),
      ChecklistItem(
        title: "9.2 Training - Proficiency Goals",
        notes: "Set goals for lowering personal minimums and IFR/IMC frequency", order: 40),
      ChecklistItem(
        title: "9.3 Training - Aeronautical Plan",
        notes: "Develop comprehensive aeronautical training plan", order: 41),

      // MARK: - Completion and Endorsement
      ChecklistItem(
        title: "10.1 Completion - Overall Assessment",
        notes: "Complete overall assessment of pilot's instrument proficiency", order: 42),
      ChecklistItem(
        title: "10.2 Completion - Endorsement",
        notes:
          "I certify that [First name, MI, Last name, grade of pilot certificate, certificate number], has satisfactorily completed the instrument proficiency check of § 61.57(d) in a [list make and model of aircraft] on [date].",
        order: 43),
      ChecklistItem(
        title: "10.3 Completion - Logbook Entry",
        notes: "Make appropriate logbook entry for IPC completion", order: 44),
    ]
  )

}
