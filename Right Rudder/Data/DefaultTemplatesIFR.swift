//
//  DefaultTemplatesIFR.swift
//  Right Rudder
//
//  IFR (Instrument Flight Rules) default checklist templates
//

import Foundation
import SwiftData

// MARK: - DefaultTemplates + IFR

extension DefaultTemplates {
  // MARK: - Instrument Rating Templates

  static let i1L1PreflightAndBasicInstrumentControl = ChecklistTemplate(
    name: "I1-L1: Pre-flight and Basic Instrument Control",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i1_l1_preflight_and_basic_instrument_control",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Review & explain the PAVE checklist with emphasis on environmental conditions",
        order: 0),
      ChecklistItem(
        title: "2. Positive Exchange of Flight Controls",
        notes: "Understands and uses the positive three-step exchange of controls", order: 1),
      ChecklistItem(
        title: "3. Collision Avoidance Procedures",
        notes:
          "Clear understanding of responsibilities & procedures for visual & Instrument reference",
        order: 2),
      ChecklistItem(
        title: "4. Using the Checklists",
        notes: "Exercises an effective flow and check process for procedures", order: 3),
      ChecklistItem(
        title: "5. Preflight for Instrument Flight",
        notes:
          "Perform aircraft inspection with emphasis on systems associated with instrument flight",
        order: 4),
      ChecklistItem(
        title: "6. Checking the Instruments on the Ground",
        notes:
          "Systematically checks instruments & systems for proper indications during ground operations",
        order: 5),
      ChecklistItem(
        title: "7. Runway Incursion Avoidance",
        notes: "Uses airport diagram, notes taxi clearances, requests clarification as needed",
        order: 6),
      ChecklistItem(
        title: "8. Normal Takeoff and Climb",
        notes:
          "Completes pre-takeoff checks, checks HI on runway, notes airspeed indications on takeoff roll",
        order: 7),
      ChecklistItem(
        title: "9. Constant Airspeed Climbs",
        notes:
          "Smooth transition level to climb, maintains airspeed ±15kts, heading ±15°, bank ±10°",
        order: 8),
      ChecklistItem(
        title: "10. Level-Off from Climb",
        notes: "Smooth transition climb to level ±100 ft, accelerates to cruise airspeed, trims",
        order: 9),
      ChecklistItem(
        title: "11. Straight and Level",
        notes: "Maintains airspeed ±15kts, heading ±15°, altitude ±150 ft", order: 10),
      ChecklistItem(
        title: "12. Level Standard Rate Turns to Heading",
        notes: "Maintains ±15kts, target bank angle ±5°, stops on assigned heading ±10°, ±150 ft",
        order: 11),
      ChecklistItem(
        title: "13. Constant Airspeed Descents",
        notes:
          "Smooth transition level to descent, maintains airspeed ±15kts, heading ±15°, bank ±10°",
        order: 12),
      ChecklistItem(
        title: "14. Level-Off from Descent",
        notes: "Smooth transition descent to level ±100 ft, returns to cruise airspeed, trims",
        order: 13),
      ChecklistItem(
        title: "15. Normal Approach and Landing",
        notes: "Completes pre-landing checks, smooth landing with appropriate crosswind correction",
        order: 14),
      ChecklistItem(
        title: "16. After landing, Taxi, Parking",
        notes: "Exercises good practices to avoid runway incursions", order: 15),
      ChecklistItem(
        title: "17. Postflight Procedures",
        notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies",
        order: 16),
    ]
  )

  static let i1L2ExpandingInstrumentSkills = ChecklistTemplate(
    name: "I1-L2: Expanding Instrument Skills",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i1_l2_expanding_instrument_skills",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes:
          "Employs PAVE checklist in identifying & mitigating flight risks, briefs the weather",
        order: 0),
      ChecklistItem(
        title: "2. Controlled Flight into Terrain Awareness",
        notes: "Briefs local area vertical obstructions & charted maximum elevation figures",
        order: 1),
      ChecklistItem(
        title: "3. Pre-takeoff Calculations",
        notes: "Briefs Weight & Balance and Takeoff and Landing performance data for conditions",
        order: 2),
      ChecklistItem(
        title: "4. Preflight for Instrument Flight",
        notes:
          "Complete aircraft inspection with emphasis on systems associated with instrument flight",
        order: 3),
      ChecklistItem(
        title: "5. Checking the Instruments on the ground",
        notes:
          "Systematically checks instruments & systems for proper indications during ground operations",
        order: 4),
      ChecklistItem(
        title: "6. Runway Incursion Avoidance",
        notes: "Uses airport diagram, notes taxi clearances, requests clarification as needed",
        order: 5),
      ChecklistItem(
        title: "7. Constant Rate Climbs",
        notes: "Smooth transition level to climb, rate ±200 fpm, heading ±15°, levels ±100 ft",
        order: 6),
      ChecklistItem(
        title: "8. Constant Rate Descents",
        notes: "Smooth transition level to descent, rate ±200 fpm, heading ±15°", order: 7),
      ChecklistItem(
        title: "9. Constant Rate Climbs and Descents with Constant Airspeed",
        notes: "Notes pitch & power, rate ±200 fpm, airspeed ±15kts, heading ±15°, levels ±100 ft",
        order: 8),
      ChecklistItem(
        title: "10. Level Standard Rate Turns to Headings",
        notes: "Up to 180° of turn, airspeed ±15kts, heading ±10°, alt ±150 ft, bank angle ±5°",
        order: 9),
      ChecklistItem(
        title: "11. Climbs and Descents While Turning to a Heading",
        notes: "Maintains airspeed ±15kts, heading ±15°, bank ±10°, levels ±100 ft", order: 10),
      ChecklistItem(
        title: "12. Straight and Level While Changing Airspeed",
        notes: "Maintains ±150 ft, heading ±15°, airspeed ±10kts, correct use of trim", order: 11),
      ChecklistItem(
        title: "13. After landing, Taxi, Parking",
        notes: "Exercises good practices to avoid runway incursions", order: 12),
      ChecklistItem(
        title: "14. Postflight Procedures",
        notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies",
        order: 13),
    ]
  )

  static let i1L3UsingTheMagneticCompass = ChecklistTemplate(
    name: "I1-L3: Using the Magnetic Compass",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i1_l3_using_the_magnetic_compass",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes:
          "Employs PAVE checklist, briefs weight & balance, takeoff & landing performance, & weather",
        order: 0),
      ChecklistItem(
        title: "2. Controlled Flight into Terrain Avoidance",
        notes: "Briefs local area minimum safe altitudes for IR operations", order: 1),
      ChecklistItem(
        title: "3. Automation Management",
        notes:
          "Review installed technically advanced systems & application for situation awareness & failures",
        order: 2),
      ChecklistItem(
        title: "4. Task Management",
        notes:
          "Review priorities regarding aircraft control, equipment failures, navigation & communications",
        order: 3),
      ChecklistItem(
        title: "5. Preflight for Instrument Flight",
        notes:
          "Complete aircraft inspection with emphasis on systems associated with instrument flight",
        order: 4),
      ChecklistItem(
        title: "6. Checking the Instruments on the Ground",
        notes:
          "Systematically checks instruments & systems for proper indications during ground operations",
        order: 5),
      ChecklistItem(
        title: "7. Runway Incursion Avoidance",
        notes: "Uses airport diagram, notes taxi clearances, requests clarification as needed",
        order: 6),
      ChecklistItem(
        title: "8. Constant Rate Climbs and Descents with Constant Airspeed",
        notes: "Notes pitch & power, rate ±200 fpm, airspeed ±10kts, heading ±10°, levels ±100 ft",
        order: 7),
      ChecklistItem(
        title: "9. Level Standard Rate Turns to Headings",
        notes: "Up to 180° of turn, alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±10°",
        order: 8),
      ChecklistItem(
        title: "10. Climbs and Descents While Turning to a Heading",
        notes: "Maintains airspeed ± 10kts, heading ±15°, bank ±10°, heading ±10°, levels ± 100 ft",
        order: 9),
      ChecklistItem(
        title: "11. Straight and Level While Changing Airspeed",
        notes: "Maintains ±150 ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 10),
      ChecklistItem(
        title: "12. Turns to Headings Using Magnetic Compass",
        notes: "Alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±20°", order: 11),
      ChecklistItem(
        title: "13. Timed Turns to Headings Using Magnetic Compass",
        notes: "Alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±20°", order: 12),
      ChecklistItem(
        title: "14. After Landing, Taxi, Parking",
        notes: "Exercises good practices to avoid runway incursions", order: 13),
      ChecklistItem(
        title: "15. Postflight Procedures",
        notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies",
        order: 14),
    ]
  )

  static let i1L4IFRFlightPlansAndClearances = ChecklistTemplate(
    name: "I1-L4: IFR Flight Plans and Clearances",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i1_l4_ifr_flight_plans_and_clearances",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes:
          "Employs PAVE checklist, briefs weight & balance, takeoff & landing performance, & weather",
        order: 0),
      ChecklistItem(
        title: "2. Enroute Charts", notes: "Review chart symbology for planned route", order: 1),
      ChecklistItem(
        title: "3. Flight Plan",
        notes: "Using route provided, prepares an IFR flight plan to a nearby airport", order: 2),
      ChecklistItem(
        title: "4. Situational Awareness",
        notes:
          "Review planned route for leg courses, distances, and ETE for an in-flight mental picture",
        order: 3),
      ChecklistItem(
        title: "5. Preflight for Instrument Flight",
        notes:
          "Complete aircraft inspection with emphasis on systems associated with instrument flight",
        order: 4),
      ChecklistItem(
        title: "6. Checking the Instruments on the Ground",
        notes:
          "Systematically checks instruments & systems for proper indications during ground operations",
        order: 5),
      ChecklistItem(
        title: "7. Copy and Read Back IFR Clearance",
        notes:
          "Simulated: requests clearance, copies simple clearance & correctly reads back clearance",
        order: 6),
      ChecklistItem(
        title: "8. Flying an \"ATC\" Route, Vectors and Altitudes",
        notes:
          "Conforms to assigned route, vectors, and altitudes in clearance or as assigned by \"ATC\"",
        order: 7),
      ChecklistItem(
        title: "9. Constant Rate Climbs and Descents with Constant Airspeed",
        notes:
          "Notes pitch & power, rate ± 200 fpm, airspeed ± 10kts, heading ±10°, levels ± 100 ft",
        order: 8),
      ChecklistItem(
        title: "10. Level Standard Rate Turns to Headings",
        notes: "Up to 180° of turn, alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±10°",
        order: 9),
      ChecklistItem(
        title: "11. Climbs and Descents While Turning to a Heading",
        notes: "Maintains airspeed ± 10kts, heading ±15°, bank ±10°, heading ±10°, levels ± 100 ft",
        order: 10),
      ChecklistItem(
        title: "12. Straight and Level While Changing Airspeed",
        notes: "Maintains ±150 ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 11),
      ChecklistItem(
        title: "13. Turns to Headings Using Magnetic Compass",
        notes: "Alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±20°", order: 12),
      ChecklistItem(
        title: "14. Timed Turns to Heading Using Magnetic Compass",
        notes: "Alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±20°", order: 13),
      ChecklistItem(
        title: "15. After landing, Taxi, Parking",
        notes: "Exercises good practices to avoid runway incursions", order: 14),
      ChecklistItem(
        title: "16. Postflight Procedures",
        notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies",
        order: 15),
    ]
  )

  static let i1L5PrimaryFlightInstrumentDisplayFailure = ChecklistTemplate(
    name: "I1-L5: Primary Flight Instrument/Display Failure",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i1_l5_primary_flight_instrument_display_failure",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (W&B, Performance, Weather), reviews instrument systems",
        order: 0),
      ChecklistItem(
        title: "2. Situational Awareness",
        notes: "Review aircraft control using standby or partial-panel instruments", order: 1),
      ChecklistItem(
        title: "3. Aeronautical Decision Making",
        notes:
          "Review managing in-flight risk (CARE ) & decisions regarding primary instrument failure",
        order: 2),
      ChecklistItem(
        title: "4. Automation Management",
        notes: "Review autopilot use in the event of primary instruments/display failure", order: 3),
      ChecklistItem(
        title: "5. Before Instrument Flight Ground Operations",
        notes: "Complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 4),
      ChecklistItem(
        title: "6. Copy and Read Back IFR Clearance",
        notes:
          "Simulated: requests clearance, copies simple clearance & correctly reads-back clearance",
        order: 5),
      ChecklistItem(
        title: "7. Straight and Level Using Standby/Partial-Panel Instruments",
        notes: "Maintains ±150 ft, heading ±15°, airspeed ±10kts", order: 6),
      ChecklistItem(
        title: "8. Standard Rate Turns to Headings Standby/Partial-Panel Instruments",
        notes: "Up to 180° of turn, alt ±150 ft, airspeed ± 10kts, heading ±15°", order: 7),
      ChecklistItem(
        title: "9. Constant Airspeed Climbs Standby/Partial-Panel Instruments",
        notes: "Airspeed ± 15kts, heading ±15°, levels ±200 ft", order: 8),
      ChecklistItem(
        title: "10. Constant Airspeed Descents Standby/Partial-Panel Instruments",
        notes: "Airspeed ± 15kts, heading ±15°, levels ±200 ft", order: 9),
      ChecklistItem(
        title: "11. Unusual Attitudes Recovery (Nose High/Low) Full Panel",
        notes:
          "Returns to stabilized level flight within operating limitations or not entering unsafe conditions",
        order: 10),
      ChecklistItem(
        title: "12. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel",
        notes:
          "Returns to stabilized level flight within operating limitations or not entering unsafe conditions",
        order: 11),
      ChecklistItem(
        title: "13. Straight and Level While Changing Airspeed",
        notes: "Maintains ±150 ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 12),
      ChecklistItem(
        title: "14. Timed Turns to Heading Using Magnetic Compass",
        notes: "Alt ±150 ft, airspeed ±10kts, bank angle ±5°, heading ±20°", order: 13),
      ChecklistItem(
        title: "15. After landing, Taxi, Parking",
        notes: "Exercises good practices to avoid runway incursions", order: 14),
      ChecklistItem(
        title: "16. Postflight Procedures",
        notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies",
        order: 15),
    ]
  )

  static let i1L6ReviewOfInstrumentControlAndProgressCheck = ChecklistTemplate(
    name: "I1-L6: Review of Instrument Control and Progress Check",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i1_l6_review_of_instrument_control_and_progress_check",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Weather)", order: 0),
      ChecklistItem(
        title: "2. Situational Awareness and Controlled Flight into Terrain Awareness",
        notes:
          "Briefs ways to maintain situational awareness & avoid terrain in instrument conditions",
        order: 1),
      ChecklistItem(
        title: "3. Positive Exchange of Flight Controls",
        notes: "Briefs the positive three-step exchange of controls", order: 2),
      ChecklistItem(
        title: "4. Automation Management",
        notes: "Briefs autopilot use in the event of primary instruments/display failures", order: 3
      ),
      ChecklistItem(
        title: "5. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 4),
      ChecklistItem(
        title: "6. Copy and Read-back IFR Clearance",
        notes:
          "Simulated: requests clearance, copies simple clearance & correctly reads-back clearance",
        order: 5),
      ChecklistItem(
        title: "7. Using the Checklists",
        notes: "Exercises an effective flow and check process for procedures", order: 6),
      ChecklistItem(
        title: "8. Collision Avoidance Procedures",
        notes:
          "Clear understanding of responsibilities & procedures for visual & Instrument reference",
        order: 7),
      ChecklistItem(
        title: "9. Constant Rate Climbs and Descents with Constant Airspeed",
        notes: "Maintains rate ±150 fpm, airspeed ±10 kts, heading ±10°, levels ±100 ft", order: 8),
      ChecklistItem(
        title: "10. Straight and Level While Changing Airspeed",
        notes: "Maintains ±120ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 9),
      ChecklistItem(
        title: "11. Level Standard Rate Turns to Headings",
        notes:
          "Up to 180° of turn, maintains alt ±120 ft, airspeed ±10kts, bank angle ±5°, heading ±10°",
        order: 10),
      ChecklistItem(
        title: "12. Climbs and Descents While Turning to a Heading",
        notes: "Maintains airspeed ±10 kts, heading ±10°, bank ±10°, levels ± 100 ft", order: 11),
      ChecklistItem(
        title: "13. Straight and Level Using Standby/Partial-Panel Instruments",
        notes: "Maintains ±150 ft, heading ±15°, airspeed ±10kts", order: 12),
      ChecklistItem(
        title: "14. Standard Rate Turns to Headings Standby/Partial-Panel Instruments",
        notes: "Up to 180° of turn, maintains alt ±150 ft, airspeed ±10kts, heading ±15°", order: 13
      ),
      ChecklistItem(
        title: "15. Constant Airspeed Climbs and Descents Standby/Partial-Panel Instruments",
        notes: "Maintains airspeed ±15 kts, heading ±15°, levels ±200 ft", order: 14),
      ChecklistItem(
        title: "16. Timed Turns to Heading Using Magnetic Compass",
        notes: "Maintains alt ±150 ft, airspeed ±10 kts, bank angle ±5°, heading ±20°", order: 15),
      ChecklistItem(
        title: "17. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel",
        notes:
          "Returns to stabilized level flight within operating limitations or not entering unsafe conditions",
        order: 16),
      ChecklistItem(
        title: "18. After landing, Taxi, Parking",
        notes: "Exercises good practices to avoid runway incursions", order: 17),
      ChecklistItem(
        title: "19. Postflight Procedures",
        notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies",
        order: 18),
    ]
  )

  static let i2L1GPSAndVORForIFR = ChecklistTemplate(
    name: "I2-L1: GPS and VOR for IFR",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i2_l1_gps_and_vor_for_ifr",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Weather)", order: 0),
      ChecklistItem(
        title: "2. Situational Awareness",
        notes: "Reviews situational awareness issues with RNAV (GPS) and VOR systems", order: 1),
      ChecklistItem(
        title: "3. Controlled Flight into Terrain Awareness",
        notes: "Briefs charted minimum altitudes and hazards of off-airway routes", order: 2),
      ChecklistItem(
        title: "4. Automation Management", notes: "Review autopilot use for instrument flight",
        order: 3),
      ChecklistItem(
        title: "5. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 4),
      ChecklistItem(
        title: "6. Using GPS for IFR Flight",
        notes: "Review certification level, capabilities & limitations of installed GPS equipment",
        order: 5),
      ChecklistItem(
        title: "7. Using VOR for IFR Flight",
        notes:
          "Reviews requirements & options for checking whether a VOR is suitable for IFR; does VOR check",
        order: 6),
      ChecklistItem(
        title: "8. GPS Flight Plan",
        notes: "Enters flight plan into GPS(RNAV) unit & confirms that it matches prebriefed route",
        order: 7),
      ChecklistItem(
        title: "9. GPS Orientation",
        notes:
          "Position with GPS, selects appropriate course/altitude to specified route or waypoint",
        order: 8),
      ChecklistItem(
        title: "10. GPS Course Interception and Tracking",
        notes:
          "Altitude ±150 ft, airspeed ±10 kts, intercepts and tracks course < full-scale deflection",
        order: 9),
      ChecklistItem(
        title: "11. VOR Tune and Identification",
        notes:
          "Determines & selects VOR frequency, identifies station by comparing audio code with chart",
        order: 10),
      ChecklistItem(
        title: "12. VOR Orientation",
        notes:
          "Orientation with 1 VOR & position with 2 or more, selects course/altitude to designated VOR",
        order: 11),
      ChecklistItem(
        title: "13. VOR Radial Interception and Tracking",
        notes:
          "Altitude ±150 ft, airspeed ±10 kts, intercepts and tracks radial < full-scale deflection",
        order: 12),
      ChecklistItem(
        title: "14. Timed Turns to Heading Using Magnetic Compass",
        notes: "Maintains alt ±120 ft, airspeed ± 10 kts, heading ±15°", order: 13),
      ChecklistItem(
        title: "15. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 14),
    ]
  )

  static let i2L2NDBADFNavigationAndDepartureProcedures = ChecklistTemplate(
    name: "I2-L2: NDB/ADF Navigation and Departure Procedures",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i2_l2_ndb_adf_navigation_and_departure_procedures",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Weather)", order: 0),
      ChecklistItem(
        title: "2. Situational Awareness",
        notes:
          "Reviews situational awareness issues with NDB/ADF and VOR systems and published procedures",
        order: 1),
      ChecklistItem(
        title: "3. Controlled Flight into Terrain Awareness",
        notes: "Reviews climb requirements and minimum altitudes on published procedures", order: 2),
      ChecklistItem(
        title: "4. Single Pilot Resource Management",
        notes: "Review the resources available for single-pilot IFR operations", order: 3),
      ChecklistItem(
        title: "5. Using NDB for IFR Navigation",
        notes: "Review NBD signals, ADF system operation/limitations & installed instrumentation",
        order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. Instrument Departure Procedure",
        notes: "Conforms to procedure restrictions, courses, & altitudes", order: 6),
      ChecklistItem(
        title: "8. NDB Orientation",
        notes:
          "Tunes, identifies & finds bearing to/from NDB, selects heading/altitude for specified route",
        order: 7),
      ChecklistItem(
        title: "9. NDB Bearing Interception and Tracking",
        notes:
          "Alt ±150 ft, airspeed ±10 kts, intercepts and tracks ±15° desired bearing inbound/outbound",
        order: 8),
      ChecklistItem(
        title: "10. VOR Orientation",
        notes:
          "Orientation with 1 VOR & position with 2 or more, selects course/altitude to designated VOR",
        order: 9),
      ChecklistItem(
        title: "11. Airway Interception and Tracking",
        notes:
          "Intercepts & tracks VOR airway, identifies intersection, alt ±120 ft, airspeed ±10 kts, ≤3/4 CDI",
        order: 10),
      ChecklistItem(
        title: "12. Turns, Climbs and Descents Standby/Partial-Panel Instruments",
        notes: "Alt ±150 ft, airspeed ±15kts, heading ±15°, levels ±150 ft", order: 11),
      ChecklistItem(
        title: "13. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel",
        notes:
          "Returns to stabilized level flight within operating limitations or not entering unsafe conditions",
        order: 12),
      ChecklistItem(
        title: "14. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 13),
    ]
  )

  static let i2L3BuildingSkillWithGPSVORAndNDBNDBNavigation = ChecklistTemplate(
    name: "I2-L3: Building Skill with GPS, VOR and NDB/NDB Navigation",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i2_l3_building_skill_with_gps_vor_and_ndb_ndb_navigation",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Weather)", order: 0),
      ChecklistItem(
        title: "2. Situational Awareness",
        notes:
          "Briefs situational awareness issues with GPS, NDB & VOR systems and published procedures",
        order: 1),
      ChecklistItem(
        title: "3. Controlled Flight into Terrain Awareness",
        notes: "Briefs climb requirements and minimum altitudes on published procedures", order: 2),
      ChecklistItem(
        title: "4. Single Pilot Resource Management",
        notes: "Briefs resources available for single-pilot IFR operations", order: 3),
      ChecklistItem(
        title: "5. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. Instrument Departure Procedure",
        notes: "Conforms to procedure restrictions, courses, & altitudes", order: 6),
      ChecklistItem(
        title: "8. GPS Course Interception and Tracking",
        notes: "Altitude ±100 ft, airspeed ±10 kts, intercepts and tracks course ≤3/4CDI", order: 7),
      ChecklistItem(
        title: "9. VOR Radial Interception and Tracking",
        notes: "Intercepts & tracks VOR radial, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 8),
      ChecklistItem(
        title: "10. Constant Rate Climbs and Descents while Tracking a VOR Radial",
        notes: "Rate ±100 fpm, airspeed ±10kts, ≤3/4 CDI, levels ±100 ft", order: 9),
      ChecklistItem(
        title: "11. NDB Bearing Interception and Tracking",
        notes:
          "Altitude ±100 ft, airspeed ±10 kts, intercepts and tracks ±10° desired bearing inbound/outbound",
        order: 10),
      ChecklistItem(
        title: "12. Airway Interception and Tracking Standby/Partial-Panel",
        notes:
          "Intercepts & tracks VOR airway, identifies intersection, alt ±150 ft, airspeed ±10 kts, ≤3/4CDI",
        order: 11),
      ChecklistItem(
        title: "13. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 12),
    ]
  )

  static let i2L4DMEARX = ChecklistTemplate(
    name: "I2-L4: DME Arcs",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i2_l4_dme_arx",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
      ChecklistItem(
        title: "2. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 1),
      ChecklistItem(
        title: "3. Holding Procedures",
        notes: "Review what ATC expects for holds (concepts, procedures and restrictions)", order: 2
      ),
      ChecklistItem(
        title: "4. Situational Awareness",
        notes:
          "Review ATC reasons for holds, consequences, alternatives, minimum fuel & emergency fuel",
        order: 3),
      ChecklistItem(
        title: "5. Single Pilot Resource Management",
        notes: "Briefs the resources available for single-pilot IFR operations", order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. DME Arcs Intercepting and Tracking",
        notes: "Alt ±120 ft, airspeed ±10 kts, heading ±10°, DME ± 1.5 nm, ≤3/4CDI", order: 6),
      ChecklistItem(
        title: "8. VOR Radial Interception and Tracking",
        notes: "Intercepts & tracks VOR radial, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 7),
      ChecklistItem(
        title: "9. NDB Bearing Interception and Tracking",
        notes:
          "Altitude ±100 ft, airspeed ±10 kts, intercepts and tracks ±10° desired bearing inbound/outbound",
        order: 8),
      ChecklistItem(
        title: "10. GPS Course Interception and Tracking",
        notes: "Altitude ±100 ft, airspeed ±10 kts, intercepts and tracks course ≤3/4CDI", order: 9),
      ChecklistItem(
        title: "11. Turns, Climbs and Descents Standby/Partial-Panel Instruments",
        notes: "Alt ±150 ft, airspeed ±15 kts, heading ±15°, levels ±150 ft", order: 10),
      ChecklistItem(
        title: "12. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel",
        notes:
          "Returns to stabilized level flight within operating limitations or not entering unsafe conditions",
        order: 11),
      ChecklistItem(
        title: "13. Airway Interception and Tracking Standby/Partial-Panel",
        notes:
          "Intercepts & tracks VOR airway, identifies intersection, alt ±150 ft, airspeed ±10 kts, ≤3/4CDI",
        order: 12),
      ChecklistItem(
        title: "14. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 13),
    ]
  )

  static let i2L5HoldingProcedures = ChecklistTemplate(
    name: "I2-L5: Holding Procedures",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i2_l5_holding_procedures",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
      ChecklistItem(
        title: "2. Aeronautical Decision Making",
        notes:
          "Review techniques for dealing with ATC imposed changes during a flight, use the CARE checklist",
        order: 1),
      ChecklistItem(
        title: "3. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
      ChecklistItem(
        title: "4. Single Pilot Resource Management",
        notes: "Briefs the resources available for single-pilot IFR operations", order: 3),
      ChecklistItem(
        title: "5. Situational Awareness",
        notes:
          "Briefs ATC reasons for holds, consequences, alternatives, minimum fuel & emergency fuel",
        order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. Holding at a VOR or an NDB",
        notes:
          "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction",
        order: 6),
      ChecklistItem(
        title: "8. Holding at a VOR with DME or GPS Waypoint",
        notes:
          "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction",
        order: 7),
      ChecklistItem(
        title: "9. Non-Published Holding at a VOR or an NDB",
        notes:
          "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction",
        order: 8),
      ChecklistItem(
        title: "10. Non-Published Holding at a VOR Intersection",
        notes:
          "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction",
        order: 9),
      ChecklistItem(
        title: "11. Holding at a VOR, NDB or GPS Waypoint Standby/Partial-Panel",
        notes:
          "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction",
        order: 10),
      ChecklistItem(
        title: "12. Intercepting and Tracking DME Arcs",
        notes: "Alt ±100 ft, airspeed ±10 kts, headings ±5°, DME ± 1.0 nm, ≤3/4CDI", order: 11),
      ChecklistItem(
        title: "13. Airway Interception and Tracking Standby/Partial-Panel",
        notes:
          "Intercepts & tracks VOR airway, identifies intersection, alt ±150 ft, airspeed ±10 kts, ≤3/4CDI",
        order: 12),
      ChecklistItem(
        title: "14. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 13),
    ]
  )

  static let i2L6ProgressCheck = ChecklistTemplate(
    name: "I2-L6: Progress Check",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i2_l6_progress_check",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
      ChecklistItem(
        title: "2. Situational Awareness and Controlled Flight into Terrain Awareness",
        notes:
          "Briefs ways to maintain situational awareness & avoid terrain in instrument conditions",
        order: 1),
      ChecklistItem(
        title: "3. Positive Exchange of Flight Controls",
        notes: "Briefs the positive three-step exchange of controls", order: 2),
      ChecklistItem(
        title: "4. Automation Management",
        notes: "Briefs autopilot use in the event of primary instruments/display failures", order: 3
      ),
      ChecklistItem(
        title: "5. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 4),
      ChecklistItem(
        title: "6. Copy and Read-back IFR Clearance",
        notes:
          "Simulated: requests clearance, copies simple clearance & correctly reads-back clearance",
        order: 5),
      ChecklistItem(
        title: "7. Using the Checklists",
        notes: "Exercises an effective flow and check process for procedures", order: 6),
      ChecklistItem(
        title: "8. Collision Avoidance Procedures",
        notes:
          "Clear understanding of responsibilities & procedures for visual & Instrument reference",
        order: 7),
      ChecklistItem(
        title: "9. Constant Rate Climbs and Descents with Constant Airspeed",
        notes: "Maintains rate ±150 fpm, airspeed ±10 kts, heading ±10°, levels ±100 ft", order: 8),
      ChecklistItem(
        title: "10. Straight and Level While Changing Airspeed",
        notes: "Maintains ±120ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 9),
      ChecklistItem(
        title: "11. Level Standard Rate Turns to Headings",
        notes:
          "Up to 180° of turn, maintains alt ±120 ft, airspeed ±10kts, bank angle ±5°, heading ±10°",
        order: 10),
      ChecklistItem(
        title: "12. Climbs and Descents While Turning to a Heading",
        notes: "Maintains airspeed ±10 kts, heading ±10°, bank ±10°, levels ± 100 ft", order: 11),
      ChecklistItem(
        title: "13. Straight and Level Using Standby/Partial-Panel Instruments",
        notes: "Maintains ±150 ft, heading ±15°, airspeed ±10kts", order: 12),
      ChecklistItem(
        title: "14. Standard Rate Turns to Headings Standby/Partial-Panel Instruments",
        notes: "Up to 180° of turn, maintains alt ±150 ft, airspeed ±10kts, heading ±15°", order: 13
      ),
      ChecklistItem(
        title: "15. Constant Airspeed Climbs and Descents Standby/Partial-Panel Instruments",
        notes: "Maintains airspeed ±15 kts, heading ±15°, levels ±200 ft", order: 14),
      ChecklistItem(
        title: "16. Timed Turns to Heading Using Magnetic Compass",
        notes: "Maintains alt ±150 ft, airspeed ±10 kts, bank angle ±5°, heading ±20°", order: 15),
      ChecklistItem(
        title: "17. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel",
        notes:
          "Returns to stabilized level flight within operating limitations or not entering unsafe conditions",
        order: 16),
      ChecklistItem(
        title: "18. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 17),
    ]
  )

  static let i3L1ILSApproachesAndProcedureTurns = ChecklistTemplate(
    name: "I3-L1: ILS Approaches and Procedure Turns",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i3_l1_ils_approaches_and_procedure_turns",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
      ChecklistItem(
        title: "2. Situational Awareness",
        notes: "Briefs situational awareness issues with ILS approaches and published procedures",
        order: 1),
      ChecklistItem(
        title: "3. Controlled Flight into Terrain Awareness",
        notes: "Briefs climb requirements and minimum altitudes on published procedures", order: 2),
      ChecklistItem(
        title: "4. Single Pilot Resource Management",
        notes: "Briefs the resources available for single-pilot IFR operations", order: 3),
      ChecklistItem(
        title: "5. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. ILS Approach Briefing",
        notes:
          "Briefs ILS approach procedures, minimums, missed approach procedures, and decision heights",
        order: 6),
      ChecklistItem(
        title: "8. ILS Approach Intercepting and Tracking",
        notes: "Intercepts & tracks ILS localizer, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 7
      ),
      ChecklistItem(
        title: "9. ILS Approach Glideslope Intercepting and Tracking",
        notes: "Intercepts & tracks ILS glideslope, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI",
        order: 8),
      ChecklistItem(
        title: "10. ILS Approach Final Approach",
        notes: "Maintains ILS localizer & glideslope, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI",
        order: 9),
      ChecklistItem(
        title: "11. ILS Approach Missed Approach",
        notes: "Executes missed approach procedures, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI",
        order: 10),
      ChecklistItem(
        title: "12. Procedure Turn",
        notes: "Executes procedure turn, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI",
        order: 11),
      ChecklistItem(
        title: "13. ILS Approach Standby/Partial-Panel",
        notes: "Intercepts & tracks ILS localizer, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI",
        order: 12),
      ChecklistItem(
        title: "14. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 13),
    ]
  )

  static let i3L2RNAVApproachesWithVerticalGuidance = ChecklistTemplate(
    name: "I3-L2: RNAV Approaches with Vertical Guidance",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i3_l2_rnav_approaches_with_vertical_guidance",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
      ChecklistItem(
        title: "3. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
      ChecklistItem(
        title: "4. Situational Awareness and Controlled Flight into Terrain Awareness",
        notes: "Briefs navigation systems, backups, minimum altitudes, local minimum safe altitude",
        order: 3),
      ChecklistItem(
        title: "5. Checklist Use",
        notes: "Briefs how will use checklists during instrument approaches and uses them", order: 4
      ),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. RNAV (GPS) Setup for Approach",
        notes:
          "Confirms nav data, calls up & verifies correct procedure/waypoints, notes mode & minima",
        order: 6),
      ChecklistItem(
        title: "8. Approach Briefing",
        notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes",
        order: 7),
      ChecklistItem(
        title: "9. Terminal Area Arrival Procedure",
        notes:
          "Conforms to published procedure, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI",
        order: 8),
      ChecklistItem(
        title: "10. RNAV (GPS WAAS) Approach with Vertical Guidance",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI",
        order: 9),
      ChecklistItem(
        title: "11. ILS Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI",
        order: 10),
      ChecklistItem(
        title: "12. Missed Approach Procedure",
        notes:
          "Initiates at DA/DH if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤3/4CDI",
        order: 11),
      ChecklistItem(
        title: "13. Transition to Landing from Straight-In Approach",
        notes: "From DH/DA normal rate of descent, normal maneuvering, uses visual glideslope",
        order: 12),
      ChecklistItem(
        title: "14. Intercepting and Tracking DME Arcs",
        notes: "Alt ±100 ft, airspeed ±10 kts, headings ±5°, DME ±1 nm, ≤3/4CDI", order: 13),
      ChecklistItem(
        title: "15. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 14),
    ]
  )

  static let i3L4VORAndNDBApproaches = ChecklistTemplate(
    name: "I3-L4: VOR and NDB Approaches",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i3_l4_vor_and_ndb_approaches",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
      ChecklistItem(
        title: "3. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
      ChecklistItem(
        title: "4. Situational Awareness and Controlled Flight into Terrain Awareness",
        notes: "Briefs navigation systems, backups, minimum altitudes, local minimum safe altitude",
        order: 3),
      ChecklistItem(
        title: "5. Checklist Use",
        notes: "Uses appropriate checklists during all flight operations", order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. Approach Briefing",
        notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes",
        order: 6),
      ChecklistItem(
        title: "8. VOR Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI",
        order: 7),
      ChecklistItem(
        title: "9. NDB Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI",
        order: 8),
      ChecklistItem(
        title: "10. Localizer Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2CDI",
        order: 9),
      ChecklistItem(
        title: "11. Missed Approach Procedure",
        notes:
          "Initiates at DA/DH/MAP if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤3/4 CDI",
        order: 10),
      ChecklistItem(
        title: "12. Transition to Landing from Straight-In Approach",
        notes: "From DH/DA/MDA normal rate of descent, normal maneuvering, uses visual glideslope",
        order: 11),
      ChecklistItem(
        title: "13. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 12),
    ]
  )

  static let i3L5CirclingApproaches = ChecklistTemplate(
    name: "I3-L5: Circling Approaches",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i3_l5_circling_approaches",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes:
          "Uses PAVE checklist (Pilot, W&B, Performance, Reserves, Weather, day/night, area lighting)",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
      ChecklistItem(
        title: "3. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
      ChecklistItem(
        title: "4. Situational Awareness and Controlled Flight into Terrain Awareness",
        notes:
          "Briefs nav systems, backups, min altitudes, local min safe altitude, obstructions near airports",
        order: 3),
      ChecklistItem(
        title: "5. Checklist Use",
        notes: "Uses appropriate checklists during all flight operations", order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. Approach Briefing",
        notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes",
        order: 6),
      ChecklistItem(
        title: "8. ILS or RNAV (GPS WAAS) Circling Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI",
        order: 7),
      ChecklistItem(
        title: "9. VOR or NDB Circling Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI",
        order: 8),
      ChecklistItem(
        title: "10. Transition to a Landing from Circling Approach",
        notes:
          "Maintains MDA +100/-0 ft, normal rate of descent, normal maneuvering, uses visual glideslope",
        order: 9),
      ChecklistItem(
        title: "11. ILS Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2 CDI",
        order: 10),
      ChecklistItem(
        title: "12. LNAV Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2 CDI",
        order: 11),
      ChecklistItem(
        title: "13. Missed Approach Procedure",
        notes:
          "Initiates at DA/DH/MAP if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤ 3/4 CDI",
        order: 12),
      ChecklistItem(
        title: "14. Transition to Landing from Straight-In Approach",
        notes: "From DH/DA/MDA normal rate of descent, normal maneuvering, uses visual glideslope",
        order: 13),
      ChecklistItem(
        title: "15. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 14),
    ]
  )

  static let i3L6PartialPanelAndUsingTheAutopilotForApproaches = ChecklistTemplate(
    name: "I3-L6: Partial Panel and Using the Autopilot for Approaches",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i3_l6_partial_panel_and_using_the_autopilot_for_approaches",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes:
          "Employs PAVE checklist, incorporates installed advanced/automated equipment in planning",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
      ChecklistItem(
        title: "3. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
      ChecklistItem(
        title: "4. Situational Awareness and Controlled Flight into Terrain Awareness",
        notes: "Briefs navigation systems, backups, minimum altitudes, local minimum safe altitude",
        order: 3),
      ChecklistItem(
        title: "5. Automation Management",
        notes: "Understands autopilot functions/modes, clear on failure indications and responses",
        order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. Approach Briefing",
        notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes",
        order: 6),
      ChecklistItem(
        title: "8. ILS Approach Standby/Partial-Panel",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI",
        order: 7),
      ChecklistItem(
        title: "9. VOR Approach Standby/Partial-Panel",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI",
        order: 8),
      ChecklistItem(
        title: "10. NDB Approach Standby/Partial-Panel",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI",
        order: 9),
      ChecklistItem(
        title: "11. LNAV or Localizer Approach Standby/Partial-Panel",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI",
        order: 10),
      ChecklistItem(
        title: "12. VOR, NDB, LNAV or Localizer Approach Using Autopilot",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2 CDI",
        order: 11),
      ChecklistItem(
        title: "13. ILS Approach Using Autopilot",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2 CDI",
        order: 12),
      ChecklistItem(
        title: "14. Missed Approach Procedure",
        notes:
          "Initiates at DA/DH/MAP if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤3/4 CDI",
        order: 13),
      ChecklistItem(
        title: "15. Transition to a Landing (Straight-in or Circling Approach)",
        notes:
          "Maintains MDA +100/-0 ft, normal rate of descent, normal maneuvering, uses visual glideslope",
        order: 14),
      ChecklistItem(
        title: "16. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 15),
    ]
  )

  static let i3L7ProgressCheck = ChecklistTemplate(
    name: "I3-L7: Progress Check",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i3_l7_progress_check",
    items: [
      ChecklistItem(
        title: "1. Managing Risk for Instrument Flight",
        notes:
          "Employs PAVE checklist, incorporates installed advanced/automated equipment in planning",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
      ChecklistItem(
        title: "3. Task Management",
        notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
      ChecklistItem(
        title: "4. Situational Awareness and Controlled Flight into Terrain Awareness",
        notes: "Briefs navigation systems, backups, minimum altitudes, local minimum safe altitude",
        order: 3),
      ChecklistItem(
        title: "5. Automation Management",
        notes:
          "Briefs autopilot functions/modes, failure indications and responses, approach techniques",
        order: 4),
      ChecklistItem(
        title: "6. Before Instrument Flight Ground Operations",
        notes:
          "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight",
        order: 5),
      ChecklistItem(
        title: "7. Approach Briefing",
        notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes",
        order: 6),
      ChecklistItem(
        title: "8. ILS Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI",
        order: 7),
      ChecklistItem(
        title: "9. RNAV (GPS WAAS) Approach with Vertical Guidance",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI",
        order: 8),
      ChecklistItem(
        title: "10. VOR or NDB Circling Approach",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI",
        order: 9),
      ChecklistItem(
        title: "11. LNAV or Localizer Approach Standby/Partial-Panel",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2CDI",
        order: 10),
      ChecklistItem(
        title: "12. VOR, NDB, LNAV or Localizer Approach Using Autopilot",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2CDI",
        order: 11),
      ChecklistItem(
        title: "13. Procedure Turn Course Reversal",
        notes: "Alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI", order: 12),
      ChecklistItem(
        title: "14. Terminal Area Arrival Procedure",
        notes:
          "Conforms to published procedure, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI",
        order: 13),
      ChecklistItem(
        title: "15. Holding Pattern Course Reversal",
        notes:
          "Correct entry, alt +100/-0 ft after FAF, a/s ±10 kts, heading ±10°, ≤1/2CDI, wind correction",
        order: 14),
      ChecklistItem(
        title: "16. Missed Approach Procedure",
        notes:
          "Initiates at DA/DH/MAP if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤1/2CDI",
        order: 15),
      ChecklistItem(
        title: "17. Transition to a Landing (Straight-in or Circling Approach)",
        notes:
          "Maintains MDA +100/-0 ft, normal rate of descent, normal maneuvering, uses visual glideslope",
        order: 16),
      ChecklistItem(
        title: "18. After landing, Taxi, Parking, Postflight",
        notes:
          "Exercises good practices to avoid runway incursions, notes & documents discrepancies",
        order: 17),
    ]
  )

  // Phase 4: Instrument Cross Countries
  static let i4L1ShortIFRCrossCountry = ChecklistTemplate(
    name: "I4-L1: Short IFR Cross Country",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i4_l1_short_ifr_cross_country",
    items: [
      ChecklistItem(
        title: "1. Cross-Country Flight Planning",
        notes: "Plan IFR cross country to airport >50nm straight-line distance", order: 0),
      ChecklistItem(
        title: "2. En Route ATC Communications",
        notes: "Experience en route ATC communications and procedures", order: 1),
      ChecklistItem(
        title: "3. Navigation Systems",
        notes: "Practice navigation using various systems during cross-country flight", order: 2),
      ChecklistItem(
        title: "4. First Instrument Approach",
        notes: "Fly first instrument approach at destination airport", order: 3),
      ChecklistItem(
        title: "5. Second Instrument Approach",
        notes: "Fly second instrument approach (different type)", order: 4),
      ChecklistItem(
        title: "6. Third Instrument Approach",
        notes: "Fly third instrument approach (different type)", order: 5),
      ChecklistItem(
        title: "7. Cross-Country Navigation",
        notes: "Demonstrate proficiency in cross-country IFR navigation", order: 6),
      ChecklistItem(
        title: "8. ATC Procedures", notes: "Follow proper ATC procedures throughout flight",
        order: 7),
      ChecklistItem(
        title: "9. Weather Considerations",
        notes: "Plan and execute flight considering weather conditions", order: 8),
      ChecklistItem(
        title: "10. Fuel Management",
        notes: "Proper fuel planning and management for cross-country flight", order: 9),
    ]
  )

  static let i4L2RefiningApproaches = ChecklistTemplate(
    name: "I4-L2: Refining Approaches",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i4_l2_refining_approaches",
    items: [
      ChecklistItem(
        title: "1. Single Pilot Resource Management",
        notes: "Instrument Rating Airman Certification Standards", order: 0),
      ChecklistItem(
        title: "2. Instrument Cockpit Check",
        notes: "Instrument Rating Airman Certification Standards", order: 1),
      ChecklistItem(
        title: "3. ILS Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 2),
      ChecklistItem(
        title: "4. RNAV (GPS WAAS) Approach with Vertical Guidance",
        notes: "Instrument Rating Airman Certification Standards", order: 3),
      ChecklistItem(
        title: "5. NDB (VOR if NDB not available) Circling Approach",
        notes: "Instrument Rating Airman Certification Standards", order: 4),
      ChecklistItem(
        title: "6. VOR Approach Standby/Partial-Panel",
        notes: "Instrument Rating Airman Certification Standards", order: 5),
      ChecklistItem(
        title: "7. VOR, NDB, LNAV or Localizer Approach Using Autopilot",
        notes: "Instrument Rating Airman Certification Standards", order: 6),
      ChecklistItem(
        title: "8. PAR or ASR Approach (if available)",
        notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±5°, ≤1/2 CDI",
        order: 7),
      ChecklistItem(
        title: "9. Procedure Turn Course Reversal",
        notes: "Alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2 CDI", order: 8),
      ChecklistItem(
        title: "10. Terminal Area Arrival Procedure",
        notes:
          "Conforms to published procedure, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2 CDI",
        order: 9),
      ChecklistItem(
        title: "11. Lost Communications", notes: "Instrument Rating Airman Certification Standards",
        order: 10),
      ChecklistItem(
        title: "12. Missed Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 11),
      ChecklistItem(
        title: "13. Landing from a Straight-in or Circling Approach",
        notes: "Instrument Rating Airman Certification Standards", order: 12),
      ChecklistItem(
        title: "14. Postflight Checking Instruments and Equipment",
        notes: "Instrument Rating Airman Certification Standards", order: 13),
    ]
  )

  static let i4L3LongIFRCrossCountryProgressCheck = ChecklistTemplate(
    name: "I4-L3: Long IFR Cross Country Progress Check",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i4_l3_long_ifr_cross_country_progress_check",
    items: [
      ChecklistItem(
        title: "1. Single-Pilot Resource Management",
        notes: "Instrument Rating Airman Certification Standards", order: 0),
      ChecklistItem(
        title: "2. Aeronautical Decision Making",
        notes: "Instrument Rating Airman Certification Standards", order: 1),
      ChecklistItem(
        title: "3. Risk Management", notes: "Instrument Rating Airman Certification Standards",
        order: 2),
      ChecklistItem(
        title: "4. Task Management", notes: "Instrument Rating Airman Certification Standards",
        order: 3),
      ChecklistItem(
        title: "5. Situational Awareness",
        notes: "Instrument Rating Airman Certification Standards", order: 4),
      ChecklistItem(
        title: "6. Controlled Flight into Terrain Awareness",
        notes: "Instrument Rating Airman Certification Standards", order: 5),
      ChecklistItem(
        title: "7. Automation Management",
        notes: "Instrument Rating Airman Certification Standards", order: 6),
      ChecklistItem(
        title: "8. Required ATC Reports", notes: "Review all required ATC reports", order: 7),
      ChecklistItem(
        title: "9. Cross-Country Flight Planning",
        notes: "Instrument Rating Airman Certification Standards", order: 8),
      ChecklistItem(
        title: "10. Instrument Cockpit Check",
        notes: "Instrument Rating Airman Certification Standards", order: 9),
      ChecklistItem(
        title: "11. ATC Clearances", notes: "Instrument Rating Airman Certification Standards",
        order: 10),
      ChecklistItem(
        title: "12. Compliance with Departure, En Route, and Arrival Procedures and Clearances",
        notes: "Instrument Rating Airman Certification Standards", order: 11),
      ChecklistItem(
        title: "13. Lost Communications", notes: "Instrument Rating Airman Certification Standards",
        order: 12),
      ChecklistItem(
        title: "14. Autopilot Use",
        notes:
          "Uses autopilot appropriately; instructor simulated failure to ensure demonstrates manual skill",
        order: 13),
      ChecklistItem(
        title: "15. Instrument approaches (3 approaches, each a different type nav system)",
        notes: "Instrument Rating Airman Certification Standards", order: 14),
      ChecklistItem(
        title: "16. Missed Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 15),
      ChecklistItem(
        title: "17. Landing from a Straight-in or Circling Approach",
        notes: "Instrument Rating Airman Certification Standards", order: 16),
      ChecklistItem(
        title: "18. Runway Incursion Avoidance",
        notes: "Studies airport diagram, anticipates post-landing taxi, aware of hot spots",
        order: 17),
      ChecklistItem(
        title: "19. Postflight Checking Instruments and Equipment",
        notes: "Instrument Rating Airman Certification Standards", order: 18),
    ]
  )

  // Phase 5: Becoming Instrument Rated
  static let i5L1AirmanCertificationStandards = ChecklistTemplate(
    name: "I5-L1: Airman Certification Standards",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i5_l1_airman_certification_standards",
    items: [
      ChecklistItem(
        title: "1. Airman Certification Standards",
        notes: "Introduction, Appendices, Areas of Operation & Tasks", order: 0),
      ChecklistItem(
        title: "2. Positive Aircraft Control",
        notes: "Instrument Rating Airman Certification Standards", order: 1),
      ChecklistItem(
        title: "3. Positive Exchange of Flight Controls",
        notes: "Instrument Rating Airman Certification Standards", order: 2),
      ChecklistItem(
        title: "4. Stall/Spin Awareness", notes: "Instrument Rating Airman Certification Standards",
        order: 3),
      ChecklistItem(
        title: "5. Collision Avoidance", notes: "Instrument Rating Airman Certification Standards",
        order: 4),
      ChecklistItem(
        title: "6. Wake Turbulence Avoidance",
        notes: "Instrument Rating Airman Certification Standards", order: 5),
      ChecklistItem(
        title: "7. Land and Hold Short Operations (LAHSO)",
        notes: "Instrument Rating Airman Certification Standards", order: 6),
      ChecklistItem(
        title: "8. Runway Incursion Avoidance",
        notes: "Instrument Rating Airman Certification Standards", order: 7),
      ChecklistItem(
        title: "9. Checklist Usage", notes: "Instrument Rating Airman Certification Standards",
        order: 8),
      ChecklistItem(
        title: "10. Icing Condition Operational Hazards, Anti-icing and Deicing Equipment",
        notes: "Instrument Rating Airman Certification Standards", order: 9),
      ChecklistItem(
        title: "11. Single-Pilot Resource Management",
        notes: "Instrument Rating Airman Certification Standards", order: 10),
      ChecklistItem(
        title: "12. Aeronautical Decision Making",
        notes: "Instrument Rating Airman Certification Standards", order: 11),
      ChecklistItem(
        title: "13. Risk Management", notes: "Instrument Rating Airman Certification Standards",
        order: 12),
      ChecklistItem(
        title: "14. Task Management", notes: "Instrument Rating Airman Certification Standards",
        order: 13),
      ChecklistItem(
        title: "15. Situational Awareness",
        notes: "Instrument Rating Airman Certification Standards", order: 14),
      ChecklistItem(
        title: "16. Controlled Flight into Terrain Awareness",
        notes: "Instrument Rating Airman Certification Standards", order: 15),
      ChecklistItem(
        title: "17. Automation Management",
        notes: "Instrument Rating Airman Certification Standards", order: 16),
      ChecklistItem(
        title: "18. Pilot Qualifications",
        notes: "Instrument Rating Airman Certification Standards", order: 17),
      ChecklistItem(
        title: "19. Weather Information", notes: "Instrument Rating Airman Certification Standards",
        order: 18),
      ChecklistItem(
        title: "20. Cross-Country Flight Planning",
        notes: "Instrument Rating Airman Certification Standards", order: 19),
      ChecklistItem(
        title: "21. Aircraft Systems Related to IFR Operations",
        notes: "Instrument Rating Airman Certification Standards", order: 20),
      ChecklistItem(
        title: "22. Aircraft Flight Instruments and Navigation Equipment",
        notes: "Instrument Rating Airman Certification Standards", order: 21),
      ChecklistItem(
        title: "23. Instrument Cockpit Check",
        notes: "Instrument Rating Airman Certification Standards", order: 22),
      ChecklistItem(
        title: "24. Air Traffic Control Clearances",
        notes: "Instrument Rating Airman Certification Standards", order: 23),
    ]
  )

  static let i5L2HoningTheEdge = ChecklistTemplate(
    name: "I5-L2: Honing the Edge",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i5_l2_honing_the_edge",
    items: [
      ChecklistItem(
        title: "25. Compliance with Departure, En Route, and Arrival Procedures and Clearances",
        notes: "Instrument Rating Airman Certification Standards", order: 0),
      ChecklistItem(
        title: "26. Holding Procedures", notes: "Instrument Rating Airman Certification Standards",
        order: 1),
      ChecklistItem(
        title: "27. Basic Instrument Flight Maneuvers",
        notes: "Instrument Rating Airman Certification Standards", order: 2),
      ChecklistItem(
        title: "28. Recovery from Unusual Flight Attitudes",
        notes: "Instrument Rating Airman Certification Standards", order: 3),
      ChecklistItem(
        title: "29. Intercepting and Tracking Navigational Systems and DME Arcs",
        notes: "Instrument Rating Airman Certification Standards", order: 4),
      ChecklistItem(
        title: "30. Nonprecision Approach",
        notes: "Instrument Rating Airman Certification Standards", order: 5),
      ChecklistItem(
        title: "31. Precision Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 6),
      ChecklistItem(
        title: "32. Missed Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 7),
      ChecklistItem(
        title: "33. Circling Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 8),
      ChecklistItem(
        title: "34. Landing from a Straight-In or Circling Approach",
        notes: "Instrument Rating Airman Certification Standards", order: 9),
      ChecklistItem(
        title: "35. Loss of Communications",
        notes: "Instrument Rating Airman Certification Standards", order: 10),
      ChecklistItem(
        title: "36. Approach with Loss of Primary Flight Instrument Indicators",
        notes: "Instrument Rating Airman Certification Standards", order: 11),
      ChecklistItem(
        title: "37. Postflight Checking Instruments and Equipment",
        notes: "Instrument Rating Airman Certification Standards", order: 12),
    ]
  )

  static let i5L3PreCheckrideProgressCheck = ChecklistTemplate(
    name: "I5-L3: Pre-Checkride Progress Check",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i5_l3_pre_checkride_progress_check",
    items: [
      ChecklistItem(
        title: "1. Airman Certification Standards",
        notes: "Introduction, Appendices, Areas of Operation & Tasks", order: 0),
      ChecklistItem(
        title: "2. Positive Aircraft Control",
        notes: "Instrument Rating Airman Certification Standards", order: 1),
      ChecklistItem(
        title: "3. Positive Exchange of Flight Controls",
        notes: "Instrument Rating Airman Certification Standards", order: 2),
      ChecklistItem(
        title: "4. Stall/Spin Awareness", notes: "Instrument Rating Airman Certification Standards",
        order: 3),
      ChecklistItem(
        title: "5. Collision Avoidance", notes: "Instrument Rating Airman Certification Standards",
        order: 4),
      ChecklistItem(
        title: "6. Wake Turbulence Avoidance",
        notes: "Instrument Rating Airman Certification Standards", order: 5),
      ChecklistItem(
        title: "7. Land and Hold Short Operations (LAHSO)",
        notes: "Instrument Rating Airman Certification Standards", order: 6),
      ChecklistItem(
        title: "8. Runway Incursion Avoidance",
        notes: "Instrument Rating Airman Certification Standards", order: 7),
      ChecklistItem(
        title: "9. Checklist Usage", notes: "Instrument Rating Airman Certification Standards",
        order: 8),
      ChecklistItem(
        title: "10. Icing Condition Operational Hazards, Anti-icing and Deicing Equipment",
        notes: "Instrument Rating Airman Certification Standards", order: 9),
      ChecklistItem(
        title: "11. Single-Pilot Resource Management",
        notes: "Instrument Rating Airman Certification Standards", order: 10),
      ChecklistItem(
        title: "12. Aeronautical Decision Making",
        notes: "Instrument Rating Airman Certification Standards", order: 11),
      ChecklistItem(
        title: "13. Risk Management", notes: "Instrument Rating Airman Certification Standards",
        order: 12),
      ChecklistItem(
        title: "14. Task Management", notes: "Instrument Rating Airman Certification Standards",
        order: 13),
      ChecklistItem(
        title: "15. Situational Awareness",
        notes: "Instrument Rating Airman Certification Standards", order: 14),
      ChecklistItem(
        title: "16. Controlled Flight into Terrain Awareness",
        notes: "Instrument Rating Airman Certification Standards", order: 15),
      ChecklistItem(
        title: "17. Automation Management",
        notes: "Instrument Rating Airman Certification Standards", order: 16),
      ChecklistItem(
        title: "18. Pilot Qualifications",
        notes: "Instrument Rating Airman Certification Standards", order: 17),
      ChecklistItem(
        title: "19. Weather Information", notes: "Instrument Rating Airman Certification Standards",
        order: 18),
      ChecklistItem(
        title: "20. Cross-Country Flight Planning",
        notes: "Instrument Rating Airman Certification Standards", order: 19),
      ChecklistItem(
        title: "21. Aircraft Systems Related to IFR Operations",
        notes: "Instrument Rating Airman Certification Standards", order: 20),
      ChecklistItem(
        title: "22. Aircraft Flight Instruments and Navigation Equipment",
        notes: "Instrument Rating Airman Certification Standards", order: 21),
      ChecklistItem(
        title: "23. Instrument Cockpit Check",
        notes: "Instrument Rating Airman Certification Standards", order: 22),
      ChecklistItem(
        title: "24. Air Traffic Control Clearances",
        notes: "Instrument Rating Airman Certification Standards", order: 23),
      ChecklistItem(
        title: "25. Compliance with Departure, En Route, and Arrival Procedures and Clearances",
        notes: "Instrument Rating Airman Certification Standards", order: 24),
      ChecklistItem(
        title: "26. Holding Procedures", notes: "Instrument Rating Airman Certification Standards",
        order: 25),
      ChecklistItem(
        title: "27. Basic Instrument Flight Maneuvers",
        notes: "Instrument Rating Airman Certification Standards", order: 26),
      ChecklistItem(
        title: "28. Recovery from Unusual Flight Attitudes",
        notes: "Instrument Rating Airman Certification Standards", order: 27),
      ChecklistItem(
        title: "29. Intercepting and Tracking Navigational Systems and DME Arcs",
        notes: "Instrument Rating Airman Certification Standards", order: 28),
      ChecklistItem(
        title: "30. Nonprecision Approach",
        notes: "Instrument Rating Airman Certification Standards", order: 29),
      ChecklistItem(
        title: "31. Precision Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 30),
      ChecklistItem(
        title: "32. Missed Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 31),
      ChecklistItem(
        title: "33. Circling Approach", notes: "Instrument Rating Airman Certification Standards",
        order: 32),
      ChecklistItem(
        title: "34. Landing from a Straight-In or Circling Approach",
        notes: "Instrument Rating Airman Certification Standards", order: 33),
      ChecklistItem(
        title: "35. Loss of Communications",
        notes: "Instrument Rating Airman Certification Standards", order: 34),
      ChecklistItem(
        title: "36. Approach with Loss of Primary Flight Instrument Indicators",
        notes: "Instrument Rating Airman Certification Standards", order: 35),
      ChecklistItem(
        title: "37. Postflight Checking Instruments and Equipment",
        notes: "Instrument Rating Airman Certification Standards", order: 36),
    ]
  )

  static let i5L4Endorsements = ChecklistTemplate(
    name: "I5-L4: Endorsements",
    category: "Instrument",
    phase: "Instrument Rating",
    templateIdentifier: "default_i5_l4_endorsements",
    items: [
      ChecklistItem(
        title: "1. Instrument Rating Knowledge Test Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.65 and has satisfactorily completed the required knowledge test review. I have determined that [Student Name] is prepared for the knowledge test.",
        order: 0),
      ChecklistItem(
        title: "2. Instrument Rating Practical Test Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.65 and has satisfactorily completed the required practical test review. I have determined that [Student Name] is prepared for the practical test.",
        order: 1),
      ChecklistItem(
        title: "3. Instrument Rating Training Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.65 and has satisfactorily completed the required instrument training. I have determined that [Student Name] is prepared for instrument operations.",
        order: 2),
      ChecklistItem(
        title: "4. Cross-Country Flight Training Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.65(c) and has satisfactorily completed the required cross-country flight training. I have determined that [Student Name] is prepared for cross-country instrument operations.",
        order: 3),
    ]
  )

}
