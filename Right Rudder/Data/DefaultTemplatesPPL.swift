//
//  DefaultTemplatesPPL.swift
//  Right Rudder
//
//  PPL (Private Pilot License) default checklist templates
//

import Foundation
import SwiftData

// MARK: - DefaultTemplates + PPL

extension DefaultTemplates {
  // MARK: - First Steps Templates

  static let studentOnboardTrainingOverview = ChecklistTemplate(
    name: "Student Onboard/Training Overview",
    category: "PPL",
    phase: "First Steps",
    templateIdentifier: "default_student_onboard_training_overview",
    items: [
      ChecklistItem(
        title: "1. Previous flight training", notes: "Document previous flight training experience",
        order: 0),
      ChecklistItem(
        title: "2. Logbook Review", notes: "Review student's existing logbook entries", order: 1),
      ChecklistItem(
        title: "3. Contact information",
        notes: "Verify all contact details are complete and accurate", order: 2),
      ChecklistItem(
        title: "4. A.14 Endorsement of U.S. Citizenship recommended by the TSA.",
        notes:
          "\"I certify that [first name, MI, last name], has presented me a [type of document presented, such as a US birth certificate or US passport and the relevant control or sequential number on the document, if any], establishing that they are a US citizen or national in accordance with 49 CFR 1552.15(c)\"",
        order: 3),
    ]
  )

  // MARK: - Phase 1 Templates

  static let p1L1StraightAndLevelFlight = ChecklistTemplate(
    name: "P1-L1: Straight and Level Flight",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l1_straight_and_level_flight",
    items: [
      ChecklistItem(
        title: "1. Safety Practices, Procedures and Equipment",
        notes: "Understands hazards, door, seat, safety belt, and fire extinguisher operation",
        order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection, Flight Control and Systems Operation",
        notes: "Observes preflight demo using checklist; understands switch & control functions",
        order: 1),
      ChecklistItem(
        title: "3. Positive Exchange of Flight Controls",
        notes: "Understands and uses the positive three-step exchange of controls", order: 2),
      ChecklistItem(
        title: "4. Prestart checklist, Engine Starting and Warm-up",
        notes: "Observes prestart checklist, starting and warm up procedures", order: 3),
      ChecklistItem(
        title: "5. Taxiing",
        notes:
          "Observes demo. With instructor, assists with controling the airplane, observes signs and markings",
        order: 4),
      ChecklistItem(
        title: "6. Before Takeoff Checks and Engine Runup",
        notes: "Observes pretakeoff checklist and engine runup", order: 5),
      ChecklistItem(
        title: "7. Normal Takeoff and Climb",
        notes: "Observes & is lightly on the controls for instructor's takeoff & initial climb",
        order: 6),
      ChecklistItem(
        title: "8. Level-off",
        notes:
          "Observes and is lightly on the controls for instructor's level-off from initial climb",
        order: 7),
      ChecklistItem(
        title: "9. Checklist Use",
        notes: "Observes instructor use of checklists for all phases of flight", order: 8),
      ChecklistItem(
        title: "10. Collision Avoidance",
        notes: "Observes demo of clearing for traffic during climbs, descents, and before turns",
        order: 9),
      ChecklistItem(
        title: "11. Trimming",
        notes:
          "Senses the changes in control pressure and moves trim wheel in the correct direction",
        order: 10),
      ChecklistItem(
        title: "12. Straight and Level",
        notes: "Notes reference point and altitude changes and initiates corrections ", order: 11),
      ChecklistItem(
        title: "13. Demonstration of tendency to maintain straight and level flight",
        notes: "Observes instructor demonstration of pitch and bank stability", order: 12),
      ChecklistItem(
        title: "14. Turn Coordination",
        notes: "With instructor assistance, applies rudder when starting & stopping turns",
        order: 13),
      ChecklistItem(
        title: "15. Medium Bank Turns",
        notes: "With assist starts & stops coordinated medium-bank, level altitude turn", order: 14),
      ChecklistItem(
        title: "16. Climbs and Level-off",
        notes: "Observes climb attitude and with instructor assist can establish a climb", order: 15
      ),
      ChecklistItem(
        title: "17. Descents and Level-off",
        notes: "Observes descent attitude and with instructor assist can establish a descent",
        order: 16),
      ChecklistItem(
        title: "18. Area Familiarization",
        notes: "Observes as instructor directs attention to prominent landmarks and roadways",
        order: 17),
      ChecklistItem(
        title: "19. Normal Approach and Landing",
        notes: "Observes instructor normal approach and landing demo including checklist use",
        order: 18),
      ChecklistItem(
        title: "20. After Landing, Taxi and Parking",
        notes:
          "With instructor assist, completes after-landing checklist, taxi, shutdown & parking",
        order: 19),
      ChecklistItem(
        title: "21. Post Flight Procedures",
        notes:
          "Observes postflight inspection and securing demonstration while following checklist",
        order: 20),
    ]
  )

  static let p1L2BasicAircraftOperations = ChecklistTemplate(
    name: "P1-L2: Basic Aircraft Operations",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l2_basic_aircraft_operations",
    items: [
      ChecklistItem(
        title: "1. Preflight Inspection, Flight Control and Systems Operation",
        notes:
          "With assist, performs preflight inspection with checklist & can explain systems operation",
        order: 0),
      ChecklistItem(
        title: "2. Passenger Briefing",
        notes: "Understands Hazards, Door, Seat, Safety belt, and fire extenguisher operation.",
        order: 1),
      ChecklistItem(
        title: "3. Positive exchange of Flight Controls",
        notes: "Understands and uses the positive three-step exchange of controls", order: 2),
      ChecklistItem(
        title: "4. Engine Starting and Warm-up",
        notes: "With instructor assist, completes prestart checklist, engine start & warm-up",
        order: 3),
      ChecklistItem(
        title: "5. Radio Communications",
        notes: "Turns on & sets up Comm radios copies ATIS, & makes taxi calls using a script",
        order: 4),
      ChecklistItem(
        title: "6. Taxiing",
        notes:
          "Taxies with minimal instructor assist, uses airport diagram, notes signs and markings",
        order: 5),
      ChecklistItem(
        title: "7. Before Takeoff Checks and Engine Runup",
        notes: "Completes pretakeoff checklist and engine runup with instructor assist", order: 6),
      ChecklistItem(
        title: "8. Normal takeoff and climb",
        notes: "Follows lightly on the controls during instructor's takeoff and initial climb",
        order: 7),
      ChecklistItem(
        title: "9. Level Off",
        notes: "With Instructor assist, levels off at desired altitude ± 300' ", order: 8),
      ChecklistItem(
        title: "10. Collision avoidance",
        notes: "With instructor assist clears traffic during climbs, descents, and before turns",
        order: 9),
      ChecklistItem(
        title: "11. Turn Coordination",
        notes: "Applies aileron and appropriate rudder & elevator for turns both directions",
        order: 10),
      ChecklistItem(
        title: "12. Medium Bank Turns",
        notes: "Checks for traffic, starts a medium-bank turn holding ±200' and stops turn ±20 °",
        order: 11),
      ChecklistItem(
        title: "13. Left and Right Turning Tendency",
        notes: "Notes rudder required for lo speed/hi power & hi speed/lo power", order: 12),
      ChecklistItem(
        title: "14. Trimming",
        notes: "Applies trim in the correct direction removing control pressure", order: 13),
      ChecklistItem(
        title: "15. Straight and Level",
        notes: "Picks reference, maintains altitude ± 200' & heading within ±20°", order: 14),
      ChecklistItem(
        title: "16. Climbs and Descents and Level-off With and Without Turns",
        notes:
          "With assist, adjusts power, pitch & bank to hold ± 10 kts  & levels off  ± 200' & ±20°",
        order: 15),
      ChecklistItem(
        title: "17. Descents With and Without Flaps",
        notes:
          "With instructor assist, starts descent without flaps & extends flaps in increments. Note FPM changes with different flap settings",
        order: 16),
      ChecklistItem(
        title: "18. Power Off Descent",
        notes: "Notes attitude for best glide speed, makes turns, & adds power for level flight",
        order: 17),
      ChecklistItem(
        title: "19. Traffic pattern operations",
        notes:
          "Entry, Exit, and call outs. Observes as instructor directs attention to prominent landmarks and roadways",
        order: 18),
      ChecklistItem(
        title: "20. Normal Approach and Landing",
        notes:
          "Follows checklist & observes instructor demonstration of normal approach and landing",
        order: 19),
      ChecklistItem(
        title: "21. After Landing, Taxi and Parking",
        notes:
          "With minimal assist completes after landing checks, taxi using airport diagram and parking",
        order: 20),
      ChecklistItem(
        title: "22. Postflight Procedures",
        notes: "Completes postflight inspection and secures the aircraft using checklist", order: 21
      ),
    ]
  )

  static let p1L3InstrumentsAndInvestigatingSlowFlight = ChecklistTemplate(
    name: "P1-L3: Instruments and Investigating slow-flight",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l3_instruments_and_investigating_slow_flight",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes: "Reviews PAVE checklist with instructor noting fuel, weather conditions & loading",
        order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes: "With minimal assist, uses appropriate checklists & performs all ground operations",
        order: 1),
      ChecklistItem(
        title: "3. Radio Communications",
        notes: "With instructor assist & script, makes taxi, takeoff, & pre-landing calls", order: 2
      ),
      ChecklistItem(
        title: "4. Crosswind Taxi",
        notes:
          "With minimal assist, notes wind, positons controls to counter the wind effects, uses diagram",
        order: 3),
      ChecklistItem(
        title: "5. Normal Take Off and Climb",
        notes:
          "With instructor's assist, performs normal takeoff, climbs ±10 kts, scans for traffic",
        order: 4),
      ChecklistItem(
        title: "6. Straight and Level",
        notes:
          "Notes reference point and altitude changes and initiates corrections, ±150' & ±15° ",
        order: 5),
      ChecklistItem(
        title: "7. Turns",
        notes:
          "Starts and stops shallow & medium bank turns holding altitude ±150' rolling out  ±15°    ",
        order: 6),
      ChecklistItem(
        title: "8. Climbs and Descents Straight and with Turns",
        notes: "Grasps pitch/airspeed relationship holds ±10 kts, trims, & levels-off within ±100'",
        order: 7),
      ChecklistItem(
        title: "9. Power Off Descent",
        notes: "Attitude for best glide speed, 180° turns noting altitude loss, & level-off ±100'",
        order: 8),
      ChecklistItem(
        title: "10. Aileron/Rudder Coordination Exercise",
        notes: "Observes demo & then practices 30° bank side-to-side keeping nose on point",
        order: 9),
      ChecklistItem(
        title: "11. Straight and Level Using Flight Instruments",
        notes: "Using visual reference, S&L on instruments ±300' ±20° & compare with outside view",
        order: 10),
      ChecklistItem(
        title: "12. Turns Using Flight Instruments",
        notes: "Left & right med bank turns on instruments ±300' ±20° & compare with outside view",
        order: 11),
      ChecklistItem(
        title: "13. Climbs and Descents Using Flight Instruments",
        notes: "Initiates climbs and descents on instruments ±15° & compare with outside view",
        order: 12),
      ChecklistItem(
        title: "14. Flying Slowly",
        notes:
          "With assist, slows to 1.1xVS0 S&L, shallow turns, note changes in force, response & sound",
        order: 13),
      ChecklistItem(
        title: "15. Descent at Approach Airspeed in Landing Configuration",
        notes:
          "With minimal assist descends approach airspeeds/flaps to simulated landing at altitude",
        order: 14),
      ChecklistItem(
        title: "16. Go-Around Procedures",
        notes: "Observes demo & with assist does go-arounds at altitude (partial and full flaps)",
        order: 15),
      ChecklistItem(
        title: "17. Area Recognition/Traffic Pattern Entry",
        notes: "Correlates position with prominent local landmarks", order: 16),
      ChecklistItem(
        title: "18. Normal Approach and Landing",
        notes: "Follows lightly on the controls during instructor's normal approach and landing",
        order: 17),
      ChecklistItem(
        title: "19. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes:
          "With minimal assist, uses appropriate checklists/diagrams & performs all ground operations",
        order: 18),
    ]
  )

  static let p1L4SlowFlightAndStalls = ChecklistTemplate(
    name: "P1-L4: Slow Flight and Stalls",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l4_slow_flight_and_stalls",
    items: [
      ChecklistItem(
        title: "1. Risk Managment",
        notes: "Reviews PAVE checklist with instructor noting fuel, weather conditions & loading",
        order: 0),
      ChecklistItem(
        title: "2. Stall/Spin Awareness",
        notes:
          "Understands concept of aerodynamic stall & spin, warning signs & need to control yaw",
        order: 1),
      ChecklistItem(
        title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes: "With minimal assist, uses appropriate checklists & performs all ground operations",
        order: 2),
      ChecklistItem(
        title: "4. Crosswind Taxi",
        notes:
          "With minimal assist, notes wind, positons controls to counter the wind effects, uses diagram. Demonstrate or verbal.",
        order: 3),
      ChecklistItem(
        title: "5. Radio Communications",
        notes: "With instructor assist & script, makes taxi, takeoff, & pre-landing calls", order: 4
      ),
      ChecklistItem(
        title: "6. Normal Take Off and Climb",
        notes:
          "With instructor's assist, performs normal takeoff, climbs ±10 kts, scans for traffic",
        order: 5),
      ChecklistItem(
        title: "7. Straight and Level",
        notes:
          "Notes reference point and altitude changes and initiates corrections, ±150' & ±15° ",
        order: 6),
      ChecklistItem(
        title: "8. Turns",
        notes:
          "Starts and stops shallow & medium bank turns holding altitude ±150' rolling out  ±15°",
        order: 7),
      ChecklistItem(
        title: "9. Fundamental Maneuvers Visual Reference",
        notes:
          "Uses coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°",
        order: 8),
      ChecklistItem(
        title: "10. Fundamental Maneuvers Instrument Reference",
        notes:
          "Uses coordinated controls, altitude ±250', heading ±20°, airspeed ±10 kts, bank ±15°",
        order: 9),
      ChecklistItem(
        title: "11. Flying Slowly",
        notes: "With minimal assist, Straight&Level, turns, climbs, & descents at minimum airspeed",
        order: 10),
      ChecklistItem(
        title: "12. Controlling Roll and Yaw at High Angle of Attack",
        notes: "With instructor assistance, explores rudder use for bank control ", order: 11),
      ChecklistItem(
        title: "13. Power-Off Stall",
        notes:
          "Observes demo and with assist, slows to a power-off stall & recovers at first indiction",
        order: 12),
      ChecklistItem(
        title: "14. Power-Off Descent",
        notes: "Demo of simulated emergency approach & landing, practice to no lower than 500' AGL",
        order: 13),
      ChecklistItem(
        title: "15. Aileron/Rudder Coordination Exercise",
        notes: "30° bank side-to-side keeping nose within ±20° of point ", order: 14),
      ChecklistItem(
        title: "16. Go-Around Procedures",
        notes: "Practice go-around procedures at altitude (partial and full flaps)", order: 15),
      ChecklistItem(
        title: "17. Collision Avoidance",
        notes: "Aware of high threat areas, scans for traffic in climbs & before turns & maneuvers",
        order: 16),
      ChecklistItem(
        title: "18. Airport Traffic Pattern",
        notes: "With instructor assist, complies with ATC instructions or non-tower procedures",
        order: 17),
      ChecklistItem(
        title: "19. Normal and Crosswind Approach and Landing",
        notes:
          "With instructor assist, completes checklist, configures airplane, flys approach to landing",
        order: 18),
      ChecklistItem(
        title: "20. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "Uses appropriate checklists & performs all ground operations", order: 19),
    ]
  )

  static let p1L5GroundReferenceManeuvers = ChecklistTemplate(
    name: "P1-L5: Ground Reference Maneuvers",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l5_ground_reference_maneuvers",
    items: [
      ChecklistItem(
        title: "1. Risk Management and Decision Making",
        notes: "Briefs the PAVE checklist and how it relates to decisions involving this flight",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Reviews with instructor resources available to assist the pilot in flight", order: 1
      ),
      ChecklistItem(
        title: "3. Stall/Spin Awareness",
        notes:
          "Can explain what a stall is, the warning signs, how to recover, & what causes a spin",
        order: 2),
      ChecklistItem(
        title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes: "Uses appropriate checklists & performs all ground operations", order: 3),
      ChecklistItem(
        title: "5. Radio Communications",
        notes: "With minimal aids, makes all taxi, takeoff, & pre-landing calls", order: 4),
      ChecklistItem(
        title: "6. Normal and Crosswind Take Off, Departure and Climb",
        notes:
          "Tracks centerline, normal liftoff, conforms to departure, climbs ±5 kts, scans for traffic",
        order: 5),
      ChecklistItem(
        title: "7. Fundamental Maneuvers Visual Reference",
        notes:
          "Uses coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°",
        order: 6),
      ChecklistItem(
        title: "8. Crab",
        notes: "Notes impact of crosswind on ground track & applies a crab angle to stay on  track",
        order: 7),
      ChecklistItem(
        title: "9. Turns Around a Point",
        notes: "Observes demo, notes wind, checks traffic, adjusts bank to correct for wind, ±200'",
        order: 8),
      ChecklistItem(
        title: "10. Rectangular Course",
        notes:
          "Notes wind, checks traffic, applies crab for crosswind, adjusts bank in turns, ±200'",
        order: 9),
      ChecklistItem(
        title: "11. Sideslip",
        notes: "Notes crosswind, uses sideslip to keep heading & track on ground course", order: 10),
      ChecklistItem(
        title: "12. Forward Slip",
        notes:
          "Uses slip to increase descent rate while keeping track aligned with ground reference",
        order: 11),
      ChecklistItem(
        title: "13. Power-Off Stall",
        notes: "Checks traffic, slows to a straight power-off stall & recovers at first indication",
        order: 12),
      ChecklistItem(
        title: "14. Power-On Stall",
        notes:
          "With assist, takeoff airspeed, adds power, pitches up, recovers at first indication",
        order: 13),
      ChecklistItem(
        title: "15. Power-Off Descent",
        notes: "Simulated emergency approach & landing to no lower than 500' AGL, ±15 kts",
        order: 14),
      ChecklistItem(
        title: "16. Go-Around Procedures",
        notes: "Practice go-around procedures at altitude (partial and full flaps), -50'", order: 15
      ),
      ChecklistItem(
        title: "17. Airport Traffic Pattern",
        notes: "With minimal assist, complies with ATC instructions or non-tower procedures, ±150'",
        order: 16),
      ChecklistItem(
        title: "18. Normal and Crosswind Approach and Landing",
        notes:
          "With minimal assist, completes checklist, configures airplane, flies approach to landing",
        order: 17),
      ChecklistItem(
        title: "19. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "Uses appropriate checklists & performs all ground operations", order: 18),
    ]
  )

  static let p1L6EmergencyManeuvers = ChecklistTemplate(
    name: "P1-L6: Emergency Maneuvers",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l6_emergency_maneuvers",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes: "Briefs PAVE checklist flight risk factors and plan to mitigate them ", order: 0),
      ChecklistItem(
        title: "2. Situational Awareness",
        notes: "Discusses methods of reorienting if temporarily lost in the local area", order: 1),
      ChecklistItem(
        title: "3. Wake Turbulence Avoidance",
        notes:
          "Explains procedures for taking off & landing after departing & arriving large aircraft",
        order: 2),
      ChecklistItem(
        title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Appropriate checklists, positions controls for X-wind & performs all ground operations",
        order: 3),
      ChecklistItem(
        title: "5. Normal and Crosswind Take Off, Departure and Climb",
        notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic",
        order: 4),
      ChecklistItem(
        title: "6. Blocked Pitot System or Static System",
        notes: "Explains indications & procedures", order: 5),
      ChecklistItem(
        title: "7. Primary Flight Display Failure", notes: "Explains indications & procedures",
        order: 6),
      ChecklistItem(
        title: "8. Electrical System Failure", notes: "Explains indications & procedures", order: 7),
      ChecklistItem(
        title: "9. Engine Failure (at Altitude) Simulated Landing",
        notes: "Assesses situation, best glide ±10 kts, best field, memory items", order: 8),
      ChecklistItem(
        title: "10. Engine Failure in Climb After Takeoff (at Altitude)",
        notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 9),
      ChecklistItem(
        title: "11. Emergency Descent",
        notes:
          "Idle, clears area, 30-45° bank, radio call, max speed for configuration and conditions  +0/-10 kts",
        order: 10),
      ChecklistItem(
        title: "12. Engine Fire",
        notes: "Memory items, best glide ±10 kts, best field, emerg approach checklist", order: 11),
      ChecklistItem(
        title: "13. Normal and Crosswind Approach and Landing",
        notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3",
        order: 12),
      ChecklistItem(
        title: "14. Landing at Tower Controlled or Non-Tower Controlled Airport",
        notes: "Traffic pattern procedures for the situation not yet experienced (if applicable)",
        order: 13),
      ChecklistItem(
        title: "15. No Flap Landing",
        notes: "Slip as necessary,  ±10 kts, no drift, smooth touchdown, first 1/3, center 1/3",
        order: 14),
      ChecklistItem(
        title: "16. Go-Around",
        notes:
          "Immediate takeoff power, pitch for Vy, +10/-5, flaps up, offset as appropriate. (Cram, Climb, Clean)",
        order: 15),
      ChecklistItem(
        title: "17. Rejected Takeoff",
        notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 16),
      ChecklistItem(
        title: "18. Forward Slip to Landing",
        notes: "Low wing into wind, track aligned w/runway, smooth recovery to landing first 1/3",
        order: 17),
      ChecklistItem(
        title: "19. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes:
          "Appropriate checklists, positions controls for X-wind & performs all ground operations",
        order: 18),
    ]
  )

  static let p1L7NormalTakeoffAndLandings = ChecklistTemplate(
    name: "P1-L7: Normal T/O & Landings",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l7_normal_takeoff_and_landings",
    items: [
      ChecklistItem(
        title: "1. Single Pilot Resource Management",
        notes: "Briefs resources available to assist the pilot in flight", order: 0),
      ChecklistItem(
        title: "2. Risk Management",
        notes: "Briefs the PAVE checklist discussing risk factors for this flight", order: 1),
      ChecklistItem(
        title: "3. Stall/Spin Awareness",
        notes: "Briefs stall characteristics & recovery procedure & spin recognition & recovery",
        order: 2),
      ChecklistItem(
        title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Appropriate checklists, positions controls for X-wind & performs all ground operations",
        order: 3),
      ChecklistItem(
        title: "5. Normal and Crosswind Take Off, Departure and Climb",
        notes:
          "Tracks C/L, smooth liftoff, conforms to procedures, climbs +10/-5 kts, scans for traffic",
        order: 4),
      ChecklistItem(
        title: "6. Pilotage",
        notes: "Correlates position on chart with prominent local landmarks & airspace", order: 5),
      ChecklistItem(
        title: "7. Steep Turns",
        notes:
          "Observes demo, 360° turns left and right, alt ±250', hdg ±20°, a/s ±10 kts, bank ±10°",
        order: 6),
      ChecklistItem(
        title: "8. Slow Flight (Straight & Level, Turns, Climbs, Descents)",
        notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°",
        order: 7),
      ChecklistItem(
        title: "9. Power-Off Stall",
        notes:
          "Clears traffic, power-off full stall, 15° bank turn ±10°,  prompt AOA, power & level wings",
        order: 8),
      ChecklistItem(
        title: "10. Descent at Approach Airspeed in Landing Configuration",
        notes: "Simulated stabilized approach to flare & go-around at altitude, a/s +10/-5 kts",
        order: 9),
      ChecklistItem(
        title: "11. Rectangular Course",
        notes: "Notes wind, checks traffic, parallel to reference, adjusts bank in turns, ±150'",
        order: 10),
      ChecklistItem(
        title: "12. S-Turns",
        notes: "Observes demo, notes wind, checks traffic, adjusts bank to correct for wind, ±150'",
        order: 11),
      ChecklistItem(
        title: "13. Straight and Level and Standard Rate Turns to a Heading (IR)",
        notes: "Under control, coordinated, alt ±200', hdg ±15°, a/s ±10 kts, bank ±10°", order: 12),
      ChecklistItem(
        title: "14. Airport Traffic Pattern",
        notes: "Radio calls, complies with instructions and/or procedures, alt ±100'", order: 13),
      ChecklistItem(
        title: "15. Normal Approach Landing (Full Stop)",
        notes:
          "Min. 3 landings to full stop, stabilized, +10/-5 kts, lands center 1/3, landing attitude",
        order: 14),
      ChecklistItem(
        title: "16. Go-Around Procedures",
        notes: "Execute go-arounds from base, final, and start of flare with minimal altitude loss",
        order: 15),
      ChecklistItem(
        title: "17. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes:
          "Appropriate checklists, positions controls for X-wind & performs all ground operations",
        order: 16),
    ]
  )

  static let p1L8CrosswindTakeoffAndLanding = ChecklistTemplate(
    name: "P1-L8: Crosswind T/O & Landing",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l8_crosswind_takeoff_and_landing",
    items: [
      ChecklistItem(
        title: "1. Single Pilot Resource Management",
        notes: "Briefs resources available for assistance during this flight", order: 0),
      ChecklistItem(
        title: "2. Risk Management",
        notes:
          "Briefs PAVE checklist flight risk factors including required runway for takeoff & landing ",
        order: 1),
      ChecklistItem(
        title: "3. Wake Turbulence Avoidance",
        notes:
          "Explains procedures for taking off & landing after departing & arriving large aircraft",
        order: 2),
      ChecklistItem(
        title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Appropriate checklists, positions controls for X-wind & performs all ground operations",
        order: 3),
      ChecklistItem(
        title: "5. Normal and Crosswind Take Off, Departure and Climb",
        notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic",
        order: 4),
      ChecklistItem(
        title: "6. Pilotage",
        notes: "Correlates position on chart with prominent local landmarks & airspace", order: 5),
      ChecklistItem(
        title: "7. Steep Turns",
        notes:
          "Clears area, 360° turns both directions, alt ±200', hdg ±20°, a/s ±10 kts, bank ±10°",
        order: 6),
      ChecklistItem(
        title: "8. Slow Flight (Straight & Level, Turns, Climbs, Descents)",
        notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°",
        order: 7),
      ChecklistItem(
        title: "9. Forward Slip Left and Right (at altitude)",
        notes:
          "Stable pitch attitude, track aligned with ground reference, recovers approach at altitude",
        order: 8),
      ChecklistItem(
        title: "10. Ground Reference Maneuvers",
        notes:
          "Checks for traffic & obstructions, alt ±150', corrects for wind in straight & turning flight",
        order: 9),
      ChecklistItem(
        title: "11. Demonstration of Faulty Approach and Landing and Corrections",
        notes: "Observes instructor demo of correction & go-around for approach & landing errors",
        order: 10),
      ChecklistItem(
        title: "12. Normal Approach and Landing",
        notes: "Stabilized, +10/-5 kts, touchdown first 1/3,  center 1/3, landing attitude",
        order: 11),
      ChecklistItem(
        title: "13. Forward Slip to Landing",
        notes: "Low wing into wind, ground track aligned with runway, recovers from slip for flare",
        order: 12),
      ChecklistItem(
        title: "14. Sideslip Exercise Over Runway",
        notes:
          "Observes demo, 5-10' above & parallel to runway, sideslip one side to other, go-around",
        order: 13),
      ChecklistItem(
        title: "15. Crosswind Landing (Full Stop)",
        notes:
          "Min. 3 , tracks C/L, lands center 1/3, parallel to runway, +10/-5 kts, landing attitude",
        order: 14),
      ChecklistItem(
        title: "16. Go-Around",
        notes:
          "Immediate takeoff power, pitch for Vy , +10/-5, retract flaps, offset as appropriate (Cram Climb, Clean)",
        order: 15),
      ChecklistItem(
        title: "17. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes:
          "Appropriate checklists, positions controls for X-wind & performs all ground operations",
        order: 16),
    ]
  )

  static let p1L9ManeuverReview = ChecklistTemplate(
    name: "P1-L9: Maneuver Review",
    category: "PPL",
    phase: "Phase 1",
    templateIdentifier: "default_p1_l9_maneuver_review",
    items: [
      ChecklistItem(
        title: "1. Risk Managment",
        notes: "Using PAVE checklist briefs risk factors for this flight & how to mitigate them ",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Explains resources available for assistance during this flight", order: 1),
      ChecklistItem(
        title: "3. Situational Awareness",
        notes: "Explains methods of reorienting if lost or disoriented", order: 2),
      ChecklistItem(
        title: "4. Stall/Spin Awareness",
        notes: "Explains stall & spin causes, characteristics & recovery procedures", order: 3),
      ChecklistItem(
        title: "5. Wake Turbulence Avoidance",
        notes:
          "Explains procedures for taking off & landing after departing & arriving large aircraf t",
        order: 4),
      ChecklistItem(
        title: "6. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls",
        order: 5),
      ChecklistItem(
        title: "7. Radio Communications",
        notes:
          "Makes all appropriate calls, understands or requests clarification for instructions",
        order: 6),
      ChecklistItem(
        title: "8. Collision Avoidance",
        notes: "Clears traffic before all operations on the ground & airborne ", order: 7),
      ChecklistItem(
        title: "9. Normal and Crosswind Take Off, Departure and Climb",
        notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic",
        order: 8),
      ChecklistItem(
        title: "10. Fundamental Maneuvers VR (Straight & Level, Turns, Climbs, Descents) ",
        notes: "Coordinated controls, in trim, alt ±100', hdg ±10°, a/s ±10 kts, bank ±10°",
        order: 9),
      ChecklistItem(
        title: "11. Fundamental Maneuvers IR (Straight & Level, Turns, Climbs, Descents)",
        notes: "Coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°",
        order: 10),
      ChecklistItem(
        title: "12. Steep Turns",
        notes: "Clears area, 360° L&R, coordinated, alt ±150', hdg ±15°, a/s ±10 kts, bank ±10°",
        order: 11),
      ChecklistItem(
        title: "13. Slow Flight (Straight & Level, Turns, Climbs, Descents)",
        notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°",
        order: 12),
      ChecklistItem(
        title: "14. Power-Off and Power-On Stall",
        notes: "Clears area, full stall, 15° bank turn ±10°,  prompt AOA, power & level wings",
        order: 13),
      ChecklistItem(
        title: "15. Engine Failures at Altitude and in Climb ",
        notes: "Assesses situation, best glide ±10 kts, best field, memory items", order: 14),
      ChecklistItem(
        title: "16. Ground Reference Maneuvers",
        notes:
          "Checks for traffic & obstructions, alt ±150', corrects for wind in straight & turning flight",
        order: 15),
      ChecklistItem(
        title: "17. Normal and Crosswind Approach and Landing",
        notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3",
        order: 16),
      ChecklistItem(
        title: "18. No Flap Landing",
        notes: "Slip as necessary,  ±10 kts, no drift, smooth touchdown, first 1/3, center 1/3",
        order: 17),
      ChecklistItem(
        title: "19. Rejected Takeoff",
        notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 18),
      ChecklistItem(
        title: "20. Go-Around",
        notes:
          "Immediate takeoff power, pitch for Vy , +10/-5, flaps up, offset as appropriate (Cram, Climb, Clean)",
        order: 19),
      ChecklistItem(
        title: "21. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "All operations correct & accurate w/checklists, taxi proper speed & controls",
        order: 20),
    ]
  )

  // MARK: - Phase 2 Templates

  static let p2L1ReviewAndSecondSolo = ChecklistTemplate(
    name: "P2-L1: Review & second Solo",
    category: "PPL",
    phase: "Phase 2",
    templateIdentifier: "default_p2_l1_review_and_second_solo",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes: "Using PAVE checklist briefs risk factors for this flight & how to mitigate them ",
        order: 0),
      ChecklistItem(
        title: "2. Wake Turbulence Avoidance",
        notes:
          "Explains procedures for taking off & landing after departing & arriving large aircraft",
        order: 1),
      ChecklistItem(
        title: "3. Cockpit Management",
        notes:
          "Checks safety equipment, all loose items secured, organizes all material to be readily accessible",
        order: 2),
      ChecklistItem(
        title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls",
        order: 3),
      ChecklistItem(
        title: "5. Normal and Crosswind Takeoff, Departure and Climb",
        notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic",
        order: 4),
      ChecklistItem(
        title: "6. Engine Failure in Climb After Takeoff (at Altitude)",
        notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 5),
      ChecklistItem(
        title: "7. Pilotage to and from Practice Area",
        notes: "Navigates most suitable route to and from practice area using chart & landmarks ",
        order: 6),
      ChecklistItem(
        title: "8. Slow Flight (Straight & Level, Turns, Climbs, Descents)",
        notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°",
        order: 7),
      ChecklistItem(
        title: "9. Power-Off and Power-On Stalls",
        notes:
          "Clears area, full stall, 15° bank turn ±10°,  prompt lower AOA, power & level wings",
        order: 8),
      ChecklistItem(
        title: "10. Steep Turns",
        notes:
          "Clears area, 360° turns both directions, alt ±100', a/s ±10 kts, bank ±5°, hdg ±10°",
        order: 9),
      ChecklistItem(
        title: "11. Engine Fire in Flight, Emergency Descent and Landing (Simulated)",
        notes:
          "Fire memory items, emerg descent config, best glide ±10 kts, best field, emerg approach checklist",
        order: 10),
      ChecklistItem(
        title: "12. Normal and Crosswind Approach and Landing",
        notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3",
        order: 11),
      ChecklistItem(
        title: "13. Forward Slip to Landing",
        notes: "Low wing into wind, ground track aligned with runway, recovers from slip for flare",
        order: 12),
      ChecklistItem(
        title: "14. Normal Takeoff and Climb (Solo)",
        notes:
          "Radio calls, X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic",
        order: 13),
      ChecklistItem(
        title: "15. Pilotage to Practice or Designated Area within 10 NM (Solo)",
        notes: "Navigates most suitable route to practice area using chart & landmarks ", order: 14),
      ChecklistItem(
        title: "16. Steep Turns (Solo)",
        notes:
          "Clears practice area, 360° turns both directions, alt ±100', a/s ±10 kts, bank ±5°, hdg ±10°",
        order: 15),
      ChecklistItem(
        title: "17. Pilotage from Practice or Designated Area (Solo)",
        notes:
          "Navigates most suitable route from practice area to airport using chart & landmarks ",
        order: 16),
      ChecklistItem(
        title: "18. Airport Traffic Pattern (Solo)",
        notes: "Appropriate radio calls, complies with instructions and/or procedures, alt ±100'",
        order: 17),
      ChecklistItem(
        title: "19. Normal Approach and Landing (Solo)", notes: "3 landings to full stop", order: 18
      ),
      ChecklistItem(
        title: "20. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "All operations correct & accurate w/checklists, taxi proper speed & controls",
        order: 19),
    ]
  )

  static let p2L2ShortFieldTakeoffAndLanding = ChecklistTemplate(
    name: "P2-L2: Short Field T/O & Landing",
    category: "PPL",
    phase: "Phase 2",
    templateIdentifier: "default_p2_l2_short_field_takeoff_and_landing",
    items: [
      ChecklistItem(
        title: "1. Calculate Takeoff and Landing Performance",
        notes:
          "Notes variances with daily high/low temps, uses conservative data & margin for skill/airplane ",
        order: 0),
      ChecklistItem(
        title: "2. Risk Management",
        notes: "Briefs PAVE checklist focusing on performance and runway factors", order: 1),
      ChecklistItem(
        title: "3. Windshear Awareness and Recovery",
        notes: "Explains windshear conditions, indications and recovery procedures", order: 2),
      ChecklistItem(
        title: "4. Stall/Spin Awareness",
        notes: "Explains stall & spin causes, characteristics & recovery procedures", order: 3),
      ChecklistItem(
        title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls",
        order: 4),
      ChecklistItem(
        title: "6. Short Field Takeoff and Climb",
        notes:
          "Observes demo, notes where 50' & 100' AGL, config, lift off a/s per AFM/POH , pitch to Vx",
        order: 5),
      ChecklistItem(
        title: "7. Engine Failure in Climb After Takeoff (at Altitude)",
        notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 6),
      ChecklistItem(
        title:
          "8. Slow Flight with Realistic Distractions (Straight & Level, Turns, Climbs, Descents)",
        notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +10/-0 kts, bank ±10°",
        order: 7),
      ChecklistItem(
        title: "9. Power-Off Stall",
        notes:
          "Clears area, full stall, 15° bank turn ±10°, coordinated, prompt lower AOA, power & level wings",
        order: 8),
      ChecklistItem(
        title: "10. Power-On Stall",
        notes:
          "Clears area, full stall, 15° bank turn ±10°, coordinated , prompt lower AOA, power & level wings",
        order: 9),
      ChecklistItem(
        title: "11. Rectangular Course",
        notes:
          "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight",
        order: 10),
      ChecklistItem(
        title: "12. Turns Around a Point",
        notes:
          "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight",
        order: 11),
      ChecklistItem(
        title: "13. S-Turns",
        notes:
          "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight",
        order: 12),
      ChecklistItem(
        title: "14. Short Field Approach and Landing",
        notes:
          "Observes demo, stabilized approach +10/-5 kts, touches down  +400'/-0', stops in shortest distance",
        order: 13),
      ChecklistItem(
        title: "15. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "All operations correct & accurate w/checklists, taxi proper speed & controls",
        order: 14),
    ]
  )

  static let p2L3BuildingSkillWithManeuversAndLandings = ChecklistTemplate(
    name: "P2-L3: Building skill with Maneuvers and Landings",
    category: "PPL",
    phase: "Phase 2",
    templateIdentifier: "default_p2_l3_building_skill_with_maneuvers_and_landings",
    items: [
      ChecklistItem(
        title: "1. Calculate Takeoff and Landing Performance",
        notes:
          "Notes variances with daily high/low temps, uses conservative data & margin for skill/airplane ",
        order: 0),
      ChecklistItem(
        title: "2. Calculate Weight and Balance",
        notes: "Notes difference in CG location from dual flights", order: 1),
      ChecklistItem(
        title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls",
        order: 2),
      ChecklistItem(
        title: "4. Normal and Crosswind Takeoff, Departure and Climb",
        notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic",
        order: 3),
      ChecklistItem(
        title: "5. Pilotage to Practice Area",
        notes: "Navigates most suitable route to practice area using chart & landmarks", order: 4),
      ChecklistItem(
        title: "6. Steep Turns",
        notes:
          "Clears area, 360° turns both directions, alt ±100', a/s ±10 kts, bank ±5°, hdg ±10°",
        order: 5),
      ChecklistItem(
        title: "7. Rectangular Course",
        notes:
          "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight",
        order: 6),
      ChecklistItem(
        title: "8. Turns Around a Point",
        notes:
          "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight",
        order: 7),
      ChecklistItem(
        title: "9. S-Turns",
        notes:
          "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight",
        order: 8),
      ChecklistItem(
        title: "10. Pilotage from Practice Area",
        notes:
          "Navigates most suitable route from practice area to airport using chart & landmarks ",
        order: 9),
      ChecklistItem(
        title: "11. Airport Traffic Pattern",
        notes:
          "Appropriate entry, radio calls, complies with instructions and/or procedures, alt ±100'",
        order: 10),
      ChecklistItem(
        title: "12. Forward Slip to Landing",
        notes: "Low wing into wind, ground track aligned with runway, recovers from slip for flare",
        order: 11),
      ChecklistItem(
        title: "13. Normal Approach and Landing", notes: "3 landings to full stop", order: 12),
      ChecklistItem(
        title: "14. Go-Around",
        notes: "Immediate takeoff power, pitch for Vy, +10/-5, flaps up, offset as appropriate",
        order: 13),
      ChecklistItem(
        title: "15. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "All operations correct & accurate w/checklists, taxi proper speed & controls",
        order: 14),
    ]
  )

  static let p2L4SoftFieldTakeoffAndLandings = ChecklistTemplate(
    name: "P2-L4: Soft Field T/O & Landings",
    category: "PPL",
    phase: "Phase 2",
    templateIdentifier: "default_p2_l4_soft_field_takeoff_and_landings",
    items: [
      ChecklistItem(
        title: "1. Calculate Takeoff and Landing Performance",
        notes:
          "Applies factors for soft runway surface, uses conservative data & margin for skill/airplane ",
        order: 0),
      ChecklistItem(
        title: "2. Risk Management",
        notes: "Briefs PAVE checklist focusing on performance and runway factors", order: 1),
      ChecklistItem(
        title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls",
        order: 2),
      ChecklistItem(
        title: "4. Taxiing for Soft Field Takeoff",
        notes:
          "Positions controls X-wind & light nose, clears area, maintains safe speed without stopping",
        order: 3),
      ChecklistItem(
        title: "5. Soft Field Takeoff and Climb",
        notes:
          "Planned no-go, controls & config set, earliest possible lift off, ground effect until Vx/Vy , +10/-5 ",
        order: 4),
      ChecklistItem(
        title: "6. Rejected Takeoff",
        notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 5),
      ChecklistItem(
        title: "7. Engine Failure in Climb After Takeoff",
        notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 6),
      ChecklistItem(
        title:
          "8. Slow Flight with Realistic Distractions (Straight & Level, Turns, Climbs, Descents)",
        notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +10/-0 kts, bank ±10°",
        order: 7),
      ChecklistItem(
        title: "9. Power-Off Stall",
        notes:
          "Clears area, full stall, 15° bank turn ±10°, coordinated, prompt lower AOA, power & level wings",
        order: 8),
      ChecklistItem(
        title: "10. Power-On Stall",
        notes:
          "Clears area, full stall, 15° bank turn ±10°, coordinated , prompt lower AOA, power & level wings",
        order: 9),
      ChecklistItem(
        title: "11. Engine Fire in Flight, Emergency Descent and Landing (Simulated)",
        notes:
          "Fire memory items, emerg descent config, best glide ±10 kts, best field, emerg approach checklist",
        order: 10),
      ChecklistItem(
        title: "12. S-Turns",
        notes:
          "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight",
        order: 11),
      ChecklistItem(
        title: "13. Soft Field Approach and Landing",
        notes: "Observes demo, stabilized approach +10/-5 kts, touches down softly", order: 12),
      ChecklistItem(
        title: "14. Short Field Takeoff and Climb",
        notes:
          "Briefs no-go, config., lift off & airspeed per AFM/POH , pitches to Vx until obstacle cleared ",
        order: 13),
      ChecklistItem(
        title: "15. Short Field Approach and Landing",
        notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance",
        order: 14),
      ChecklistItem(
        title: "16. Go-Around",
        notes: "Immediate takeoff power, pitch for Vy , +10/-5, flaps up, offset as appropriate",
        order: 15),
      ChecklistItem(
        title: "17. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "All operations correct & accurate w/checklists, taxi proper speed & controls",
        order: 16),
    ]
  )

  static let p2L5Phase2Overview = ChecklistTemplate(
    name: "P2-L5: Phase 2 Overview",
    category: "PPL",
    phase: "Phase 2",
    templateIdentifier: "default_p2_l5_phase_2_overview",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes:
          "Briefs PAVE checklist including W&B, fuel, & performance, use of the CARE checklist in-flight",
        order: 0),
      ChecklistItem(
        title: "2. Emergency Equipment and Survival Gear",
        notes:
          "Explains location and use of emergency equipment, evaluates adequacy for this flight",
        order: 1),
      ChecklistItem(
        title: "3. Single Pilot Resource Management",
        notes: "Briefs planned use of available resources during flight", order: 2),
      ChecklistItem(
        title: "4. Flight Planning ",
        notes:
          "Briefs planned route, checkpoints, alternates, weather, NOTAMS, airspace, terrain, navigation log ",
        order: 3),
      ChecklistItem(
        title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass",
        order: 4),
      ChecklistItem(
        title: "6. Short Field Takeoff, Climb and Departure",
        notes:
          "No-go, config., liftoff a/s per POH/AFM, Vx ± 5 kts until obstacle cleared, turns to heading",
        order: 5),
      ChecklistItem(
        title: "7. FSS and ATC Radar Service",
        notes:
          "Opens flight plan with FSS and contacts appropriate ATC facility for VFR Flight Following",
        order: 6),
      ChecklistItem(
        title: "8. En Route Cruise",
        notes:
          "Uses power & mixture settings per POH/AFM, TAS and Fuel Flow planning, hdg ±10°, alt ±100'",
        order: 7),
      ChecklistItem(
        title: "9. Navigation (DR, Pilotage, VOR and GPS)",
        notes:
          "Keeps nav log, uses DR, pilotage & electronic nav, track within 2 nm of course, ETA ±3 min",
        order: 8),
      ChecklistItem(
        title: "10. Cockpit Management",
        notes: "Equipment and materials organized, easily accessible and restrained", order: 9),
      ChecklistItem(
        title: "11. Task Management",
        notes: "Prioritizes and manages tasks by selecting the most appropriate for the moment ",
        order: 10),
      ChecklistItem(
        title: "12. Collision Avoidance",
        notes:
          "Divides attention among all tasks making sure that looking for traffic is not abandoned ",
        order: 11),
      ChecklistItem(
        title: "13. Heading Indicator Failure ",
        notes: "Simulated HI failure, use compass for headings, hdg ±10°", order: 12),
      ChecklistItem(
        title: "14. Electrical Failure ",
        notes:
          "Simulated emergency, reverts to DR & pilotage, decides go to destination, alternate, or return",
        order: 13),
      ChecklistItem(
        title: "15. Lost Procedures",
        notes:
          "Instructor introduces realistic distractions requiring use of lost procedures for reorientation",
        order: 14),
      ChecklistItem(
        title: "16. Diversion to an Alternate",
        notes:
          "Scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel, advises ATC",
        order: 15),
      ChecklistItem(
        title: "17. Short Field Approach and Landing",
        notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance",
        order: 16),
      ChecklistItem(
        title: "18. Soft Field Takeoff, Climb and Departure ",
        notes:
          "No-go, controls/config set, earliest liftoff, ground effect until Vx/Vy , +10/-5, turns to heading ",
        order: 17),
      ChecklistItem(
        title: "19. Soft Field Approach and Landing",
        notes:
          "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction",
        order: 18),
      ChecklistItem(
        title: "20. No Flap Landing",
        notes: "Slip as necessary, ±10 kts, no drift, smooth touchdown, first 500'", order: 19),
      ChecklistItem(
        title: "21. After Landing, Taxi, Parking, Post Flight Procedures and Refueling",
        notes:
          "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan",
        order: 20),
    ]
  )

  // MARK: - Pre-Solo/Solo Templates

  static let preSoloQuizAndDocuments = ChecklistTemplate(
    name: "Pre-Solo Quiz & Documents",
    category: "PPL",
    phase: "Phase 1.5 Pre-Solo/Solo",
    templateIdentifier: "default_pre_solo_quiz_and_documents",
    items: [
      ChecklistItem(
        title: "1. Administer, Grade, and Correct pre-solo quiz", notes: "Pass is 100% corrected",
        order: 0),
      ChecklistItem(
        title: "2. Medical Certificate", notes: "1st, 2nd, or 3rd class medical clearance", order: 1
      ),
      ChecklistItem(title: "3. Student Pilot Certificate", notes: "Uploaded", order: 2),
    ]
  )

  static let preSoloTrainingCheckoff = ChecklistTemplate(
    name: "Pre-Solo Training Checkoff (61.87)",
    category: "PPL",
    phase: "Phase 1.5 Pre-Solo/Solo",
    templateIdentifier: "default_pre_solo_training_checkoff",
    items: [
      ChecklistItem(
        title:
          "1. Proper flight preparation procedures including, Preflight planning, Powerplant operations, and aircraft systems",
        notes: "", order: 0),
      ChecklistItem(
        title: "2. Taxiing or surface operations, including runups", notes: "To be filled in later",
        order: 1),
      ChecklistItem(
        title: "3. Takeoffs and landings, including normal and crosswind", notes: "", order: 2),
      ChecklistItem(
        title: "4. Straight and Level flight, and turns in both directions", notes: "", order: 3),
      ChecklistItem(title: "5. Climbs and climbing turns", notes: "", order: 4),
      ChecklistItem(
        title: "6. Airport traffic patterns, including entry and departure procedures", notes: "",
        order: 5),
      ChecklistItem(
        title: "7. Collision avoidance, wind-sheer avoidance, and wake turbulance avoidance",
        notes: "", order: 6),
      ChecklistItem(
        title: "8. Descents, with and without turns, using high and low drag configurations",
        notes: "", order: 7),
      ChecklistItem(
        title: "9. Flight at various airspeeds from cruise to slow flight", notes: "", order: 8),
      ChecklistItem(
        title:
          "10. Stall entries from various flight attitudes and power combinations with recovery initiated at the first indication of a stall",
        notes: "", order: 9),
      ChecklistItem(
        title: "11. Emergency procedures and equipment malfunctions", notes: "", order: 10),
      ChecklistItem(title: "12. Ground reference maneuvers", notes: "", order: 11),
      ChecklistItem(
        title: "13. Approaches to a landing with simulated engine malfunctions", notes: "",
        order: 12),
      ChecklistItem(title: "14. Slips to a landing", notes: "", order: 13),
      ChecklistItem(title: "15. Go-Arounds", notes: "", order: 14),

    ]
  )

  static let firstSolo = ChecklistTemplate(
    name: "First Solo",
    category: "PPL",
    phase: "Phase 1.5 Pre-Solo/Solo",
    templateIdentifier: "default_first_solo",
    items: [
      ChecklistItem(
        title: "1. Risk Managment",
        notes: "Using PAVE checklist, brief risk factors for this flight & how to mitigate them",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Managment",
        notes: "Explains resources available for assistance during this flight", order: 1),
      ChecklistItem(
        title: "3. Aircraft Perfomance and Weight and Balance",
        notes:
          "Briefs takeoff and landing runway required, climb rate, and dual and solo weight & balance.",
        order: 2),
      ChecklistItem(
        title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Briefs Safety Items, Correct Accurate Steps with Checklists, Proper Taxi Speed and Controls",
        order: 3),
      ChecklistItem(
        title: "5. Radio Communications",
        notes:
          "Makes all appropriate calls, understands or requests clarification for instructions.",
        order: 4),
      ChecklistItem(
        title: "6. Collision Avoidance",
        notes: "Clears traffic before all operations on the ground and airborne.", order: 5),
      ChecklistItem(
        title: "7. Normal and Crosswind Takeoff, Departure and Climb",
        notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic",
        order: 6),
      ChecklistItem(
        title: "8. Pilotage to Practice Area",
        notes: "Navigates the most suitable route to practice area using chart and landmarks.",
        order: 7),
      ChecklistItem(
        title: "9. Ground Reference Maneuvers",
        notes:
          "Checks for traffic & Obstructions, alt ±150', corrects for wind in straight & turning flight.",
        order: 8),
      ChecklistItem(
        title: "10. Airport Traffic Pattern",
        notes:
          "Appropriate radio calls complies with instructions and/or procedures. Altitude +/- 100'.",
        order: 9),
      ChecklistItem(
        title: "11. Normal Approach and Landing",
        notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3",
        order: 10),
      ChecklistItem(
        title: "12. Go-Around",
        notes:
          "Immediate takeoff power, pitch for Vy, +10/-5, Flaps up, offset as appropriate. (Cram clean climb).",
        order: 11),
      ChecklistItem(
        title: "13. Logbook and Certificate Endorsements",
        notes: "Instructor makes appropriate entries and explains limitations.", order: 12),
      ChecklistItem(
        title: "14. Radio Communications (Solo)",
        notes:
          "Makes all appropriate calls, understands, or requests clarification for instructions.",
        order: 13),
      ChecklistItem(
        title: "15. Airport Ground and Taxi Operations (Solo)",
        notes: "Radio calls complies with instructions and/or procedures.", order: 14),
      ChecklistItem(
        title: "16. Normal Takeoff, Climb to Ramin in Pattern (Solo)",
        notes: "Radio calls, complies with instructions and/or procedures, Altitude ±100'.",
        order: 15),
      ChecklistItem(
        title: "17. Airport Traffic Pattern (Solo)",
        notes:
          "Appropriate radio calls complies with instructions and/or procedures Altitude ±100'",
        order: 16),
      ChecklistItem(
        title: "18. Normal Approach and Landing (Solo)", notes: "3 landings to full stop.",
        order: 17),
      ChecklistItem(
        title: "19. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "All operations correct & accurate w/checklists, taxi proper speed & controls.",
        order: 18),
    ]
  )

  static let soloEndorsements = ChecklistTemplate(
    name: "Solo Endorsements",
    category: "PPL",
    phase: "Phase 1.5 Pre-Solo/Solo",
    templateIdentifier: "default_solo_endorsements",
    items: [
      ChecklistItem(
        title: "1. Pre-solo aeronautical knowledge 61.87(b)",
        notes:
          "I certify that (first, middle, last) has satisfactorily completed the pre-solo knowledge test of 61.87(b) for the [make and model] aircraft.",
        order: 0),
      ChecklistItem(
        title: "2. Pre-solo flight training 61.87(c)(1)(2) and 61.87(d)",
        notes:
          "I certify that (first, middle, last) has received and logged pre-solo flight training for, the maneuvers and procedures that are appropriate to make the [make and model] aircraft. I have determined that (he or she) has demonstrated satisfactory proficiency and safety on the maneuvers and procedures required by 61.87 in this or similar make and model of aircraft to be flown.",
        order: 1),
      ChecklistItem(
        title: "3. Solo flight 61.87(n)",
        notes:
          "I certify that (first, middle, last) has received the required training to qualify for solo flying. I have determined that he or she meets the applicable requirements of 61.87(n) and is proficient to make solo flights in the (make and model).",
        order: 2),
      ChecklistItem(
        title: "4. Solo flight at night 61.87(o)",
        notes:
          "I certify that (first, middle, last) has received the required training to qualify for solo flight at night. I have determined that he or she meets the applicable requirements of 61.87(o) and is proficient to make solo flights at night in the (make and model).",
        order: 3),
    ]
  )

  // MARK: - Phase 3 Templates

  static let p3L10LongXcSoloBriefing = ChecklistTemplate(
    name: "P3-L10: >150nm long Xc Solo Briefing",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l10_long_xc_solo_briefing",
    items: [
      ChecklistItem(
        title: "1. Logbook and Certificate Endorsements and Required Documents",
        notes:
          "Understands the required endorsements, student pilot privileges & specific instructor restrictions",
        order: 0),
      ChecklistItem(
        title: "2. Route Briefing",
        notes:
          "Briefs route, checkpoints, airspace, terrain, boundaries, cross-checks, altitudes, VORs, alternates",
        order: 1),
      ChecklistItem(
        title: "3. Weather briefing",
        notes:
          "Departure, en route, destinations & alternates (current & forecast), NOTAMS, what ifs for delays",
        order: 2),
      ChecklistItem(
        title: "4. Destinations/Alternates Facilities",
        notes:
          "Briefs ATC or CTAF procedures/frequencies, runways, taxiways, servicing, NavAids, NOTAMS",
        order: 3),
      ChecklistItem(
        title: "5. Navigation Plan",
        notes:
          "Briefs charts & pubs (current), methods of navigation, nav log, times, fuel reserves",
        order: 4),
      ChecklistItem(
        title: "6. Risk Management",
        notes: "Briefs the PAVE checklist and how to employ the in-flight CARE checklist", order: 5),
      ChecklistItem(
        title: "7. Single Pilot Resource Management",
        notes:
          "Briefs resources available for assistance in and outside the cockpit including en route weather",
        order: 6),
      ChecklistItem(
        title: "8. Lost Procedures", notes: "Briefs steps to follow if unsure of position", order: 7
      ),
      ChecklistItem(
        title: "9. Weight and Balance and Performance",
        notes:
          "Briefs takeoff & landing W&B, takeoff & landing runway required, power settings & performance",
        order: 8),
      ChecklistItem(
        title: "10. Emergency Equipment and Survival Gear",
        notes: "Explains location and use of emergency equipment & its adequacy for this flight",
        order: 9),
      ChecklistItem(
        title: "11. Emergency Operations",
        notes:
          "Briefs what ifs of engine failure, engine fire, rough engine, electrical failure, NORDO",
        order: 10),
      ChecklistItem(
        title: "12. FSS and ATC Radar Service",
        notes:
          "Files, opens & closes flight plan with FSS for each leg, employs VFR Flight Following (if available) ",
        order: 11),
      ChecklistItem(
        title: "13. En Route Landings",
        notes: "Full stop landing each destination, refueling (as necessary), weather briefing",
        order: 12),
      ChecklistItem(
        title: "14. After Landing, Taxi, Parking, Post Flight Procedures and Refueling",
        notes:
          "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan",
        order: 13),
      ChecklistItem(
        title: "15. Postflight Navigation Log and Conditions Review",
        notes:
          "Briefs instructor on planned versus actual GS, ETE, fuel used, track, airport operations & weather ",
        order: 14),
    ]
  )

  static let p3L1PilotageAndDRCrossCountry = ChecklistTemplate(
    name: "P3-L1: Pilotage and DR Cross-Country >50nm",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l1_pilotage_and_dr_cross_country",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes:
          "Briefs PAVE checklist for this flight and use of the CARE checklist during the flight",
        order: 0),
      ChecklistItem(
        title: "2. Emergency Equipment and Survival Gear",
        notes:
          "Explains location and use of emergency equipment, evaluates adequacy for this flight",
        order: 1),
      ChecklistItem(
        title: "3. Weight and Balance and Performance Calculations",
        notes:
          "Briefs load limits and takeoff/land runway requirements and climb and cruise performance",
        order: 2),
      ChecklistItem(
        title: "4. Flight Planning",
        notes:
          "Briefs planned route, checkpoints, alternates, weather, NOTAMS, airspace, terrain, navigation log",
        order: 3),
      ChecklistItem(
        title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass",
        order: 4),
      ChecklistItem(
        title: "6. Short Field Takeoff, Climb and Departure ",
        notes:
          "No-go, config., liftoff a/s per POH/AFM, V X  ± 5 kts until obstacle cleared, turns to heading",
        order: 5),
      ChecklistItem(
        title: "7. Open Prefiled Flight Plan",
        notes: "Determines correct FSS frequency, establishes contact, opens flight plan", order: 6),
      ChecklistItem(
        title: "8. En Route Cruise",
        notes:
          "Uses power & mixture settings per POH/AFM, TAS and Fuel Flow planning, hdg ±10°, alt ±100'",
        order: 7),
      ChecklistItem(
        title: "9. Pilotage",
        notes:
          "Identifies landmarks by relating surface features to chart symbols, verifies position within 3 nm",
        order: 8),
      ChecklistItem(
        title: "10. DR and Navigation Log",
        notes: "Records ATA, calculates ETEs , GS, fuel, wind & changes to ETA", order: 9),
      ChecklistItem(
        title: "11. Magnetic Compass",
        notes: "Simulated HI failure, use compass for headings, hdg ±15°", order: 10),
      ChecklistItem(
        title: "12. Cockpit Management",
        notes: "Equipment and materials organized, easily accessible and restrained", order: 11),
      ChecklistItem(
        title: "13. Task Management",
        notes: "Prioritizes and manages tasks by selecting the most appropriate for the moment ",
        order: 12),
      ChecklistItem(
        title: "14. Collision Avoidance",
        notes:
          "Divides attention among all tasks making sure that looking for traffic is not abandoned",
        order: 13),
      ChecklistItem(
        title: "15. Lost Procedures",
        notes:
          "nstructor introduces realistic distractions requiring use of lost procedures for reorientation",
        order: 14),
      ChecklistItem(
        title: "16. Diversion to an Alternate",
        notes:
          "Instructor scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel",
        order: 15),
      ChecklistItem(
        title: "17. Airport Traffic Pattern",
        notes:
          "Appropriate entry, radio calls, complies with instructions and/or procedures, alt ±100'",
        order: 16),
      ChecklistItem(
        title: "18. Short Field Approach and Landing",
        notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance",
        order: 17),
      ChecklistItem(
        title: "19. Soft Field Takeoff, Climb and Departure",
        notes:
          "No-go, controls/config set, earliest liftoff, ground effect until Vx /Vy , +10/-5, turns to heading",
        order: 18),
      ChecklistItem(
        title: "20. Soft Field Approach and Landing",
        notes:
          "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction",
        order: 19),
      ChecklistItem(
        title: "21. After Landing, Taxi, Parking, Post Flight Procedures and Refueling",
        notes:
          "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan",
        order: 20),
    ]
  )

  static let p3L2NavigationAids = ChecklistTemplate(
    name: "P3-L2: Navigation Aids",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l2_navigation_aids",
    items: [
      ChecklistItem(
        title: "1. Risk Management", notes: "Briefs PAVE checklist for this flight", order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Utilizes all available resources during flight", order: 1),
      ChecklistItem(
        title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass",
        order: 2),
      ChecklistItem(
        title: "4. Electronic Flight Plan",
        notes:
          "Enters proscribed flight plan into installed or portable system, checks accuracy, saves",
        order: 3),
      ChecklistItem(
        title: "5. Soft Field Takeoff and Climb ",
        notes: "No-go, controls/config set, earliest liftoff, ground effect until V /V , +10/-5",
        order: 4),
      ChecklistItem(
        title: "6. VOR Orientation and Tracking VR",
        notes:
          "Tunes & ID,  finds radial, fix w/X-radials, intercepts/tracks course To/Fm VOR, station passage",
        order: 5),
      ChecklistItem(
        title: "7. Localizer Course Intercepting and Tracking",
        notes: "Tunes & ID LOC,  intercepts and tracks  front and back courses", order: 6),
      ChecklistItem(
        title: "8. GPS Navigation",
        notes:
          "Activates flight plan, intercepts/track courses, uses Nearest & Direct To for divert ",
        order: 7),
      ChecklistItem(
        title: "9. In-Flight Weather Resources",
        notes:
          "Accesses all available in-flight resources (FSS, EFAS, HIWAS, ATIS, Cockpit Display)",
        order: 8),
      ChecklistItem(
        title: "10. Fundamental Maneuvers IR (Straight & Level, Turns, Climbs, Descents)",
        notes: "Coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°",
        order: 9),
      ChecklistItem(
        title: "11. Recovery from Unusual Attitudes IR",
        notes: "Promptly to stabilized, level flight, coordinated, correct control sequence",
        order: 10),
      ChecklistItem(
        title: "12. Electronic Navigation IR",
        notes:
          "Course to destination/alternate, intercepts/tracks course, safe altitude  ±200', 1/2 deflection",
        order: 11),
      ChecklistItem(
        title: "13. Federal Airways ",
        notes:
          "Identifies airway on chart, selects course in navigation system, intercepts and tracks course",
        order: 12),
      ChecklistItem(
        title: "14. Autopilot (if installed)",
        notes:
          "Conducts preflight test, explains ways to disengage, uses wing leveling, alt/heading hold & nav",
        order: 13),
      ChecklistItem(
        title: "15. Soft Field Approach and Landing",
        notes:
          "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction",
        order: 14),
      ChecklistItem(
        title: "16. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "All operations correct & accurate w/checklists, taxi proper speed & controls",
        order: 15),
    ]
  )

  static let p3L3AllSystemsCrossCountry = ChecklistTemplate(
    name: "P3-L3: All Systems Cross-country",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l3_all_systems_cross_country",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes:
          "Briefs PAVE checklist for this flight and use of the CARE checklist during the flight",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Utilizes all available resources during flight", order: 1),
      ChecklistItem(
        title: "3. Weight and Balance and Performance Calculations",
        notes:
          "Briefs load limits and takeoff/land runway requirements and climb and cruise performance",
        order: 2),
      ChecklistItem(
        title: "4. Flight Planning ",
        notes:
          "Briefs planned route, checkpoints, alternates, weather, NOTAMS, airspace, terrain, navigation log ",
        order: 3),
      ChecklistItem(
        title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass",
        order: 4),
      ChecklistItem(
        title: "6. FSS and ATC Radar Service",
        notes:
          "Opens flight plan with FSS and contacts appropriate ATC facility for VFR Flight Following",
        order: 5),
      ChecklistItem(
        title: "7. En Route Cruise",
        notes:
          "Uses power & mixture settings per POH/AFM, TAS and Fuel Flow planning, hdg ±10°, alt ±100'",
        order: 6),
      ChecklistItem(
        title: "8. Pilotage and DR",
        notes: "Maintains navigation log, position within 3 nm, ETA or revised ETA within 3 min.",
        order: 7),
      ChecklistItem(
        title: "9. Magnetic Compass",
        notes: "Simulated HI failure, use compass for headings, hdg ±15°", order: 8),
      ChecklistItem(
        title: "10. Electronic Navigation and Autopilot (if equipped)",
        notes:
          "At least 1 leg VOR, no more than 1 leg GPS, engage A/P (not more than 5 min.) in cruise",
        order: 9),
      ChecklistItem(
        title: "11. In-Flight Weather Resources",
        notes:
          "Checks available in-flight resources en route (FSS, EFAS, HIWAS, ATIS, Cockpit Display)",
        order: 10),
      ChecklistItem(
        title: "12. Cockpit Management",
        notes: "Equipment and materials organized, easily accessible and restrained", order: 11),
      ChecklistItem(
        title: "13. Task Management",
        notes: "Prioritizes and manages tasks by selecting the most appropriate for the moment ",
        order: 12),
      ChecklistItem(
        title: "14. Collision Avoidance",
        notes:
          "Divides attention among all tasks  making sure that looking for traffic is not abandoned ",
        order: 13),
      ChecklistItem(
        title: "15. Lost Procedures",
        notes:
          "Instructor introduces realistic distractions requiring use of lost procedures for reorientation",
        order: 14),
      ChecklistItem(
        title: "16. Diversion to an Alternate",
        notes:
          "Instructor scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel",
        order: 15),
      ChecklistItem(
        title: "17. Airport Traffic Pattern",
        notes:
          "Appropriate entry, radio calls, complies with instructions and/or procedures, alt ±100'",
        order: 16),
      ChecklistItem(
        title: "18. Soft Field Approach and Landing",
        notes:
          "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction",
        order: 17),
      ChecklistItem(
        title: "19. Short Field Takeoff, Climb and Departure",
        notes:
          "No-go, config., liftoff a/s per POH/AFM, V X  ± 5 kts until obstacle cleared,  turns to heading",
        order: 18),
      ChecklistItem(
        title: "20. Short Field Approach and Landing",
        notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance",
        order: 19),
      ChecklistItem(
        title: "21. After Landing, Taxi, Parking, Post Flight Procedures and Refueling",
        notes:
          "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan",
        order: 20),
    ]
  )

  static let p3L4NightFlying = ChecklistTemplate(
    name: "P3-L4: Night Flying",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l4_night_flying",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes:
          "Briefs PAVE checklist, focus on pilot rest, aircraft/pilot equipment & weather/moonlight",
        order: 0),
      ChecklistItem(
        title: "2. Physiological Aspects of Night Flying",
        notes:
          "Explains vision limitations at night, how to protect night vision, how to scan for traffic",
        order: 1),
      ChecklistItem(
        title: "3. Single Pilot Resource Management",
        notes: "Discusses differences in resources at night versus day, emergency equipment",
        order: 2),
      ChecklistItem(
        title: "4. CFIT", notes: "Discusses night hazards for Controlled Flight Into Terrain",
        order: 3),
      ChecklistItem(
        title: "5. Airport Layout and Lighting",
        notes: "Briefs notes, NOTAMs, operating hours, layout and lighting for airports to be used",
        order: 4),
      ChecklistItem(
        title: "6. Preflight Inspection at Night",
        notes:
          "Uses good light, correct/accurate steps w/checklists, checks all lights, fuel load, compass",
        order: 5),
      ChecklistItem(
        title: "7. Night Prestart and Starting",
        notes: "Flashlights readily available, sets cockpit & external lights, uses checklists ",
        order: 6),
      ChecklistItem(
        title: "8. Taxiing at Night",
        notes:
          "Confirms position w/airport diagram, appropriate speed & lighting, conscious of other aircraft ",
        order: 7),
      ChecklistItem(
        title: "9. Before Takeoff Checks at Night",
        notes:
          "Brakes locked for runup, correct/accurate steps w/checklists, confirms not moving on mag check",
        order: 8),
      ChecklistItem(
        title: "10. Night Take Off",
        notes:
          "Lights set, lineup on C/L, power & airspeed check before no go, smooth rotation to climb attitude",
        order: 9),
      ChecklistItem(
        title: "11. Climb After Night Takeoff",
        notes:
          "Climb attitude on AI, positive rate of climb, Vy  ±10 kts, wings level until minimum 400' AGL,  ",
        order: 10),
      ChecklistItem(
        title: "12. Night Local Area Navigation",
        notes: "Landmark recognition, electronic navigation aids ", order: 11),
      ChecklistItem(
        title: "13. Constant Airspeed Climb IR",
        notes: "Stabilized, coordinated, V Y  ±10 kts,  hdg ±15°, level off alt ±200' ", order: 12),
      ChecklistItem(
        title: "14. Constant Airspeed Descent IR",
        notes: "Stabilized, coordinated, a/s ±10 kts,  hdg ±15°, level off alt ±200' ", order: 13),
      ChecklistItem(
        title: "180° Level Turn IR",
        notes:
          "Stabilized, coordinated,  alt ±200', airspeed ±10 kts, standard rate turn bank ±10°, hdg ±15°",
        order: 14),
      ChecklistItem(
        title: "16. Recovery from Unusual Attitudes IR",
        notes: "Promptly to stabilized, level flight, coordinated, correct control sequence",
        order: 15),
      ChecklistItem(
        title: "17. Night Approach and Landing",
        notes:
          "Pattern alt ±100', hdg ±10°, stabilized approach, a/s +10/-5 kts, 6 full stop (2 landing light off)",
        order: 16),
      ChecklistItem(
        title: "18. Night Go-Around",
        notes:
          "Immediate takeoff power, pitch on AI for Vy , airspeed +10/-5 kts, flaps up per POH",
        order: 17),
      ChecklistItem(
        title: "19. Night Taxiing, Parking, Securing and Post Flight Procedures",
        notes:
          "Confirms position w/airport diagram, conscious of lights on other aircraft, uses checklists.",
        order: 18),
    ]
  )

  static let p3L5PreSoloXcProgressCheck = ChecklistTemplate(
    name: "P3-L5 Pre-Solo Xc Progress Check",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l5_pre_solo_xc_progress_check",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes:
          "Briefs PAVE checklist including W&B, fuel, & performance, use of the CARE checklist in-flight",
        order: 0),
      ChecklistItem(
        title: "2. Emergency Equipment and Survival Gear",
        notes:
          "Explains location and use of emergency equipment, evaluates adequacy for this flight",
        order: 1),
      ChecklistItem(
        title: "3. Single Pilot Resource Management",
        notes: "Briefs planned use of available resources during flight", order: 2),
      ChecklistItem(
        title: "4. Flight Planning",
        notes:
          "Briefs planned route, checkpoints, alternates, weather, NOTAMS, airspace, terrain, navigation log",
        order: 3),
      ChecklistItem(
        title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass",
        order: 4),
      ChecklistItem(
        title: "6. Short Field Takeoff, Climb and Departure",
        notes:
          "No-go, config., liftoff a/s per POH/AFM, V X  ± 5 kts until obstacle cleared, turns to heading",
        order: 5),
      ChecklistItem(
        title: "7. FSS and ATC Radar Service",
        notes:
          "Opens flight plan with FSS and contacts appropriate ATC facility for VFR Flight Following",
        order: 6),
      ChecklistItem(
        title: "8. En Route Cruise",
        notes:
          "Uses power & mixture settings per POH/AFM, TAS and Fuel Flow planning, hdg ±10°, alt ±100'",
        order: 7),
      ChecklistItem(
        title: "9. Navigation (DR, Pilotage, VOR and GPS)",
        notes:
          "Keeps nav log, uses DR, pilotage & electronic nav, track within 2 nm of course, ETA ±3 min",
        order: 8),
      ChecklistItem(
        title: "10. Cockpit Management",
        notes: "Equipment and materials organized, easily accessible and restrained", order: 9),
      ChecklistItem(
        title: "11. Task Management",
        notes: "Prioritizes and manages tasks by selecting the most appropriate for the moment ",
        order: 10),
      ChecklistItem(
        title: "12. Collision Avoidance",
        notes:
          "Divides attention among all tasks making sure that looking for traffic is not abandoned ",
        order: 11),
      ChecklistItem(
        title: "13. Heading Indicator Failure",
        notes: "Simulated HI failure, use compass for headings, hdg ±10°", order: 12),
      ChecklistItem(
        title: "14. Electrical Failure",
        notes:
          "Simulated emergency, reverts to DR & pilotage, decides go to destination, alternate, or return ",
        order: 13),
      ChecklistItem(
        title: "15. Lost Procedures",
        notes:
          "Instructor introduces realistic distractions requiring use of lost procedures for reorientation",
        order: 14),
      ChecklistItem(
        title: "16. Diversion to an Alternate",
        notes:
          "Scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel, advises ATC",
        order: 15),
      ChecklistItem(
        title: "17. Short Field Approach and Landing",
        notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance",
        order: 16),
      ChecklistItem(
        title: "18. Soft Field Takeoff, Climb and Departure",
        notes:
          "No-go, controls/config set, earliest liftoff, ground effect until V /V , +10/-5, turns to heading",
        order: 17),
      ChecklistItem(
        title: "19. Soft Field Approach and Landing",
        notes:
          "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction",
        order: 18),
      ChecklistItem(
        title: "20. No Flap Landing",
        notes: "Slip as necessary, ±10 kts, no drift, smooth touchdown, first 500'", order: 19),
      ChecklistItem(
        title: "21. After Landing, Taxi, Parking, Post Flight Procedures and Refueling",
        notes:
          "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan",
        order: 20),
    ]
  )

  static let p3L5XcSoloPreCheck = ChecklistTemplate(
    name: "P3-L5.1  Xc solo pre-check (61.93(e)-(m)",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l5_1_xc_solo_pre_check",
    items: [
      ChecklistItem(
        title: "1. FAA Knowledge Test", notes: "Completed with passing score", order: 0),
      ChecklistItem(title: "2. Logbook Endorsements", notes: "", order: 1),
      ChecklistItem(title: "3. Required Documents", notes: "on person", order: 2),
      ChecklistItem(
        title: "4. Navigation",
        notes:
          "Use of aeronautical charts for VFR navigation using pilotage and DR with the aid of a magnetic compass",
        order: 3),
      ChecklistItem(
        title: "5. Aircraft performance charts",
        notes: "calculate Takeoff, and landing distance, and climb performance", order: 4),
      ChecklistItem(
        title: "6. Weather Briefing",
        notes:
          "Procurement and analysis of aeronautical weather reports and forecasts, including recognition of critical weather situations and estimating visibility while in flight",
        order: 5),
      ChecklistItem(title: "7. Emergency Procedures", notes: "Memory Items", order: 6),
      ChecklistItem(
        title: "8. Traffic Pattern procedures",
        notes: "Are departure, area arrival, entry into traffic pattern and appraoch", order: 7),
      ChecklistItem(
        title: "9. Collision and windshear avoidance, wake turbluance precautions", notes: "",
        order: 8),
      ChecklistItem(
        title: "10. CFIT",
        notes:
          "Recognition, avoidance, and operational restrictions of hazardous terrain features in the geographical area where the cross-country flight will be flown",
        order: 9),
      ChecklistItem(
        title: "11. Use of intruments and equipment",
        notes:
          "Procedures for operating the instruments and equipment installed in the aircraft to be flown, including recognition and use of the proper operational procedures and indications",
        order: 10),
      ChecklistItem(
        title: "12. Radio Comms",
        notes:
          "se of radios for VFR navigation and two-way communication, except that a student pilot seeking a sport pilot certificate must only receive and log flight training on the use of radios installed in the aircraft to be flown",
        order: 11),
      ChecklistItem(
        title: "13. Takeoff & Landings",
        notes:
          "akeoff, approach, and landing procedures, including short-field, soft-field, and crosswind takeoffs, approaches, and landings",
        order: 12),
      ChecklistItem(
        title: "14. Climbs", notes: "Climbs at best angle Vx, and best rate Vy", order: 13),
      ChecklistItem(
        title: "15. Flight by reference to instruments",
        notes:
          "Control and maneuvering solely by reference to flight instruments, including straight and level flight, turns, descents, climbs, use of radio aids, and ATC directives. For student pilots seeking a sport pilot certificate, the provisions of this paragraph only apply when receiving training for cross-country flight in an airplane that has a VH greater than 87 knots CAS.",
        order: 14),
    ]
  )

  static let p3L5XcEndorsements = ChecklistTemplate(
    name: "P3-L5.2 XC endorsements (61.93)",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l5_2_xc_endorsements",
    items: [
      ChecklistItem(
        title: "1. A.9 Solo cross-country flight 61.93(c)(1) and (2)",
        notes:
          "I certify that [first name, MI, last name] has received the required solo cross-country training. I find they have met the applicable requirements of 61.93 and are proficient to make solo cross-country flights in a [make and model] aircraft.",
        order: 0),
      ChecklistItem(
        title: "2. A.10 Solo cross-country flight 61.93(c)(3)",
        notes:
          "I have reviewed the cross-country planning of [first name, MI, last name]. I find the planning and preparation to be correct to make the solo flight from [Origination Airport] to [Origination Airport] via [route of flight] with landings at [names of the airports] in a [Make and model] aircraft on [date]. [List any applicable conditions or limitations.]",
        order: 1),
    ]
  )

  static let p3L6XcSolo = ChecklistTemplate(
    name: "P3-L6: XC Solo",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l6_xc_solo",
    items: [
      ChecklistItem(
        title: "1. Route Briefing",
        notes:
          "Briefs route, checkpoints, airspace, terrain, boundaries, cross-checks, altitudes, VORs, alternates",
        order: 0),
      ChecklistItem(
        title: "2. Weather briefing",
        notes:
          "Departure, en route, destination & alternates (current & forecast), NOTAMS, what ifs for delays",
        order: 1),
      ChecklistItem(
        title: "3. Destination/Alternates Facilities",
        notes:
          "Briefs ATC or CTAF procedures/frequencies, runways, taxiways, servicing, NavAids, NOTAMS ",
        order: 2),
      ChecklistItem(
        title: "4. Navigation Plan",
        notes:
          "Briefs charts & pubs (current), methods of navigation, nav log, times, fuel reserves",
        order: 3),
      ChecklistItem(
        title: "5. Risk Management",
        notes: "Briefs the PAVE checklist and how to employ the CARE checklist en route", order: 4),
      ChecklistItem(
        title: "6. Single Pilot Resource Management",
        notes:
          "Briefs resources available for assistance in and outside the cockpit including en route weather",
        order: 5),
      ChecklistItem(
        title: "7. Lost Procedures", notes: "Briefs steps to follow if unsure of position", order: 6
      ),
      ChecklistItem(
        title: "8. Weight and Balance and Performance",
        notes:
          "Briefs takeoff & landing W&B, takeoff & landing runway required, power settings & performance",
        order: 7),
      ChecklistItem(
        title: "9. Emergency Equipment and Survival Gear",
        notes: "Explains location and use of emergency equipment & its adequacy for this flight",
        order: 8),
      ChecklistItem(
        title: "10. Emergency Operations",
        notes:
          "Briefs what ifs of engine failure, engine fire, rough engine, electrical failure, NORDO",
        order: 9),
      ChecklistItem(
        title: "11. FSS and ATC Radar Service",
        notes:
          "Files, opens & closes  flight plan with FSS , employs VFR Flight Following (if available) ",
        order: 10),
      ChecklistItem(
        title: "12. Flight to Airport More Than 50 NM Straight Line Distance ",
        notes:
          "Full stop normal landing, refueling (as necessary), weather briefing, return to home airport",
        order: 11),
      ChecklistItem(
        title: "13. After Landing, Taxi, Parking, Post Flight Procedures and Refueling",
        notes:
          "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan",
        order: 12),
      ChecklistItem(
        title: "14. Postflight Navigation Log and Conditions Review",
        notes:
          "Briefs instructor on planned versus actual GS, ETE, fuel used, track, airport operations & weather ",
        order: 13),
    ]
  )

  static let p3L7Xc100nmNightDual = ChecklistTemplate(
    name: "P3-L7: XC >100nm Night (Dual)",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l7_xc_100nm_night_dual",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes:
          "Briefs PAVE checklist including W&B, fuel, & performance, use of the CARE checklist in-flight",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes:
          "Briefs resources available for assistance in and outside the cockpit including en route weather",
        order: 1),
      ChecklistItem(
        title: "3. Physiological Aspects of Night Flying",
        notes:
          "Explains vision limitations at night, how to protect night vision, how to scan for traffic",
        order: 2),
      ChecklistItem(
        title: "4. Emergency Equipment and Survival Gear",
        notes: "Explains location and use of emergency equipment & its adequacy for this flight",
        order: 3),
      ChecklistItem(
        title: "5. Route Briefing",
        notes:
          "Briefs route, night visible checkpoints, airspace, terrain, boundaries, altitudes, VORs, alternates",
        order: 4),
      ChecklistItem(
        title: "6. Weather briefing",
        notes:
          "Departure, en route, destination & alternates (current & forecast), NOTAMS, what ifs for delays",
        order: 5),
      ChecklistItem(
        title: "7. Destination/Alternates Facilities",
        notes:
          "Briefs ATC or CTAF proced/freq, runways, taxiways, lighting, servicing, NavAids, NOTAMS",
        order: 6),
      ChecklistItem(
        title: "8. CFIT",
        notes: "Discusses night hazards on this route for Controlled Flight Into Terrain", order: 7),
      ChecklistItem(
        title: "9. Night Preflight Inspection and Startup",
        notes:
          "Correct/accurate steps w/checklists, uses good light, confirms required fuel load, preps cockpit",
        order: 8),
      ChecklistItem(
        title: "10. Night Taxiing and Before Takeoff Checks",
        notes:
          "Checks instruments and compass, controlled taxi using airport diagram, correct steps w/checklists",
        order: 9),
      ChecklistItem(
        title: "11. Night Take Off and Climb",
        notes:
          "Lights, on C/L, pwr & a/s check, climb attitude, positive climb, V Y  ±10 kts, wings level <400' AGL",
        order: 10),
      ChecklistItem(
        title: "12. FSS and ATC Radar Service",
        notes:
          "Files, opens & closes flight plan with FSS, employs VFR Flight Following (if available) ",
        order: 11),
      ChecklistItem(
        title: "13. Navigation (DR, Pilotage, VOR and GPS)",
        notes:
          "Keeps nav log, uses DR, pilotage & electronic nav, track within 3 nm of course, ETA ±3 min",
        order: 12),
      ChecklistItem(
        title: "14. Collision Avoidance",
        notes:
          "Divides attention among all tasks making sure that looking for traffic is not abandoned ",
        order: 13),
      ChecklistItem(
        title: "15. Controlling by Flight Instruments (180° Turn and Electronic Navigation)",
        notes:
          "Alt ±200', airspeed ±10 kts, standard rate turn bank ±10°, hdg ±15°, CDI 1/2 deflection",
        order: 14),
      ChecklistItem(
        title: "16. Lost Procedures",
        notes:
          "Instructor introduces realistic distractions requiring use of lost procedures for reorientation",
        order: 15),
      ChecklistItem(
        title: "17. Diversion to an Alternate",
        notes:
          "Scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel, advises ATC",
        order: 16),
      ChecklistItem(
        title: "18. Emergency Operations",
        notes:
          "Simulated rough engine, electrical failure, heading indicator  failure, radio failure",
        order: 17),
      ChecklistItem(
        title: "19. Night Approach and Landing",
        notes:
          "Pattern alt ±100', hdg ±10°, stabilized approach, a/s +10/-5 kts, 6 full stop (2 landing light off)",
        order: 18),
      ChecklistItem(
        title: "20. Night Go-Around",
        notes:
          "Immediate takeoff power, pitch on AI for V Y , airspeed +10/-5 kts, flaps up per POH",
        order: 19),
      ChecklistItem(
        title: "21. Night Taxiing, Parking, Securing and Post Flight Procedures",
        notes:
          "Confirms position w/airport diagram, conscious of lights on other aircraft, uses checklists.",
        order: 20),
    ]
  )

  static let p3L8SecondSoloXcBriefing = ChecklistTemplate(
    name: "P3-L8: 2nd Solo Xc Briefing",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l8_second_solo_xc_briefing",
    items: [
      ChecklistItem(
        title: "1. Logbook and Certificate endorsements and Required documents",
        notes:
          "Understands the required endorsements, student pilot privileges & specific instructor restrictions ",
        order: 0),
      ChecklistItem(
        title: "2. Route Briefing",
        notes:
          "Briefs route, checkpoints, airspace, terrain, boundaries, cross-checks, altitudes, VORs, alternates",
        order: 1),
      ChecklistItem(
        title: "3. Weather briefing",
        notes:
          "Departure, en route, destination & alternates (current & forecast), NOTAMS, what ifs for delays",
        order: 2),
      ChecklistItem(
        title: "4. Destination/Alternates Facilities",
        notes:
          "Briefs ATC or CTAF procedures/frequencies, runways, taxiways, servicing, NavAids, NOTAMS",
        order: 3),
      ChecklistItem(
        title: "5. Navigation Plan",
        notes:
          "Briefs charts & pubs (current), methods of navigation, nav log, times, fuel reserves",
        order: 4),
      ChecklistItem(
        title: "6. Risk Management",
        notes: "Briefs the PAVE checklist and how to employ the CARE checklist en route", order: 5),
      ChecklistItem(
        title: "7. Single Pilot Resource Management",
        notes:
          "Briefs resources available for assistance in and outside the cockpit including en route weather",
        order: 6),
      ChecklistItem(
        title: "8. Lost Procedures", notes: "Briefs steps to follow if unsure of position", order: 7
      ),
      ChecklistItem(
        title: "9. Weight and Balance and Performance",
        notes:
          "Briefs takeoff & landing W&B, takeoff & landing runway required, power settings & performance",
        order: 8),
      ChecklistItem(
        title: "10. Emergency Equipment and Survival Gear",
        notes: "Explains location and use of emergency equipment & its adequacy for this flight",
        order: 9),
      ChecklistItem(
        title: "11. Emergency Operations",
        notes:
          "Briefs what ifs of engine failure, engine fire, rough engine, electrical failure, NORDO",
        order: 10),
      ChecklistItem(
        title: "12. FSS and ATC Radar Service",
        notes:
          "Files, opens & closes  flight plan with FSS for each leg, employs VFR Flight Following (if available)",
        order: 11),
      ChecklistItem(
        title: "13. Flight to Airport More Than 50 NM Straight Line Distance ",
        notes:
          "Full stop normal landing, refueling (as necessary), weather briefing, return to home airport",
        order: 12),
      ChecklistItem(
        title: "14. After Landing, Taxi, Parking, Post Flight Procedures and Refueling",
        notes:
          "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan",
        order: 13),
      ChecklistItem(
        title: "15. Postflight Navigation Log and Conditions Review",
        notes:
          "Briefs instructor on planned versus actual GS, ETE, fuel used, track, airport operations & weather ",
        order: 14),
    ]
  )

  static let p3L9EmergenciesAndInstrumentReview = ChecklistTemplate(
    name: "P3-L9: Emergencies and Instrument Review",
    category: "PPL",
    phase: "Phase 3",
    templateIdentifier: "default_p3_l9_emergencies_and_instrument_review",
    items: [
      ChecklistItem(
        title: "1. Risk Management",
        notes:
          "Briefs PAVE checklist and CARE checklist focusing on preparedness for in-flight equipment failures",
        order: 0),
      ChecklistItem(
        title: "2. Single Pilot Resource Management",
        notes: "Briefs planned use of available resources during emergencies", order: 1),
      ChecklistItem(
        title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks",
        notes:
          "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls",
        order: 2),
      ChecklistItem(
        title: "4. Short Field Takeoff, Climb and Departure",
        notes: "No-go, config., liftoff a/s per POH/AFM, Vx ± 5 kts until obstacle cleared",
        order: 3),
      ChecklistItem(
        title: "5. Soft Field Takeoff and Climb",
        notes: "No-go, controls/config set, earliest liftoff, ground effect until Vx /Vy , ± 5 kts",
        order: 4),
      ChecklistItem(
        title: "6. Rejected Takeoff",
        notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 5),
      ChecklistItem(
        title: "7. Engine Failure in Climb After Takeoff",
        notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 6),
      ChecklistItem(
        title: "8. Engine Fire in Flight, Emergency Descent and Landing (Simulated)",
        notes:
          "Fire memory items, emerg descent config, best glide ±10 kts, best field, emerg approach checklist",
        order: 7),
      ChecklistItem(
        title: "9. Constant Airspeed Climb IR",
        notes: "Stabilized, coordinated, Vy ±5 kts,  hdg ±10°, level off alt ±100' ", order: 8),
      ChecklistItem(
        title: "10. Constant Airspeed Descent IR",
        notes: "Stabilized, coordinated, a/s ±5 kts,  hdg ±10°, level off alt ±100' ", order: 9),
      ChecklistItem(
        title: "180° Level Turn IR",
        notes:
          "Stabilized, coordinated,  alt ±150', airspeed ±10 kts, standard rate turn bank ±5°, hdg ±10°",
        order: 10),
      ChecklistItem(
        title: "12. Electronic Navigation IR",
        notes: "Tunes, selects course, alt ±150', airspeed ±10 kts, hdg ±10°, CDI 1/2 deflection",
        order: 11),
      ChecklistItem(
        title: "13. Recovery from Unusual Attitudes IR",
        notes: "Promptly to stabilized, level flight, coordinated, correct control sequence",
        order: 12),
      ChecklistItem(
        title: "14. Autopilot (if installed) IR",
        notes:
          "Preflight test, in simulated IMC engages wing leveling, alt & heading/nav hold to return to VMC",
        order: 13),
      ChecklistItem(
        title: "15. Electrical Failure",
        notes:
          "Simulated emergency, reverts to DR & pilotage, decides go to destination, alternate, or return ",
        order: 14),
      ChecklistItem(
        title: "16. Emergency Communications and ATC Resources",
        notes: "Explain emergency communication procedures for requesting ATC assistance", order: 15
      ),
      ChecklistItem(
        title: "17. Short Field Approach and Landing",
        notes: "Stabilized approach ±5 kts, touchdown within 400', stops in shortest distance",
        order: 16),
      ChecklistItem(
        title: "18. Soft Field Approach and Landing",
        notes:
          "Stabilized approach ±5 kts, touches down softly, wt. off nose, maintains crosswind correction",
        order: 17),
      ChecklistItem(
        title: "19. No Flap Landing",
        notes: "Slip as necessary, ±10 kts, no drift, smooth touchdown, first 500'", order: 18),
      ChecklistItem(
        title: "20. After Landing, Taxi, Parking, and Post Flight Procedures",
        notes: "Uses checklists, complete/accurate", order: 19),
    ]
  )

  // MARK: - Phase 4 Templates

  static let p4L1PreCheckrideInstructorReview = ChecklistTemplate(
    name: "P4-L1.1: Pre-Checkride Instructor Review",
    category: "PPL",
    phase: "Phase 4",
    templateIdentifier: "default_p4_l1_1_pre_checkride_instructor_review",
    items: [
      ChecklistItem(
        title: "1. Airman Certification Standards",
        notes:
          "introduction (Special Emphasis Areas), Applicant's Checklist &  Areas of Operation and Tasks ",
        order: 0),
      ChecklistItem(
        title: "2. Single-Pilot Resource Management",
        notes: "Private Pilot Airman Certification Standards", order: 1),
      ChecklistItem(
        title: "3. Risk Management", notes: "Private Pilot Airman Certification Standards", order: 2
      ),
      ChecklistItem(
        title: "4. Aeronautical Decision-Making",
        notes: "Private Pilot Airman Certification Standards", order: 3),
      ChecklistItem(
        title: "5. Task Management", notes: "Private Pilot Airman Certification Standards", order: 4
      ),
      ChecklistItem(
        title: "6. Situational Awareness", notes: "Private Pilot Airman Certification Standards",
        order: 5),
      ChecklistItem(
        title: "7. Controlled Flight into Terrain (CFIT)",
        notes: "Private Pilot Airman Certification Standards", order: 6),
      ChecklistItem(
        title: "8. Automation Management", notes: "Private Pilot Airman Certification Standards",
        order: 7),
      ChecklistItem(
        title: "9. Positive Exchange of Flight Controls",
        notes: "Explains and uses the positive three-step exchange of controls", order: 8),
      ChecklistItem(
        title: "10. Wake Turbulence Avoidance",
        notes:
          "Explains procedures for taking off & landing after departing & arriving large aircraft",
        order: 9),
      ChecklistItem(
        title: "11. Land and Hold Short Operations (LAHSO)",
        notes:
          "Explains where to find if an airport uses LAHSO, procedures, restrictions & options",
        order: 10),
      ChecklistItem(
        title: "12. Runway Incursion Avoidance",
        notes: "Private Pilot Airman Certification Standards", order: 11),
      ChecklistItem(
        title: "13. Certificates and Documents",
        notes: "Private Pilot Airman Certification Standards", order: 12),
      ChecklistItem(
        title: "14. Airworthiness Requirements",
        notes: "Private Pilot Airman Certification Standards", order: 13),
      ChecklistItem(
        title: "15. Weather Information", notes: "Private Pilot Airman Certification Standards",
        order: 14),
      ChecklistItem(
        title: "16. Cross-Country Flight Planning",
        notes: "Private Pilot Airman Certification Standards", order: 15),
      ChecklistItem(
        title: "17. National Airspace System",
        notes: "Private Pilot Airman Certification Standards", order: 16),
      ChecklistItem(
        title: "18. Performance and Limitations",
        notes: "Private Pilot Airman Certification Standards", order: 17),
      ChecklistItem(
        title: "19. Operation of Systems", notes: "Private Pilot Airman Certification Standards",
        order: 18),
      ChecklistItem(
        title: "20. Aeromedical Factors", notes: "Private Pilot Airman Certification Standards",
        order: 19),
      ChecklistItem(
        title: "21. Preflight Inspection", notes: "Private Pilot Airman Certification Standards",
        order: 20),
      ChecklistItem(
        title: "22. Cockpit Management", notes: "Private Pilot Airman Certification Standards",
        order: 21),
      ChecklistItem(
        title: "23. Engine starting", notes: "Private Pilot Airman Certification Standards",
        order: 22),
      ChecklistItem(
        title: "24. Taxiing", notes: "Private Pilot Airman Certification Standards", order: 23),
      ChecklistItem(
        title: "25. Before Takeoff Check", notes: "Private Pilot Airman Certification Standards",
        order: 24),
      ChecklistItem(
        title: "26. Radio Communications and ATC Light Signals",
        notes: "Private Pilot Airman Certification Standards", order: 25),
      ChecklistItem(
        title: "27. Traffic Patterns", notes: "Private Pilot Airman Certification Standards",
        order: 26),
      ChecklistItem(
        title: "28. Airport, Runway and Taxiway Signs, Markings and Lighting",
        notes: "Private Pilot Airman Certification Standards", order: 27),
      ChecklistItem(
        title: "29. Normal and Crosswind Takeoff and Climb",
        notes: "Private Pilot Airman Certification Standards", order: 28),
      ChecklistItem(
        title: "30. Normal and Crosswind Approach and Landing",
        notes: "Private Pilot Airman Certification Standards", order: 29),
      ChecklistItem(
        title: "31. Soft-Field Takeoff and Climb",
        notes: "Private Pilot Airman Certification Standards", order: 30),
      ChecklistItem(
        title: "32. Soft-Field Approach and Landing",
        notes: "Private Pilot Airman Certification Standards", order: 31),
      ChecklistItem(
        title: "33. Short-Field Takeoff and Maximum Performance Climb",
        notes: "Private Pilot Airman Certification Standards", order: 32),
      ChecklistItem(
        title: "34. Short-Field Approach and Landing",
        notes: "Private Pilot Airman Certification Standards", order: 33),
      ChecklistItem(
        title: "35. Forward Slip to a Landing",
        notes: "Private Pilot Airman Certification Standards", order: 34),
      ChecklistItem(
        title: "36. Go-Around/Rejected Landing",
        notes: "Private Pilot Airman Certification Standards", order: 35),
      ChecklistItem(
        title: "37. Steep Turns", notes: "Private Pilot Airman Certification Standards", order: 36),
      ChecklistItem(
        title: "38. Rectangular Course", notes: "Private Pilot Airman Certification Standards",
        order: 37),
      ChecklistItem(
        title: "39. S-Turns", notes: "Private Pilot Airman Certification Standards", order: 38),
      ChecklistItem(
        title: "40. Turns Around a Point", notes: "Private Pilot Airman Certification Standards",
        order: 39),
      ChecklistItem(
        title: "41. Pilotage and Dead Reckoning",
        notes: "Private Pilot Airman Certification Standards", order: 40),
      ChecklistItem(
        title: "42. Navigation Systems and Radar Services",
        notes: "Private Pilot Airman Certification Standards", order: 41),
      ChecklistItem(
        title: "43. Diversion", notes: "Private Pilot Airman Certification Standards", order: 42),
      ChecklistItem(
        title: "44. Lost Procedures", notes: "Private Pilot Airman Certification Standards",
        order: 43),
      ChecklistItem(
        title: "45. Maneuvering During Slow Flight",
        notes: "Private Pilot Airman Certification Standards", order: 44),
      ChecklistItem(
        title: "46. Power-Off Stalls", notes: "Private Pilot Airman Certification Standards",
        order: 45),
      ChecklistItem(
        title: "47. Power-On Stalls", notes: "Private Pilot Airman Certification Standards",
        order: 46),
      ChecklistItem(
        title: "48. Spin Awareness", notes: "Private Pilot Airman Certification Standards",
        order: 47),
      ChecklistItem(
        title: "49. Straight-and-Level Flight IR",
        notes: "Private Pilot Airman Certification Standards", order: 48),
      ChecklistItem(
        title: "50. Constant Airspeed Climbs IR",
        notes: "Private Pilot Airman Certification Standards", order: 49),
      ChecklistItem(
        title: "51. Constant Airspeed Descents IR",
        notes: "Private Pilot Airman Certification Standards", order: 50),
      ChecklistItem(
        title: "52. Turns to Headings IR", notes: "Private Pilot Airman Certification Standards",
        order: 51),
      ChecklistItem(
        title: "53. Recovery from Unusual Flight Attitudes IR",
        notes: "Private Pilot Airman Certification Standards", order: 52),
      ChecklistItem(
        title: "54. Radio Communications, Navigation Systems/Facilities and Radar Services",
        notes: "Private Pilot Airman Certification Standards", order: 53),
      ChecklistItem(
        title: "55. Emergency Descent", notes: "Private Pilot Airman Certification Standards",
        order: 54),
      ChecklistItem(
        title: "56. Emergency Approach and Landing (Simulated)",
        notes: "Private Pilot Airman Certification Standards", order: 55),
      ChecklistItem(
        title: "57. Systems and Equipment Malfunctions",
        notes: "Private Pilot Airman Certification Standards", order: 56),
      ChecklistItem(
        title: "58. Emergency Equipment and Survival Gear",
        notes: "Private Pilot Airman Certification Standards", order: 57),
      ChecklistItem(
        title: "59. Night Preparation", notes: "Private Pilot Airman Certification Standards",
        order: 58),
      ChecklistItem(
        title: "60. After Landing, Parking and Securing",
        notes: "Private Pilot Airman Certification Standards", order: 59),
    ]
  )

  static let p4L1CheckrideChecklist = ChecklistTemplate(
    name: "P4-L1.2: Checkride Checklist",
    category: "PPL",
    phase: "Phase 4",
    templateIdentifier: "default_p4_l1_2_checkride_checklist",
    items: [
      ChecklistItem(
        title:
          "1. Valid Student Pilot Certificate, Sport Pilot Certificate, or Recreational Pilot Certificate.",
        notes: "", order: 0),
      ChecklistItem(
        title: "2. Completion of flight training program.",
        notes:
          "Flight training program to meet the requirements of part 61 sub part E. The rule provides the specific minimum aeronautical knowledge, flight proficiency and aeronautic experience requirements that the training program must meet.",
        order: 1),
      ChecklistItem(
        title: "3. Night Experience Requirements.",
        notes:
          "Applicants must meet night experience requirements regardless of medical qualification considerations. Section 61.110 lists the only exception.",
        order: 2),
      ChecklistItem(
        title: "4. 3 hours of flight solely by reference to instruments.",
        notes:
          "Private pilot airplane and powered lift applicants must also accomplish three hours of flight training on the control and maneuvering of the aircraft solely by reference to instruments in the category and class of aircraft. The three hours of flight training do not have to be conducted by a CF-II.",
        order: 3),
    ]
  )

  static let p4L1PracticalTestEndorsements = ChecklistTemplate(
    name: "P4-L1.3 Practical Test Endorsements",
    category: "PPL",
    phase: "Phase 4",
    templateIdentifier: "default_p4_l1_3_practical_test_endorsements",
    items: [
      ChecklistItem(
        title: "1. A.33 Flight proficiency/practical test. 61.103(f), 61.107(b), 61.109.",
        notes:
          "I certified that [first name, MI, last name] has received the required training in accordance with 61.107 and 61.109. I have determined they are prepared for the [name of] practical test.",
        order: 0),
      ChecklistItem(
        title: "2. A.1 Prerequisites for practical test. 61.39(a)(6)(i) and (ii).",
        notes:
          "I certified that [first name, MI, last name] has received and logged training time within 2 calendar months preceding the month of application in preparation for the practical test and they are prepared for the required practical test for the issuance of [applicable certificate].",
        order: 1),
      ChecklistItem(
        title:
          "3. A.2 Review of deficiencies identified on airman knowledge test. 61.39(a)(6)(iii) as required.",
        notes:
          "I certified that [first name, MI, last name] has demonstrated satisfactory knowledge of the subject areas in which they were deficient on the [applicable] Airmen knowledge test.",
        order: 2),
    ]
  )

  static let p4L3WrittenTestEndorsements = ChecklistTemplate(
    name: "P4-L3: Written Test Endorsements",
    category: "PPL",
    phase: "Phase 4",
    templateIdentifier: "default_p4_l3_written_test_endorsements",
    items: [
      ChecklistItem(
        title: "1. A.32 Aeronautical knowledge test 61.35(a)(1), 61.103(d), and 61.105",
        notes:
          "I certify that [first name, MI, last name] has received the required training in accordance with 61.105. I have determined they are prepared for the [name of] knowledge test.",
        order: 0)
    ]
  )

}
