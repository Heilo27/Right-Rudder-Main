//
//  DefaultTemplates.swift
//  Right Rudder
//
//  Created by AI on 10/8/25.
//

import Foundation
import SwiftData

/// Centralized location for all default checklist templates
class DefaultTemplates {
    
    // MARK: - First Steps Templates
    
    static let studentOnboardTrainingOverview = ChecklistTemplate(
        name: "Student Onboard/Training Overview",
        category: "PPL",
        phase: "First Steps",
        templateIdentifier: "default_student_onboard_training_overview",
        items: [
            ChecklistItem(title: "Previous flight training", notes: "Document previous flight training experience", order: 0),
            ChecklistItem(title: "Logbook Review", notes: "Review student's existing logbook entries", order: 1),
            ChecklistItem(title: "Contact information", notes: "Verify all contact details are complete and accurate", order: 2),
            ChecklistItem(title: "U.S. Citizenship proof & endorsement", notes: "Review citizenship documentation and endorsements", order: 3),
        ]
    )
    
    // MARK: - Phase 1 Templates
    
    static let p1L10ManeuverReview = ChecklistTemplate(
        name: "P1-L10: Maneuver Review",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l10_maneuver_review",
        items: [
            ChecklistItem(title: "RIsk Managment", notes: "Using PAVE checklist briefs risk factors for this flight & how to mitigate them ", order: 0),
            ChecklistItem(title: "Single Pilot Resource Management", notes: "Explains resources available for assistance during this flight", order: 1),
            ChecklistItem(title: "Situational Awareness", notes: "Explains methods of reorienting if lost or disoriented", order: 2),
            ChecklistItem(title: "Stall/Spin Awareness", notes: "Explains stall & spin causes, characteristics & recovery procedures", order: 3),
            ChecklistItem(title: "Wake Turbulence Avoidance", notes: "Explains procedures for taking off & landing after departing & arriving large aircraf t", order: 4),
            ChecklistItem(title: "Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls", order: 5),
            ChecklistItem(title: "Radio Communications", notes: "Makes all appropriate calls, understands or requests clarification for instructions", order: 6),
            ChecklistItem(title: "Collision Avoidance", notes: "Clears traffic before all operations on the ground & airborne ", order: 7),
            ChecklistItem(title: "Normal and Crosswind Take Off, Departure and Climb", notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic", order: 8),
            ChecklistItem(title: "Fundamental Maneuvers VR (Straight & Level, Turns, Climbs, Descents) ", notes: "Coordinated controls, in trim, alt ±100', hdg ±10°, a/s ±10 kts, bank ±10°", order: 9),
            ChecklistItem(title: "Fundamental Maneuvers IR (Straight & Level, Turns, Climbs, Descents)", notes: "Coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°", order: 10),
            ChecklistItem(title: "Steep Turns", notes: "Clears area, 360° L&R, coordinated, alt ±150', hdg ±15°, a/s ±10 kts, bank ±10°", order: 11),
            ChecklistItem(title: "Slow Flight (Straight & Level, Turns, Climbs, Descents)", notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°", order: 12),
            ChecklistItem(title: "Power-Off and Power-On Stall", notes: "Clears area, full stall, 15° bank turn ±10°,  prompt AOA, power & level wings", order: 13),
            ChecklistItem(title: "Engine Failures at Altitude and in Climb ", notes: "Assesses situation, best glide ±10 kts, best field, memory items", order: 14),
            ChecklistItem(title: "Ground Reference Maneuvers", notes: "Checks for traffic & obstructions, alt ±150', corrects for wind in straight & turning flight", order: 15),
            ChecklistItem(title: "Normal and Crosswind Approach and Landing", notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3", order: 16),
            ChecklistItem(title: "No Flap Landing", notes: "Slip as necessary,  ±10 kts, no drift, smooth touchdown, first 1/3, center 1/3", order: 17),
            ChecklistItem(title: "Rejected Takeoff", notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 18),
            ChecklistItem(title: "Go-Around", notes: "Immediate takeoff power, pitch for V Y , +10/-5, flaps up, offset as appropriate (Cram, Climb, Clean)", order: 19),
            ChecklistItem(title: "After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls", order: 20),
        ]
    )
    
    static let p1L1StraightAndLevelFlight = ChecklistTemplate(
        name: "P1-L1: Straight and Level Flight",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l1_straight_and_level_flight",
        items: [
            ChecklistItem(title: "1. Safety Practices, Procedures and Equipment", notes: "Understands hazards, door, seat, safety belt, and fire extinguisher operation", order: 0),
            ChecklistItem(title: "2. Preflight Inspection, Flight Control and Systems Operation", notes: "Observes preflight demo using checklist; understands  switch & control functions", order: 1),
            ChecklistItem(title: "3. Positive Exchange of Flight Controls", notes: "Understands and uses the positive three-step exchange of controls", order: 2),
            ChecklistItem(title: "4. Prestart checklist, Engine Starting and Warm-up", notes: "Observes prestart checklist, starting and warm up procedures", order: 3),
            ChecklistItem(title: "5. Taxiing", notes: "Observes demo, with instr assist controls the airplane, observes signs and markings", order: 4),
            ChecklistItem(title: "6. Before Takeoff Checks and Engine Runup", notes: "Observes pretakeoff checklist and engine runup", order: 5),
            ChecklistItem(title: "7. Normal Takeoff and Climb", notes: "Observes & is lightly on the controls for instructor's takeoff & initial climb", order: 6),
            ChecklistItem(title: "8. Level-off", notes: "Observes and is lightly on the controls for instructor's level-off from initial climb", order: 7),
            ChecklistItem(title: "9. Checklist Use", notes: "Observes instructor use of checklists for all phases of flight", order: 8),
            ChecklistItem(title: "10. Collision Avoidance", notes: "Observes demo of clearing for traffic during climbs, descents, and before turns", order: 9),
            ChecklistItem(title: "11. Trimming", notes: "Senses the changes in control pressure and moves trim wheel in the correct direction", order: 10),
            ChecklistItem(title: "12. Straight and Level", notes: "Notes reference point and altitude changes and initiates corrections ", order: 11),
            ChecklistItem(title: "13. Demonstration of tendency to maintain straight and level flight", notes: "Observes instructor demonstration of pitch and bank stability", order: 12),
            ChecklistItem(title: "14. Turn Coordination", notes: "With instructor assist applies rudder when starting & stopping turns", order: 13),
            ChecklistItem(title: "15. Medium Bank Turns", notes: "With assist starts & stops coordinated medium-bank, level altitude turn", order: 14),
            ChecklistItem(title: "16. Climbs and Level-off", notes: "Observes climb attitude and with instructor assist can establish a climb", order: 15),
            ChecklistItem(title: "17. Descents and Level-off", notes: "Observes descent attitude and with instructor assist can establish a descent", order: 16),
            ChecklistItem(title: "18. Area Familiarization", notes: "Observes as instructor directs attention to prominent landmarks and roadways", order: 17),
            ChecklistItem(title: "19. Normal Approach and Landing", notes: "Observes instructor normal approach and landing demo including checklist use", order: 18),
            ChecklistItem(title: "20. After Landing, Taxi and Parking", notes: "With instructor assist, completes after-landing checklist, taxi, shutdown & parking", order: 19),
            ChecklistItem(title: "21. Post Flight Procedures", notes: "Observes postflight inspection and securing demonstration while following checklist", order: 20),
        ]
    )
    
    static let p1L2BasicAircraftOperations = ChecklistTemplate(
        name: "P1-L2: Basic Aircraft Operations",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l2_basic_aircraft_operations",
        items: [
            ChecklistItem(title: "1. Preflight Inspection, Flight Control and Systems Operation", notes: "With assist, performs preflight inspection with checklist & can explain systems operation", order: 0),
            ChecklistItem(title: "2. Passenger Briefing", notes: "Understands Hazards, Door, Seat, Safety belt, and fire extenguisher operation.", order: 1),
            ChecklistItem(title: "3. Positive exchange of Flight Controls", notes: "Understands and uses the positive three-step exchange of controls", order: 2),
            ChecklistItem(title: "4. Engine Starting and Warm-up", notes: "With instructor assist, completes prestart checklist, engine start & warm-up", order: 3),
            ChecklistItem(title: "5. Radio Communications", notes: "Turns on & sets up Comm radios copies ATIS, & makes taxi calls using a script", order: 4),
            ChecklistItem(title: "6. Taxiing", notes: "Taxies with minimal instructor assist, uses airport diagram, notes signs and markings", order: 5),
            ChecklistItem(title: "7. Before Takeoff Checks and Engine Runup", notes: "Completes pretakeoff checklist and engine runup with instructor assist", order: 6),
            ChecklistItem(title: "8. Normal takeoff and climb", notes: "Follows lightly on the controls during instructor's takeoff and initial climb", order: 7),
            ChecklistItem(title: "9. Level Off", notes: "With Instructor assist, levels off at desired altitude ± 300' ", order: 8),
            ChecklistItem(title: "10. Collision avoidance", notes: "With instructor assist clears traffic during climbs, descents, and before turns", order: 9),
            ChecklistItem(title: "11. Turn Coordination", notes: "Applies aileron and appropriate rudder & elevator for turns both directions", order: 10),
            ChecklistItem(title: "12. Medium Bank Turns", notes: "Checks for traffic, starts a medium-bank turn holding ±200' and stops turn ±20 °", order: 11),
            ChecklistItem(title: "13. Left and Right Turning Tendency", notes: "Notes rudder required for lo speed/hi power & hi speed/lo power", order: 12),
            ChecklistItem(title: "14. Trimming", notes: "Applies trim in the correct direction removing control pressure", order: 13),
            ChecklistItem(title: "15. Straight and Level", notes: "Picks reference, maintains altitude ± 200' & heading within ±20°", order: 14),
            ChecklistItem(title: "16. Climbs and Descents and Level-off With and Without Turns", notes: "With assist, adjusts power, pitch & bank to hold ± 10 kts  & levels off  ± 200' & ±20°", order: 15),
            ChecklistItem(title: "17. Descents With and Without Flaps", notes: "With instructor assist, starts descent without flaps & extends flaps in increments. Note FPM changes with different flap settings", order: 16),
            ChecklistItem(title: "18. Power Off Descent", notes: "Notes attitude for best glide speed, makes turns, & adds power for level flight", order: 17),
            ChecklistItem(title: "19. Traffic pattern operations", notes: "Entry, Exit, and call outs. Observes as instructor directs attention to prominent landmarks and roadways", order: 18),
            ChecklistItem(title: "20. Normal Approach and Landing", notes: "Follows checklist & observes instructor demonstration of normal approach and landing", order: 19),
            ChecklistItem(title: "21. After Landing, Taxi and Parking", notes: "With minimal assist completes after landing checks, taxi using airport diagram and parking", order: 20),
            ChecklistItem(title: "22. Postflight Procedures", notes: "Completes postflight inspection and secures the aircraft using checklist", order: 21),
        ]
    )
    
    static let p1L3InstrumentsAndInvestigatingSlowFlight = ChecklistTemplate(
        name: "P1-L3: Instruments and Investigating slow-flight",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l3_instruments_and_investigating_slow_flight",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Reviews PAVE checklist with instructor noting fuel, weather conditions & loading", order: 0),
            ChecklistItem(title: "2. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "With minimal assist, uses appropriate checklists & performs all ground operations", order: 1),
            ChecklistItem(title: "3. Radio Communications", notes: "With instructor assist & script, makes taxi, takeoff, & pre-landing calls", order: 2),
            ChecklistItem(title: "4. Crosswind Taxi", notes: "With minimal assist, notes wind, positons controls to counter the wind effects, uses diagram", order: 3),
            ChecklistItem(title: "5. Normal Take Off and Climb", notes: "With instructor's assist, performs normal takeoff, climbs ±10 kts, scans for traffic", order: 4),
            ChecklistItem(title: "6. Straight and Level", notes: "Notes reference point and altitude changes and initiates corrections, ±150' & ±15° ", order: 5),
            ChecklistItem(title: "7. Turns", notes: "Starts and stops shallow & medium bank turns holding altitude ±150' rolling out  ±15°    ", order: 6),
            ChecklistItem(title: "8. Climbs and Descents Straight and with Turns", notes: "Grasps pitch/airspeed relationship holds ±10 kts, trims, & levels-off within ±100'", order: 7),
            ChecklistItem(title: "9. Power Off Descent", notes: "Attitude for best glide speed, 180° turns noting altitude loss, & level-off ±100'", order: 8),
            ChecklistItem(title: "10. Aileron/Rudder Coordination Exercise", notes: "Observes demo & then practices 30° bank side-to-side keeping nose on point", order: 9),
            ChecklistItem(title: "11. Straight and Level Using Flight Instruments", notes: "Using visual reference, S&L on instruments ±300' ±20° & compare with outside view", order: 10),
            ChecklistItem(title: "12. Turns Using Flight Instruments", notes: "Left & right med bank turns on instruments ±300' ±20° & compare with outside view", order: 11),
            ChecklistItem(title: "13. Climbs and Descents Using Flight Instruments", notes: "Initiates climbs and descents on instruments ±15° & compare with outside view", order: 12),
            ChecklistItem(title: "14. Flying Slowly", notes: "With assist, slows to 1.1VS S&L, shallow turns, note changes in force, response & sound", order: 13),
            ChecklistItem(title: "15. Descent at Approach Airspeed in Landing Configuration", notes: "With minimal assist descends approach airspeeds/flaps to simulated landing at altitude", order: 14),
            ChecklistItem(title: "16. Go-Around Procedures", notes: "Observes demo & with assist does go-arounds at altitude (partial and full flaps)", order: 15),
            ChecklistItem(title: "17. Area Recognition/Traffic Pattern Entry", notes: "Correlates position with prominent local landmarks", order: 16),
            ChecklistItem(title: "18. Normal Approach and Landing", notes: "Follows lightly on the controls during instructor's normal approach and landing", order: 17),
            ChecklistItem(title: "19. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "With minimal assist, uses appropriate checklists/diagrams & performs all ground operations", order: 18),
        ]
    )
    
    static let p1L4SlowFlightAndStalls = ChecklistTemplate(
        name: "P1-L4: Slow Flight and Stalls",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l4_slow_flight_and_stalls",
        items: [
            ChecklistItem(title: "1. Risk Managment", notes: "Reviews PAVE checklist with instructor noting fuel, weather conditions & loading", order: 0),
            ChecklistItem(title: "2. Stall/Spin Awareness", notes: "Understands concept of aerodynamic stall & spin, warning signs & need to control yaw", order: 1),
            ChecklistItem(title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "With minimal assist, uses appropriate checklists & performs all ground operations", order: 2),
            ChecklistItem(title: "4. Crosswind Taxi", notes: "With minimal assist, notes wind, positons controls to counter the wind effects, uses diagram. Demonstrate or verbal.", order: 3),
            ChecklistItem(title: "5. Radio Communications", notes: "With instructor assist & script, makes taxi, takeoff, & pre-landing calls", order: 4),
            ChecklistItem(title: "6. Normal Take Off and Climb", notes: "With instructor's assist, performs normal takeoff, climbs ±10 kts, scans for traffic", order: 5),
            ChecklistItem(title: "7. Straight and Level", notes: "Notes reference point and altitude changes and initiates corrections, ±150' & ±15° ", order: 6),
            ChecklistItem(title: "8. Turns", notes: "Starts and stops shallow & medium bank turns holding altitude ±150' rolling out  ±15°", order: 7),
            ChecklistItem(title: "9. Fundamental Maneuvers Visual Reference", notes: "Uses coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°", order: 8),
            ChecklistItem(title: "10. Fundamental Maneuvers Instrument Reference", notes: "Uses coordinated controls, altitude ±250', heading ±20°, airspeed ±10 kts, bank ±15°", order: 9),
            ChecklistItem(title: "11. Flying Slowly", notes: "With minimal assist, Straight&Level, turns, climbs, & descents at minimum airspeed", order: 10),
            ChecklistItem(title: "12. Controlling Roll and Yaw at High Angle of Attack", notes: "With instructor assistance, explores rudder use for bank control ", order: 11),
            ChecklistItem(title: "13. Power-Off Stall", notes: "Observes demo and with assist, slows to a power-off stall & recovers at first indiction", order: 12),
            ChecklistItem(title: "14. Power-Off Descent", notes: "Demo of simulated emergency approach & landing, practice to no lower than 500' AGL", order: 13),
            ChecklistItem(title: "15. Aileron/Rudder Coordination Exercise", notes: "30° bank side-to-side keeping nose within ±20° of point ", order: 14),
            ChecklistItem(title: "16. Go-Around Procedures", notes: "Practice go-around procedures at altitude (partial and full flaps)", order: 15),
            ChecklistItem(title: "17. Collision Avoidance", notes: "Aware of high threat areas, scans for traffic in climbs & before turns & maneuvers", order: 16),
            ChecklistItem(title: "18. Airport Traffic Pattern", notes: "With instructor assist, complies with ATC instructions or non-tower procedures", order: 17),
            ChecklistItem(title: "19. Normal and Crosswind Approach and Landing", notes: "With instructor assist, completes checklist, configures airplane, flys approach to landing", order: 18),
            ChecklistItem(title: "20. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "Uses appropriate checklists & performs all ground operations", order: 19),
        ]
    )
    
    static let p1L5GroundReferenceManeuvers = ChecklistTemplate(
        name: "P1-L5: Ground Reference Maneuvers",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l5_ground_reference_maneuvers",
        items: [
            ChecklistItem(title: "1. Risk Management and Decision Making", notes: "Briefs the PAVE checklist and how it relates to decisions involving this flight", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Reviews with instructor resources available to assist the pilot in flight", order: 1),
            ChecklistItem(title: "3. Stall/Spin Awareness", notes: "Can explain what a stall is, the warning signs, how to recover, & what causes a spin", order: 2),
            ChecklistItem(title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Uses appropriate checklists & performs all ground operations", order: 3),
            ChecklistItem(title: "5. Radio Communications", notes: "With minimal aids, makes all taxi, takeoff, & pre-landing calls", order: 4),
            ChecklistItem(title: "6. Normal and Crosswind Take Off, Departure and Climb", notes: "Tracks centerline, normal liftoff, conforms to departure, climbs ±5 kts, scans for traffic", order: 5),
            ChecklistItem(title: "7. Fundamental Maneuvers Visual Reference", notes: "Uses coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°", order: 6),
            ChecklistItem(title: "8. Crab", notes: "Notes impact of crosswind on ground track & applies a crab angle to stay on  track", order: 7),
            ChecklistItem(title: "9. Turns Around a Point", notes: "Observes demo, notes wind, checks traffic, adjusts bank to correct for wind, ±200'", order: 8),
            ChecklistItem(title: "10. Rectangular Course", notes: "Notes wind, checks traffic, applies crab for crosswind, adjusts bank in turns, ±200'", order: 9),
            ChecklistItem(title: "11. Sideslip", notes: "Notes crosswind, uses sideslip to keep heading & track on ground course", order: 10),
            ChecklistItem(title: "12. Forward Slip", notes: "Uses slip to increase descent rate while keeping track aligned with ground reference", order: 11),
            ChecklistItem(title: "13. Power-Off Stall", notes: "Checks traffic, slows to a straight power-off stall & recovers at first indication", order: 12),
            ChecklistItem(title: "14. Power-On Stall", notes: "With assist, takeoff airspeed, adds power, pitches up, recovers at first indication", order: 13),
            ChecklistItem(title: "15. Power-Off Descent", notes: "Simulated emergency approach & landing to no lower than 500' AGL, ±15 kts", order: 14),
            ChecklistItem(title: "16. Go-Around Procedures", notes: "Practice go-around procedures at altitude (partial and full flaps), -50'", order: 15),
            ChecklistItem(title: "17. Airport Traffic Pattern", notes: "With minimal assist, complies with ATC instructions or non-tower procedures, ±150'", order: 16),
            ChecklistItem(title: "18. Normal and Crosswind Approach and Landing", notes: "With minimal assist, completes checklist, configures airplane, flies approach to landing", order: 17),
            ChecklistItem(title: "19. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "Uses appropriate checklists & performs all ground operations", order: 18),
        ]
    )
    
    static let p1L6EmergencyManeuvers = ChecklistTemplate(
        name: "P1-L6: Emergency Maneuvers",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l6_emergency_maneuvers",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist flight risk factors and plan to mitigate them ", order: 0),
            ChecklistItem(title: "2. Situational Awareness", notes: "Discusses methods of reorienting if temporarily lost in the local area", order: 1),
            ChecklistItem(title: "3. Wake Turbulence Avoidance", notes: "Explains procedures for taking off & landing after departing & arriving large aircraft", order: 2),
            ChecklistItem(title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Appropriate checklists, positions controls for X-wind & performs all ground operations", order: 3),
            ChecklistItem(title: "5. Normal and Crosswind Take Off, Departure and Climb", notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic", order: 4),
            ChecklistItem(title: "6. Blocked Pitot System or Static System", notes: "Explains indications & procedures", order: 5),
            ChecklistItem(title: "7. Primary Flight Display Failure", notes: "Explains indications & procedures", order: 6),
            ChecklistItem(title: "8. Electrical System Failure", notes: "Explains indications & procedures", order: 7),
            ChecklistItem(title: "9. Engine Failure (at Altitude) Simulated Landing", notes: "Assesses situation, best glide ±10 kts, best field, memory items", order: 8),
            ChecklistItem(title: "10. Engine Failure in Climb After Takeoff (at Altitude)", notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 9),
            ChecklistItem(title: "11. Emergency Descent", notes: "Idle, clears area, 30-45° bank, radio call, max speed for configuration and conditions  +0/-10 kts", order: 10),
            ChecklistItem(title: "12. Engine Fire", notes: "Memory items, best glide ±10 kts, best field, emerg approach checklist", order: 11),
            ChecklistItem(title: "13. Normal and Crosswind Approach and Landing", notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3", order: 12),
            ChecklistItem(title: "14. Landing at Tower Controlled or Non-Tower Controlled Airport", notes: "Traffic pattern procedures for the situation not yet experienced (if applicable)", order: 13),
            ChecklistItem(title: "15. No Flap Landing", notes: "Slip as necessary,  ±10 kts, no drift, smooth touchdown, first 1/3, center 1/3", order: 14),
            ChecklistItem(title: "16. Go-Around", notes: "Immediate takeoff power, pitch for VY, +10/-5, flaps up, offset as appropriate.        (Cram, Climb, Clean)", order: 15),
            ChecklistItem(title: "17. Rejected Takeoff", notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 16),
            ChecklistItem(title: "18. Forward Slip to Landing", notes: "Low wing into wind, track aligned w/runway, smooth recovery to landing first 1/3", order: 17),
            ChecklistItem(title: "19. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "Appropriate checklists, positions controls for X-wind & performs all ground operations", order: 18),
        ]
    )
    
    static let p1L7NormalTakeoffAndLandings = ChecklistTemplate(
        name: "P1-L7: Normal T/O & Landings",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l7_normal_takeoff_and_landings",
        items: [
            ChecklistItem(title: "1. Single Pilot Resource Management", notes: "Briefs resources available to assist the pilot in flight", order: 0),
            ChecklistItem(title: "2. Risk Management", notes: "Briefs the PAVE checklist discussing risk factors for this flight", order: 1),
            ChecklistItem(title: "3. Stall/Spin Awareness", notes: "Briefs stall characteristics & recovery procedure & spin recognition & recovery", order: 2),
            ChecklistItem(title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Appropriate checklists, positions controls for X-wind & performs all ground operations", order: 3),
            ChecklistItem(title: "5. Normal and Crosswind Take Off, Departure and Climb", notes: "Tracks C/L, smooth liftoff, conforms to procedures, climbs +10/-5 kts, scans for traffic", order: 4),
            ChecklistItem(title: "6. Pilotage", notes: "Correlates position on chart with prominent local landmarks & airspace", order: 5),
            ChecklistItem(title: "7. Steep Turns", notes: "Observes demo, 360° turns left and right, alt ±250', hdg ±20°, a/s ±10 kts, bank ±10°", order: 6),
            ChecklistItem(title: "8. Slow Flight (Straight & Level, Turns, Climbs, Descents)", notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°", order: 7),
            ChecklistItem(title: "9. Power-Off Stall", notes: "Clears traffic, power-off full stall, 15° bank turn ±10°,  prompt AOA, power & level wings", order: 8),
            ChecklistItem(title: "10. Descent at Approach Airspeed in Landing Configuration", notes: "Simulated stabilized approach to flare & go-around at altitude, a/s +10/-5 kts", order: 9),
            ChecklistItem(title: "11. Rectangular Course", notes: "Notes wind, checks traffic, parallel to reference, adjusts bank in turns, ±150'", order: 10),
            ChecklistItem(title: "12. S-Turns", notes: "Observes demo, notes wind, checks traffic, adjusts bank to correct for wind, ±150'", order: 11),
            ChecklistItem(title: "13. Straight and Level and Standard Rate Turns to a Heading (IR)", notes: "Under control, coordinated, alt ±200', hdg ±15°, a/s ±10 kts, bank ±10°", order: 12),
            ChecklistItem(title: "14. Airport Traffic Pattern", notes: "Radio calls, complies with instructions and/or procedures, alt ±100'", order: 13),
            ChecklistItem(title: "15. Normal Approach Landing (Full Stop)", notes: "Min. 3 landings to full stop, stabilized, +10/-5 kts, lands center 1/3, landing attitude", order: 14),
            ChecklistItem(title: "16. Go-Around Procedures", notes: "Execute go-arounds from base, final, and start of flare with minimal altitude loss", order: 15),
            ChecklistItem(title: "17. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "Appropriate checklists, positions controls for X-wind & performs all ground operations", order: 16),
        ]
    )
    
    static let p1L8CrosswindTakeoffAndLanding = ChecklistTemplate(
        name: "P1-L8: Crosswind T/O & Landing",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l8_crosswind_takeoff_and_landing",
        items: [
            ChecklistItem(title: "1. Single Pilot Resource Management", notes: "Briefs resources available for assistance during this flight", order: 0),
            ChecklistItem(title: "2. Risk Management", notes: "Briefs PAVE checklist flight risk factors including required runway for takeoff & landing ", order: 1),
            ChecklistItem(title: "3. Wake Turbulence Avoidance", notes: "Explains procedures for taking off & landing after departing & arriving large aircraft", order: 2),
            ChecklistItem(title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Appropriate checklists, positions controls for X-wind & performs all ground operations", order: 3),
            ChecklistItem(title: "5. Normal and Crosswind Take Off, Departure and Climb", notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic", order: 4),
            ChecklistItem(title: "6. Pilotage", notes: "Correlates position on chart with prominent local landmarks & airspace", order: 5),
            ChecklistItem(title: "7. Steep Turns", notes: "Clears area, 360° turns both directions, alt ±200', hdg ±20°, a/s ±10 kts, bank ±10°", order: 6),
            ChecklistItem(title: "8. Slow Flight (Straight & Level, Turns, Climbs, Descents)", notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°", order: 7),
            ChecklistItem(title: "9. Forward Slip Left and Right (at altitude)", notes: "Stable pitch attitude, track aligned with ground reference, recovers approach at altitude", order: 8),
            ChecklistItem(title: "10. Ground Reference Maneuvers", notes: "Checks for traffic & obstructions, alt ±150', corrects for wind in straight & turning flight", order: 9),
            ChecklistItem(title: "11. Demonstration of Faulty Approach and Landing and Corrections", notes: "Observes instructor demo of correction & go-around for approach & landing errors", order: 10),
            ChecklistItem(title: "12. Normal Approach and Landing", notes: "Stabilized, +10/-5 kts, touchdown first 1/3,  center 1/3, landing attitude", order: 11),
            ChecklistItem(title: "13. Forward Slip to Landing", notes: "Low wing into wind, ground track aligned with runway, recovers from slip for flare", order: 12),
            ChecklistItem(title: "14. Sideslip Exercise Over Runway", notes: "Observes demo, 5-10' above & parallel to runway, sideslip one side to other, go-around", order: 13),
            ChecklistItem(title: "15. Crosswind Landing (Full Stop)", notes: "Min. 3 , tracks C/L, lands center 1/3, parallel to runway, +10/-5 kts, landing attitude", order: 14),
            ChecklistItem(title: "16. Go-Around", notes: "Immediate takeoff power, pitch for V Y , +10/-5, retract flaps, offset as appropriate (Cram Climb, Clean)", order: 15),
            ChecklistItem(title: "17. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "Appropriate checklists, positions controls for X-wind & performs all ground operations", order: 16),
        ]
    )
    
    static let p1L9ShortSoftFieldTakeoffAndLanding = ChecklistTemplate(
        name: "P1-L9: Short/Soft Field T/O & Landing",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l9_short_soft_field_takeoff_and_landing",
        items: [
            ChecklistItem(title: "1. Calculate Takeoff and Landing Performance", notes: "Notes variances with daily high/low temps, uses conservative data & margin for skill/airplane ", order: 0),
            ChecklistItem(title: "2. Risk Management", notes: "Briefs PAVE checklist focusing on performance and runway factors", order: 1),
            ChecklistItem(title: "3. Windshear Awareness and Recovery", notes: "Explains windshear conditions, indications and recovery procedures", order: 2),
            ChecklistItem(title: "4. Stall/Spin Awareness", notes: "Explains stall & spin causes, characteristics & recovery procedures", order: 3),
            ChecklistItem(title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls", order: 4),
            ChecklistItem(title: "6. Short Field Takeoff and Climb", notes: "Observes demo, notes where 50' & 100' AGL, config, lift off a/s per AFM/POH , pitch to V X", order: 5),
            ChecklistItem(title: "7. Engine Failure in Climb After Takeoff (at Altitude)", notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 6),
            ChecklistItem(title: "8. Slow Flight with Realistic Distractions (Straight & Level, Turns, Climbs, Descents)", notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +10/-0 kts, bank ±10°", order: 7),
            ChecklistItem(title: "9. Power-Off Stall", notes: "Clears area, full stall, 15° bank turn ±10°,  coordinated, prompt lower AOA, power & level wings", order: 8),
            ChecklistItem(title: "10. Power-On Stall", notes: "Clears area, full stall, 15° bank turn ±10°,  coordinated , prompt lower AOA, power & level wings", order: 9),
            ChecklistItem(title: "11. Rectangular Course", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 10),
            ChecklistItem(title: "12. Turns Around a Point", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 11),
            ChecklistItem(title: "13. S-Turns", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 12),
            ChecklistItem(title: "14. Short Field Approach and Landing", notes: "Observes demo, stabilized approach +10/-5 kts, touches down  +400'/-0', stops in shortest distance", order: 13),
            ChecklistItem(title: "15. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls", order: 14),
        ]
    )
    
    // MARK: - Pre-Solo Templates
    
    static let endorsements = ChecklistTemplate(
        name: "Endorsements",
        category: "PPL",
        phase: "Pre-Solo",
        templateIdentifier: "default_endorsements",
        items: [
            //ChecklistItem(title: "A.1 Prerequisites for practical test: Title 14 or the Code of Federal Regulations (14 CFR) part 61. 61.39(a)(6)(1) and (2)", notes: "", order: 0),
            //ChecklistItem(title: "I certify that (first, middle, last) has received and logged training time within 2 calendar-months preceding the month of application in preparation for the practical test and he/she is prepared for the required practical test for the issuance of Private Pilot Certificate", notes: "", order: 1),
            //ChecklistItem(title: "A.2 Review of deficiencies identified on airman knowledge test: 61.39(a)(6)(i), as required.", notes: "", order: 2),
            //ChecklistItem(title: "I certify that (first, middle, last) has demonstrated satisfactory knowledge of the subject areas in which he/she was deficient on the Private Pilot Certificate airman knowledge test.", notes: "", order: 3),
            ChecklistItem(title: "A.3 Aeronautical knowledge 61.87(b) (Pre-solo written to 100%. I have to ensure that their written test deficiencies have been reviewed and corrected to 100% by explaining to them the areas they got wrong.)", notes: "", order: 4),
            ChecklistItem(title: "I certify that (first, middle, last) has satisfactorily completed the pre-solo knowledge test of 61.87(b) for the [make and model] aircraft.", notes: "", order: 5),
            ChecklistItem(title: "A.4 Pre-Solo Training to Proficiency 61.87(c)(1)(2) and 61.87(d). (I must cover all 15 procedures and maneuvers and determine that student is both safe and proficient)", notes: "", order: 6),
            ChecklistItem(title: "I certify that (first, middle, last) has received and logged pre-solo flight training for, the maneuvers and procedures that are appropriate to make the [make and model] aircraft. I have determined that (he or she) has demonstrated satisfactory proficiency and safety on the maneuvers and procedures required by 61.87 in this or similar make and model of aircraft to be flown.", notes: "", order: 7),
            ChecklistItem(title: "A.6 Solo flight (first 90 calendar day period): 61.87(n)", notes: "", order: 8),
            ChecklistItem(title: "I certify that (first, middle, last) has received the required training to qualify for solo flying. I have determined that he or she meets the applicable requirements of 61.87(n) and is proficient to make solo flights in the (make and model).", notes: "", order: 9),
        ]
    )
    
    static let preSoloQuiz = ChecklistTemplate(
        name: "Pre-Solo Quiz",
        category: "PPL",
        phase: "Pre-Solo",
        templateIdentifier: "default_pre_solo_quiz",
        items: [
            ChecklistItem(title: "Administer, Grade and correct pre-solo quiz", notes: "", order: 0),
        ]
    )
    
    static let preSoloTraining6187 = ChecklistTemplate(
        name: "Pre-Solo Training (61.87)",
        category: "PPL",
        phase: "Pre-Solo",
        templateIdentifier: "default_pre_solo_training_6187",
        items: [
            ChecklistItem(title: "(1) Proper flight preparation procedures including, Preflight planning, Powerplant operations, and aircraft systems", notes: "", order: 0),
            ChecklistItem(title: "(2) Taxiing or surface operations, including runups", notes: "", order: 1),
            ChecklistItem(title: "(3) Takeoffs and landings, including normal and crosswind", notes: "", order: 2),
            ChecklistItem(title: "(4) Straight and level flight, and turns in both directions", notes: "", order: 3),
            ChecklistItem(title: "(5) Climbs and climbing turns", notes: "", order: 4),
            ChecklistItem(title: "(6) Airport traffic patterns, including entry and departure procedures", notes: "", order: 5),
            ChecklistItem(title: "(7) Collision avoidance, wind-shear avoidance, and wake turbulence avoidance", notes: "", order: 6),
            ChecklistItem(title: "(8) Descents, with and without turns, using high and low drag configurations", notes: "", order: 7),
            ChecklistItem(title: "(9) Flight at various airspeeds from cruise to slow flight", notes: "", order: 8),
            ChecklistItem(title: "(10) Stall entries from various flight attitudes and power combinations with recovery initiated at first indication of a stall", notes: "", order: 9),
            ChecklistItem(title: "(11) Emergency Procedures and equipment malfunctions", notes: "", order: 10),
            ChecklistItem(title: "(12) Ground reference maneuvers", notes: "", order: 11),
            ChecklistItem(title: "(13) Approaches to a landing area with simulated engine malfunctions", notes: "", order: 12),
            ChecklistItem(title: "(14) Slips to a landing", notes: "", order: 13),
            ChecklistItem(title: "(15) Go-Arounds", notes: "", order: 14),
        ]
    )
    
    // MARK: - Phase 2 Templates (Empty for now)
    
    static let p2L1PilotageAndDeadReckoning = ChecklistTemplate(
        name: "P2-L1: Pilotage and Dead Reckoning",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l1_pilotage_and_dead_reckoning",
        items: []
    )
    
    static let p2L2NavigationAids = ChecklistTemplate(
        name: "P2-L2: Navigation Aids",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l2_navigation_aids",
        items: []
    )
    
    static let p2L3Short100MileCrossCountry = ChecklistTemplate(
        name: "P2-L3: Short (<100 mile) Cross country",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l3_short_100_mile_cross_country",
        items: []
    )
    
    static let p2L4NightFlying = ChecklistTemplate(
        name: "P2-L4: Night Flying",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l4_night_flying",
        items: []
    )
    
    static let p2L5Short100MileCrossCountry = ChecklistTemplate(
        name: "P2-L5: Short (<100 mile) Cross Country",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l5_short_100_mile_cross_country",
        items: []
    )
    
    static let p2L6FlyingByInstruments = ChecklistTemplate(
        name: "P2-L6: Flying by Instruments",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l6_flying_by_instruments",
        items: []
    )
    
    static let p2L7Phase2Check = ChecklistTemplate(
        name: "P2-L7: Phase 2 check",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l7_phase_2_check",
        items: []
    )
    
    // MARK: - Phase 3 Templates (Empty for now)
    
    static let p390DaySoloEndorsement = ChecklistTemplate(
        name: "P3 90 day Solo endorsement",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_90_day_solo_endorsement",
        items: []
    )
    
    static let p3AdditionXCEndorsements = ChecklistTemplate(
        name: "P3 Addition XC endorsements",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_addition_xc_endorsements",
        items: []
    )
    
    static let p3CheckridePreparation = ChecklistTemplate(
        name: "P3 Checkride Preparation",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_checkride_preparation",
        items: []
    )
    
    static let p3FirstXCEndorsement6193 = ChecklistTemplate(
        name: "P3 First XC endorsement (61.93)",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_first_xc_endorsement_6193",
        items: []
    )
    
    static let p3FlightProficiencyPracticalTest6107 = ChecklistTemplate(
        name: "P3 Flight Proficiency [Practical test] (61.107)",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_flight_proficiency_practical_test_6107",
        items: []
    )
    
    static let p3KnowledgeAreas = ChecklistTemplate(
        name: "P3 Knowledge Areas",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_knowledge_areas",
        items: []
    )
    
    static let p3PrivatePilotEndorsements = ChecklistTemplate(
        name: "P3 Private Pilot Endorsements",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_private_pilot_endorsements",
        items: []
    )
    
    static let p3L1XCSolo = ChecklistTemplate(
        name: "P3-L1: XC Solo",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l1_xc_solo",
        items: []
    )
    
    static let p3L2XC150NMSolo = ChecklistTemplate(
        name: "P3-L2: XC 150nm solo",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l2_xc_150nm_solo",
        items: []
    )
    
    // MARK: - Phase 4 Templates (Empty for now)
    
    static let p4CheckrideChecklist = ChecklistTemplate(
        name: "P4 Checkride Checklist",
        category: "PPL",
        phase: "Phase 4",
        templateIdentifier: "default_p4_checkride_checklist",
        items: []
    )
    
    static let p4PracticalTestEndorsements = ChecklistTemplate(
        name: "P4 Practical Test Endorsements",
        category: "PPL",
        phase: "Phase 4",
        templateIdentifier: "default_p4_practical_test_endorsements",
        items: []
    )
    
    static let p4PrivatePilotOverview = ChecklistTemplate(
        name: "P4 Private Pilot Overview",
        category: "PPL",
        phase: "Phase 4",
        templateIdentifier: "default_p4_private_pilot_overview",
        items: []
    )
    
    static let p4WrittenTestEndorsements = ChecklistTemplate(
        name: "P4 Written Test Endorsements",
        category: "PPL",
        phase: "Phase 4",
        templateIdentifier: "default_p4_written_test_endorsements",
        items: []
    )
    
    // MARK: - All Templates Array
    
    static let allTemplates: [ChecklistTemplate] = [
        // First Steps
        studentOnboardTrainingOverview,
        // Phase 1
        p1L10ManeuverReview,
        p1L1StraightAndLevelFlight,
        p1L2BasicAircraftOperations,
        p1L3InstrumentsAndInvestigatingSlowFlight,
        p1L4SlowFlightAndStalls,
        p1L5GroundReferenceManeuvers,
        p1L6EmergencyManeuvers,
        p1L7NormalTakeoffAndLandings,
        p1L8CrosswindTakeoffAndLanding,
        p1L9ShortSoftFieldTakeoffAndLanding,
        // Pre-Solo
        endorsements,
        preSoloQuiz,
        preSoloTraining6187,
        // Phase 2
        p2L1PilotageAndDeadReckoning,
        p2L2NavigationAids,
        p2L3Short100MileCrossCountry,
        p2L4NightFlying,
        p2L5Short100MileCrossCountry,
        p2L6FlyingByInstruments,
        p2L7Phase2Check,
        // Phase 3
        p390DaySoloEndorsement,
        p3AdditionXCEndorsements,
        p3CheckridePreparation,
        p3FirstXCEndorsement6193,
        p3FlightProficiencyPracticalTest6107,
        p3KnowledgeAreas,
        p3PrivatePilotEndorsements,
        p3L1XCSolo,
        p3L2XC150NMSolo,
        // Phase 4
        p4CheckrideChecklist,
        p4PracticalTestEndorsements,
        p4PrivatePilotOverview,
        p4WrittenTestEndorsements
    ]
}
