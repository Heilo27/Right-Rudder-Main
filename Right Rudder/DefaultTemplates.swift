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
            ChecklistItem(title: "1. Previous flight training", notes: "Document previous flight training experience", order: 0),
            ChecklistItem(title: "2. Logbook Review", notes: "Review student's existing logbook entries", order: 1),
            ChecklistItem(title: "3. Contact information", notes: "Verify all contact details are complete and accurate", order: 2),
            ChecklistItem(title: "4. A.14 Endorsement of U.S. Citizenship recommended by the TSA.", notes: "\"I certify that [first name, MI, last name], has presented me a [type of document presented, such as a US birth certificate or US passport and the relevant control or sequential number on the document, if any], establishing that they are a US citizen or national in accordance with 49 CFR 1552.15(c)\"", order: 3),
        ]
    )
    
    // MARK: - Phase 1 Templates
    
    static let p1L1StraightAndLevelFlight = ChecklistTemplate(
        name: "P1-L1: Straight and Level Flight",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l1_straight_and_level_flight",
        items: [
            ChecklistItem(title: "1. Safety Practices, Procedures and Equipment", notes: "Understands hazards, door, seat, safety belt, and fire extinguisher operation", order: 0),
            ChecklistItem(title: "2. Preflight Inspection, Flight Control and Systems Operation", notes: "Observes preflight demo using checklist; understands switch & control functions", order: 1),
            ChecklistItem(title: "3. Positive Exchange of Flight Controls", notes: "Understands and uses the positive three-step exchange of controls", order: 2),
            ChecklistItem(title: "4. Prestart checklist, Engine Starting and Warm-up", notes: "Observes prestart checklist, starting and warm up procedures", order: 3),
            ChecklistItem(title: "5. Taxiing", notes: "Observes demo. With instructor, assists with controling the airplane, observes signs and markings", order: 4),
            ChecklistItem(title: "6. Before Takeoff Checks and Engine Runup", notes: "Observes pretakeoff checklist and engine runup", order: 5),
            ChecklistItem(title: "7. Normal Takeoff and Climb", notes: "Observes & is lightly on the controls for instructor's takeoff & initial climb", order: 6),
            ChecklistItem(title: "8. Level-off", notes: "Observes and is lightly on the controls for instructor's level-off from initial climb", order: 7),
            ChecklistItem(title: "9. Checklist Use", notes: "Observes instructor use of checklists for all phases of flight", order: 8),
            ChecklistItem(title: "10. Collision Avoidance", notes: "Observes demo of clearing for traffic during climbs, descents, and before turns", order: 9),
            ChecklistItem(title: "11. Trimming", notes: "Senses the changes in control pressure and moves trim wheel in the correct direction", order: 10),
            ChecklistItem(title: "12. Straight and Level", notes: "Notes reference point and altitude changes and initiates corrections ", order: 11),
            ChecklistItem(title: "13. Demonstration of tendency to maintain straight and level flight", notes: "Observes instructor demonstration of pitch and bank stability", order: 12),
            ChecklistItem(title: "14. Turn Coordination", notes: "With instructor assistance, applies rudder when starting & stopping turns", order: 13),
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
            ChecklistItem(title: "14. Flying Slowly", notes: "With assist, slows to 1.1xVS0 S&L, shallow turns, note changes in force, response & sound", order: 13),
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
            ChecklistItem(title: "16. Go-Around", notes: "Immediate takeoff power, pitch for Vy, +10/-5, flaps up, offset as appropriate. (Cram, Climb, Clean)", order: 15),
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
            ChecklistItem(title: "16. Go-Around", notes: "Immediate takeoff power, pitch for Vy , +10/-5, retract flaps, offset as appropriate (Cram Climb, Clean)", order: 15),
            ChecklistItem(title: "17. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "Appropriate checklists, positions controls for X-wind & performs all ground operations", order: 16),
        ]
    )
    
    static let p1L9ManeuverReview = ChecklistTemplate(
        name: "P1-L9: Maneuver Review",
        category: "PPL",
        phase: "Phase 1",
        templateIdentifier: "default_p1_l9_maneuver_review",
        items: [
            ChecklistItem(title: "1. Risk Managment", notes: "Using PAVE checklist briefs risk factors for this flight & how to mitigate them ", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Explains resources available for assistance during this flight", order: 1),
            ChecklistItem(title: "3. Situational Awareness", notes: "Explains methods of reorienting if lost or disoriented", order: 2),
            ChecklistItem(title: "4. Stall/Spin Awareness", notes: "Explains stall & spin causes, characteristics & recovery procedures", order: 3),
            ChecklistItem(title: "5. Wake Turbulence Avoidance", notes: "Explains procedures for taking off & landing after departing & arriving large aircraf t", order: 4),
            ChecklistItem(title: "6. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls", order: 5),
            ChecklistItem(title: "7. Radio Communications", notes: "Makes all appropriate calls, understands or requests clarification for instructions", order: 6),
            ChecklistItem(title: "8. Collision Avoidance", notes: "Clears traffic before all operations on the ground & airborne ", order: 7),
            ChecklistItem(title: "9. Normal and Crosswind Take Off, Departure and Climb", notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic", order: 8),
            ChecklistItem(title: "10. Fundamental Maneuvers VR (Straight & Level, Turns, Climbs, Descents) ", notes: "Coordinated controls, in trim, alt ±100', hdg ±10°, a/s ±10 kts, bank ±10°", order: 9),
            ChecklistItem(title: "11. Fundamental Maneuvers IR (Straight & Level, Turns, Climbs, Descents)", notes: "Coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°", order: 10),
            ChecklistItem(title: "12. Steep Turns", notes: "Clears area, 360° L&R, coordinated, alt ±150', hdg ±15°, a/s ±10 kts, bank ±10°", order: 11),
            ChecklistItem(title: "13. Slow Flight (Straight & Level, Turns, Climbs, Descents)", notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°", order: 12),
            ChecklistItem(title: "14. Power-Off and Power-On Stall", notes: "Clears area, full stall, 15° bank turn ±10°,  prompt AOA, power & level wings", order: 13),
            ChecklistItem(title: "15. Engine Failures at Altitude and in Climb ", notes: "Assesses situation, best glide ±10 kts, best field, memory items", order: 14),
            ChecklistItem(title: "16. Ground Reference Maneuvers", notes: "Checks for traffic & obstructions, alt ±150', corrects for wind in straight & turning flight", order: 15),
            ChecklistItem(title: "17. Normal and Crosswind Approach and Landing", notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3", order: 16),
            ChecklistItem(title: "18. No Flap Landing", notes: "Slip as necessary,  ±10 kts, no drift, smooth touchdown, first 1/3, center 1/3", order: 17),
            ChecklistItem(title: "19. Rejected Takeoff", notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 18),
            ChecklistItem(title: "20. Go-Around", notes: "Immediate takeoff power, pitch for Vy , +10/-5, flaps up, offset as appropriate (Cram, Climb, Clean)", order: 19),
            ChecklistItem(title: "21. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls", order: 20),
        ]
    )
    
    // MARK: - Phase 2 Templates
    
    static let p2L1ReviewAndSecondSolo = ChecklistTemplate(
        name: "P2-L1: Review & second Solo",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l1_review_and_second_solo",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Using PAVE checklist briefs risk factors for this flight & how to mitigate them ", order: 0),
            ChecklistItem(title: "2. Wake Turbulence Avoidance", notes: "Explains procedures for taking off & landing after departing & arriving large aircraft", order: 1),
            ChecklistItem(title: "3. Cockpit Management", notes: "Checks safety equipment, all loose items secured, organizes all material to be readily accessible", order: 2),
            ChecklistItem(title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls", order: 3),
            ChecklistItem(title: "5. Normal and Crosswind Takeoff, Departure and Climb", notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic", order: 4),
            ChecklistItem(title: "6. Engine Failure in Climb After Takeoff (at Altitude)", notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 5),
            ChecklistItem(title: "7. Pilotage to and from Practice Area", notes: "Navigates most suitable route to and from practice area using chart & landmarks ", order: 6),
            ChecklistItem(title: "8. Slow Flight (Straight & Level, Turns, Climbs, Descents)", notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +15/-0 kts, bank ±10°", order: 7),
            ChecklistItem(title: "9. Power-Off and Power-On Stalls", notes: "Clears area, full stall, 15° bank turn ±10°,  prompt lower AOA, power & level wings", order: 8),
            ChecklistItem(title: "10. Steep Turns", notes: "Clears area, 360° turns both directions, alt ±100', a/s ±10 kts, bank ±5°, hdg ±10°", order: 9),
            ChecklistItem(title: "11. Engine Fire in Flight, Emergency Descent and Landing (Simulated)", notes: "Fire memory items, emerg descent config, best glide ±10 kts, best field, emerg approach checklist", order: 10),
            ChecklistItem(title: "12. Normal and Crosswind Approach and Landing", notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3", order: 11),
            ChecklistItem(title: "13. Forward Slip to Landing", notes: "Low wing into wind, ground track aligned with runway, recovers from slip for flare", order: 12),
            ChecklistItem(title: "14. Normal Takeoff and Climb (Solo)", notes: "Radio calls, X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic", order: 13),
            ChecklistItem(title: "15. Pilotage to Practice or Designated Area within 10 NM (Solo)", notes: "Navigates most suitable route to practice area using chart & landmarks ", order: 14),
            ChecklistItem(title: "16. Steep Turns (Solo)", notes: "Clears practice area, 360° turns both directions, alt ±100', a/s ±10 kts, bank ±5°, hdg ±10°", order: 15),
            ChecklistItem(title: "17. Pilotage from Practice or Designated Area (Solo)", notes: "Navigates most suitable route from practice area to airport using chart & landmarks ", order: 16),
            ChecklistItem(title: "18. Airport Traffic Pattern (Solo)", notes: "Appropriate radio calls, complies with instructions and/or procedures, alt ±100'", order: 17),
            ChecklistItem(title: "19. Normal Approach and Landing (Solo)", notes: "3 landings to full stop", order: 18),
            ChecklistItem(title: "20. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls", order: 19),
        ]
    )
    
    static let p2L2ShortFieldTakeoffAndLanding = ChecklistTemplate(
        name: "P2-L2: Short Field T/O & Landing",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l2_short_field_takeoff_and_landing",
        items: [
            ChecklistItem(title: "1. Calculate Takeoff and Landing Performance", notes: "Notes variances with daily high/low temps, uses conservative data & margin for skill/airplane ", order: 0),
            ChecklistItem(title: "2. Risk Management", notes: "Briefs PAVE checklist focusing on performance and runway factors", order: 1),
            ChecklistItem(title: "3. Windshear Awareness and Recovery", notes: "Explains windshear conditions, indications and recovery procedures", order: 2),
            ChecklistItem(title: "4. Stall/Spin Awareness", notes: "Explains stall & spin causes, characteristics & recovery procedures", order: 3),
            ChecklistItem(title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls", order: 4),
            ChecklistItem(title: "6. Short Field Takeoff and Climb", notes: "Observes demo, notes where 50' & 100' AGL, config, lift off a/s per AFM/POH , pitch to Vx", order: 5),
            ChecklistItem(title: "7. Engine Failure in Climb After Takeoff (at Altitude)", notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 6),
            ChecklistItem(title: "8. Slow Flight with Realistic Distractions (Straight & Level, Turns, Climbs, Descents)", notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +10/-0 kts, bank ±10°", order: 7),
            ChecklistItem(title: "9. Power-Off Stall", notes: "Clears area, full stall, 15° bank turn ±10°, coordinated, prompt lower AOA, power & level wings", order: 8),
            ChecklistItem(title: "10. Power-On Stall", notes: "Clears area, full stall, 15° bank turn ±10°, coordinated , prompt lower AOA, power & level wings", order: 9),
            ChecklistItem(title: "11. Rectangular Course", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 10),
            ChecklistItem(title: "12. Turns Around a Point", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 11),
            ChecklistItem(title: "13. S-Turns", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 12),
            ChecklistItem(title: "14. Short Field Approach and Landing", notes: "Observes demo, stabilized approach +10/-5 kts, touches down  +400'/-0', stops in shortest distance", order: 13),
            ChecklistItem(title: "15. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls", order: 14),
        ]
    )
    
    static let p2L3BuildingSkillWithManeuversAndLandings = ChecklistTemplate(
        name: "P2-L3: Building skill with Maneuvers and Landings",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l3_building_skill_with_maneuvers_and_landings",
        items: [
            ChecklistItem(title: "1. Calculate Takeoff and Landing Performance", notes: "Notes variances with daily high/low temps, uses conservative data & margin for skill/airplane ", order: 0),
            ChecklistItem(title: "2. Calculate Weight and Balance", notes: "Notes difference in CG location from dual flights", order: 1),
            ChecklistItem(title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls", order: 2),
            ChecklistItem(title: "4. Normal and Crosswind Takeoff, Departure and Climb", notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic", order: 3),
            ChecklistItem(title: "5. Pilotage to Practice Area", notes: "Navigates most suitable route to practice area using chart & landmarks", order: 4),
            ChecklistItem(title: "6. Steep Turns", notes: "Clears area, 360° turns both directions, alt ±100', a/s ±10 kts, bank ±5°, hdg ±10°", order: 5),
            ChecklistItem(title: "7. Rectangular Course", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 6),
            ChecklistItem(title: "8. Turns Around a Point", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 7),
            ChecklistItem(title: "9. S-Turns", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 8),
            ChecklistItem(title: "10. Pilotage from Practice Area", notes: "Navigates most suitable route from practice area to airport using chart & landmarks ", order: 9),
            ChecklistItem(title: "11. Airport Traffic Pattern", notes: "Appropriate entry, radio calls, complies with instructions and/or procedures, alt ±100'", order: 10),
            ChecklistItem(title: "12. Forward Slip to Landing", notes: "Low wing into wind, ground track aligned with runway, recovers from slip for flare", order: 11),
            ChecklistItem(title: "13. Normal Approach and Landing", notes: "3 landings to full stop", order: 12),
            ChecklistItem(title: "14. Go-Around", notes: "Immediate takeoff power, pitch for Vy, +10/-5, flaps up, offset as appropriate", order: 13),
            ChecklistItem(title: "15. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls", order: 14),
        ]
    )
    
    static let p2L4SoftFieldTakeoffAndLandings = ChecklistTemplate(
        name: "P2-L4: Soft Field T/O & Landings",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l4_soft_field_takeoff_and_landings",
        items: [
            ChecklistItem(title: "1. Calculate Takeoff and Landing Performance", notes: "Applies factors for soft runway surface, uses conservative data & margin for skill/airplane ", order: 0),
            ChecklistItem(title: "2. Risk Management", notes: "Briefs PAVE checklist focusing on performance and runway factors", order: 1),
            ChecklistItem(title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls", order: 2),
            ChecklistItem(title: "4. Taxiing for Soft Field Takeoff", notes: "Positions controls X-wind & light nose, clears area, maintains safe speed without stopping", order: 3),
            ChecklistItem(title: "5. Soft Field Takeoff and Climb", notes: "Planned no-go, controls & config set, earliest possible lift off, ground effect until Vx/Vy , +10/-5 ", order: 4),
            ChecklistItem(title: "6. Rejected Takeoff", notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 5),
            ChecklistItem(title: "7. Engine Failure in Climb After Takeoff", notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 6),
            ChecklistItem(title: "8. Slow Flight with Realistic Distractions (Straight & Level, Turns, Climbs, Descents)", notes: "Smooth, coordinated controls, alt ±150', hdg ±10°, a/s +10/-0 kts, bank ±10°", order: 7),
            ChecklistItem(title: "9. Power-Off Stall", notes: "Clears area, full stall, 15° bank turn ±10°, coordinated, prompt lower AOA, power & level wings", order: 8),
            ChecklistItem(title: "10. Power-On Stall", notes: "Clears area, full stall, 15° bank turn ±10°, coordinated , prompt lower AOA, power & level wings", order: 9),
            ChecklistItem(title: "11. Engine Fire in Flight, Emergency Descent and Landing (Simulated)", notes: "Fire memory items, emerg descent config, best glide ±10 kts, best field, emerg approach checklist", order: 10),
            ChecklistItem(title: "12. S-Turns", notes: "Checks for traffic & obstructions, alt ±100', corrects for wind in straight & turning flight", order: 11),
            ChecklistItem(title: "13. Soft Field Approach and Landing", notes: "Observes demo, stabilized approach +10/-5 kts, touches down softly", order: 12),
            ChecklistItem(title: "14. Short Field Takeoff and Climb", notes: "Briefs no-go, config., lift off & airspeed per AFM/POH , pitches to Vx until obstacle cleared ", order: 13),
            ChecklistItem(title: "15. Short Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance", order: 14),
            ChecklistItem(title: "16. Go-Around", notes: "Immediate takeoff power, pitch for Vy , +10/-5, flaps up, offset as appropriate", order: 15),
            ChecklistItem(title: "17. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls", order: 16),
        ]
    )
    
    static let p2L5Phase2Overview = ChecklistTemplate(
        name: "P2-L5: Phase 2 Overview",
        category: "PPL",
        phase: "Phase 2",
        templateIdentifier: "default_p2_l5_phase_2_overview",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist including W&B, fuel, & performance, use of the CARE checklist in-flight", order: 0),
            ChecklistItem(title: "2. Emergency Equipment and Survival Gear", notes: "Explains location and use of emergency equipment, evaluates adequacy for this flight", order: 1),
            ChecklistItem(title: "3. Single Pilot Resource Management", notes: "Briefs planned use of available resources during flight", order: 2),
            ChecklistItem(title: "4. Flight Planning ", notes: "Briefs planned route, checkpoints, alternates, weather, NOTAMS, airspace, terrain, navigation log ", order: 3),
            ChecklistItem(title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass", order: 4),
            ChecklistItem(title: "6. Short Field Takeoff, Climb and Departure", notes: "No-go, config., liftoff a/s per POH/AFM, Vx ± 5 kts until obstacle cleared, turns to heading", order: 5),
            ChecklistItem(title: "7. FSS and ATC Radar Service", notes: "Opens flight plan with FSS and contacts appropriate ATC facility for VFR Flight Following", order: 6),
            ChecklistItem(title: "8. En Route Cruise", notes: "Uses power & mixture settings per POH/AFM, TAS and Fuel Flow planning, hdg ±10°, alt ±100'", order: 7),
            ChecklistItem(title: "9. Navigation (DR, Pilotage, VOR and GPS)", notes: "Keeps nav log, uses DR, pilotage & electronic nav, track within 2 nm of course, ETA ±3 min", order: 8),
            ChecklistItem(title: "10. Cockpit Management", notes: "Equipment and materials organized, easily accessible and restrained", order: 9),
            ChecklistItem(title: "11. Task Management", notes: "Prioritizes and manages tasks by selecting the most appropriate for the moment ", order: 10),
            ChecklistItem(title: "12. Collision Avoidance", notes: "Divides attention among all tasks making sure that looking for traffic is not abandoned ", order: 11),
            ChecklistItem(title: "13. Heading Indicator Failure ", notes: "Simulated HI failure, use compass for headings, hdg ±10°", order: 12),
            ChecklistItem(title: "14. Electrical Failure ", notes: "Simulated emergency, reverts to DR & pilotage, decides go to destination, alternate, or return", order: 13),
            ChecklistItem(title: "15. Lost Procedures", notes: "Instructor introduces realistic distractions requiring use of lost procedures for reorientation", order: 14),
            ChecklistItem(title: "16. Diversion to an Alternate", notes: "Scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel, advises ATC", order: 15),
            ChecklistItem(title: "17. Short Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance", order: 16),
            ChecklistItem(title: "18. Soft Field Takeoff, Climb and Departure ", notes: "No-go, controls/config set, earliest liftoff, ground effect until Vx/Vy , +10/-5, turns to heading ", order: 17),
            ChecklistItem(title: "19. Soft Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction", order: 18),
            ChecklistItem(title: "20. No Flap Landing", notes: "Slip as necessary, ±10 kts, no drift, smooth touchdown, first 500'", order: 19),
            ChecklistItem(title: "21. After Landing, Taxi, Parking, Post Flight Procedures and Refueling", notes: "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan", order: 20),
        ]
    )
    
    // MARK: - Pre-Solo/Solo Templates
    
    static let preSoloQuizAndDocuments = ChecklistTemplate(
        name: "Pre-Solo Quiz & Documents",
        category: "PPL",
        phase: "Phase 1.5 Pre-Solo/Solo",
        templateIdentifier: "default_pre_solo_quiz_and_documents",
        items: [
            ChecklistItem(title: "1. Administer, Grade, and Correct pre-solo quiz", notes: "Pass is 100% corrected", order: 0),
            ChecklistItem(title: "2. Medical Certificate", notes: "1st, 2nd, or 3rd class medical clearance", order: 1),
            ChecklistItem(title: "3. Student Pilot Certificate", notes: "Uploaded", order: 2),
        ]
    )
    
    static let preSoloTrainingCheckoff = ChecklistTemplate(
        name: "Pre-Solo Training Checkoff (61.87)",
        category: "PPL",
        phase: "Phase 1.5 Pre-Solo/Solo",
        templateIdentifier: "default_pre_solo_training_checkoff",
        items: [
            ChecklistItem(title: "1. Proper flight preparation procedures including, Preflight planning, Powerplant operations, and aircraft systems", notes: "", order: 0),
            ChecklistItem(title: "2. Taxiing or surface operations, including runups", notes: "To be filled in later", order: 1),
            ChecklistItem(title: "3. Takeoffs and landings, including normal and crosswind", notes: "", order: 2),
            ChecklistItem(title: "4. Straight and Level flight, and turns in both directions", notes: "", order: 3),
            ChecklistItem(title: "5. Climbs and climbing turns", notes: "", order: 4),
            ChecklistItem(title: "6. Airport traffic patterns, including entry and departure procedures", notes: "", order: 5),
            ChecklistItem(title: "7. Collision avoidance, wind-sheer avoidance, and wake turbulance avoidance", notes: "", order: 6),
            ChecklistItem(title: "8. Descents, with and without turns, using high and low drag configurations", notes: "", order: 7),
            ChecklistItem(title: "9. Flight at various airspeeds from cruise to slow flight", notes: "", order: 8),
            ChecklistItem(title: "10. Stall entries from various flight attitudes and power combinations with recovery initiated at the first indication of a stall", notes: "", order: 9),
            ChecklistItem(title: "11. Emergency procedures and equipment malfunctions", notes: "", order: 10),
            ChecklistItem(title: "12. Ground reference maneuvers", notes: "", order: 11),
            ChecklistItem(title: "13. Approaches to a landing with simulated engine malfunctions", notes: "", order: 12),
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
            ChecklistItem(title: "1. Risk Managment", notes: "Using PAVE checklist, brief risk factors for this flight & how to mitigate them", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Managment", notes: "Explains resources available for assistance during this flight", order: 1),
            ChecklistItem(title: "3. Aircraft Perfomance and Weight and Balance", notes: "Briefs takeoff and landing runway required, climb rate, and dual and solo weight & balance.", order: 2),
            ChecklistItem(title: "4. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs Safety Items, Correct Accurate Steps with Checklists, Proper Taxi Speed and Controls", order: 3),
            ChecklistItem(title: "5. Radio Communications", notes: "Makes all appropriate calls, understands or requests clarification for instructions.", order: 4),
            ChecklistItem(title: "6. Collision Avoidance", notes: "Clears traffic before all operations on the ground and airborne.", order: 5),
            ChecklistItem(title: "7. Normal and Crosswind Takeoff, Departure and Climb", notes: "X-wind controls, tracks C/L, smooth liftoff, climbs +10/-5 kts, scans for traffic", order: 6),
            ChecklistItem(title: "8. Pilotage to Practice Area", notes: "Navigates the most suitable route to practice area using chart and landmarks.", order: 7),
            ChecklistItem(title: "9. Ground Reference Maneuvers", notes: "Checks for traffic & Obstructions, alt ±150', corrects for wind in straight & turning flight.", order: 8),
            ChecklistItem(title: "10. Airport Traffic Pattern", notes: "Appropriate radio calls complies with instructions and/or procedures. Altitude +/- 100'.", order: 9),
            ChecklistItem(title: "11. Normal Approach and Landing", notes: "Stabilized, +10/-5 kts, no drift, smooth touchdown, first 1/3, center 1/3", order: 10),
            ChecklistItem(title: "12. Go-Around", notes: "Immediate takeoff power, pitch for Vy, +10/-5, Flaps up, offset as appropriate. (Cram clean climb).", order: 11),
            ChecklistItem(title: "13. Logbook and Certificate Endorsements", notes: "Instructor makes appropriate entries and explains limitations.", order: 12),
            ChecklistItem(title: "14. Radio Communications (Solo)", notes: "Makes all appropriate calls, understands, or requests clarification for instructions.", order: 13),
            ChecklistItem(title: "15. Airport Ground and Taxi Operations (Solo)", notes: "Radio calls complies with instructions and/or procedures.", order: 14),
            ChecklistItem(title: "16. Normal Takeoff, Climb to Ramin in Pattern (Solo)", notes: "Radio calls, complies with instructions and/or procedures, Altitude ±100'.", order: 15),
            ChecklistItem(title: "17. Airport Traffic Pattern (Solo)", notes: "Appropriate radio calls complies with instructions and/or procedures Altitude ±100'", order: 16),
            ChecklistItem(title: "18. Normal Approach and Landing (Solo)", notes: "3 landings to full stop.", order: 17),
            ChecklistItem(title: "19. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls.", order: 18),
        ]
    )
    
    static let soloEndorsements = ChecklistTemplate(
        name: "Solo Endorsements",
        category: "PPL",
        phase: "Phase 1.5 Pre-Solo/Solo",
        templateIdentifier: "default_solo_endorsements",
        items: [
            ChecklistItem(title: "1. Pre-solo aeronautical knowledge 61.87(b)", notes: "I certify that (first, middle, last) has satisfactorily completed the pre-solo knowledge test of 61.87(b) for the [make and model] aircraft.", order: 0),
            ChecklistItem(title: "2. Pre-solo flight training 61.87(c)(1)(2) and 61.87(d)", notes: "I certify that (first, middle, last) has received and logged pre-solo flight training for, the maneuvers and procedures that are appropriate to make the [make and model] aircraft. I have determined that (he or she) has demonstrated satisfactory proficiency and safety on the maneuvers and procedures required by 61.87 in this or similar make and model of aircraft to be flown.", order: 1),
            ChecklistItem(title: "3. Solo flight 61.87(n)", notes: "I certify that (first, middle, last) has received the required training to qualify for solo flying. I have determined that he or she meets the applicable requirements of 61.87(n) and is proficient to make solo flights in the (make and model).", order: 2),
            ChecklistItem(title: "4. Solo flight at night 61.87(o)", notes: "I certify that (first, middle, last) has received the required training to qualify for solo flight at night. I have determined that he or she meets the applicable requirements of 61.87(o) and is proficient to make solo flights at night in the (make and model).", order: 3),
        ]
    )
    
    // MARK: - Phase 3 Templates
    
    static let p3L10LongXcSoloBriefing = ChecklistTemplate(
        name: "P3-L10: >150nm long Xc Solo Briefing",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l10_long_xc_solo_briefing",
        items: [
            ChecklistItem(title: "1. Logbook and Certificate Endorsements and Required Documents", notes: "Understands the required endorsements, student pilot privileges & specific instructor restrictions", order: 0),
            ChecklistItem(title: "2. Route Briefing", notes: "Briefs route, checkpoints, airspace, terrain, boundaries, cross-checks, altitudes, VORs, alternates", order: 1),
            ChecklistItem(title: "3. Weather briefing", notes: "Departure, en route, destinations & alternates (current & forecast), NOTAMS, what ifs for delays", order: 2),
            ChecklistItem(title: "4. Destinations/Alternates Facilities", notes: "Briefs ATC or CTAF procedures/frequencies, runways, taxiways, servicing, NavAids, NOTAMS", order: 3),
            ChecklistItem(title: "5. Navigation Plan", notes: "Briefs charts & pubs (current), methods of navigation, nav log, times, fuel reserves", order: 4),
            ChecklistItem(title: "6. Risk Management", notes: "Briefs the PAVE checklist and how to employ the in-flight CARE checklist", order: 5),
            ChecklistItem(title: "7. Single Pilot Resource Management", notes: "Briefs resources available for assistance in and outside the cockpit including en route weather", order: 6),
            ChecklistItem(title: "8. Lost Procedures", notes: "Briefs steps to follow if unsure of position", order: 7),
            ChecklistItem(title: "9. Weight and Balance and Performance", notes: "Briefs takeoff & landing W&B, takeoff & landing runway required, power settings & performance", order: 8),
            ChecklistItem(title: "10. Emergency Equipment and Survival Gear", notes: "Explains location and use of emergency equipment & its adequacy for this flight", order: 9),
            ChecklistItem(title: "11. Emergency Operations", notes: "Briefs what ifs of engine failure, engine fire, rough engine, electrical failure, NORDO", order: 10),
            ChecklistItem(title: "12. FSS and ATC Radar Service", notes: "Files, opens & closes flight plan with FSS for each leg, employs VFR Flight Following (if available) ", order: 11),
            ChecklistItem(title: "13. En Route Landings", notes: "Full stop landing each destination, refueling (as necessary), weather briefing", order: 12),
            ChecklistItem(title: "14. After Landing, Taxi, Parking, Post Flight Procedures and Refueling", notes: "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan", order: 13),
            ChecklistItem(title: "15. Postflight Navigation Log and Conditions Review", notes: "Briefs instructor on planned versus actual GS, ETE, fuel used, track, airport operations & weather ", order: 14),
        ]
    )
    
    static let p3L1PilotageAndDRCrossCountry = ChecklistTemplate(
        name: "P3-L1: Pilotage and DR Cross-Country >50nm",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l1_pilotage_and_dr_cross_country",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist for this flight and use of the CARE checklist during the flight", order: 0),
            ChecklistItem(title: "2. Emergency Equipment and Survival Gear", notes: "Explains location and use of emergency equipment, evaluates adequacy for this flight", order: 1),
            ChecklistItem(title: "3. Weight and Balance and Performance Calculations", notes: "Briefs load limits and takeoff/land runway requirements and climb and cruise performance", order: 2),
            ChecklistItem(title: "4. Flight Planning", notes: "Briefs planned route, checkpoints, alternates, weather, NOTAMS, airspace, terrain, navigation log", order: 3),
            ChecklistItem(title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass", order: 4),
            ChecklistItem(title: "6. Short Field Takeoff, Climb and Departure ", notes: "No-go, config., liftoff a/s per POH/AFM, V X  ± 5 kts until obstacle cleared, turns to heading", order: 5),
            ChecklistItem(title: "7. Open Prefiled Flight Plan", notes: "Determines correct FSS frequency, establishes contact, opens flight plan", order: 6),
            ChecklistItem(title: "8. En Route Cruise", notes: "Uses power & mixture settings per POH/AFM, TAS and Fuel Flow planning, hdg ±10°, alt ±100'", order: 7),
            ChecklistItem(title: "9. Pilotage", notes: "Identifies landmarks by relating surface features to chart symbols, verifies position within 3 nm", order: 8),
            ChecklistItem(title: "10. DR and Navigation Log", notes: "Records ATA, calculates ETEs , GS, fuel, wind & changes to ETA", order: 9),
            ChecklistItem(title: "11. Magnetic Compass", notes: "Simulated HI failure, use compass for headings, hdg ±15°", order: 10),
            ChecklistItem(title: "12. Cockpit Management", notes: "Equipment and materials organized, easily accessible and restrained", order: 11),
            ChecklistItem(title: "13. Task Management", notes: "Prioritizes and manages tasks by selecting the most appropriate for the moment ", order: 12),
            ChecklistItem(title: "14. Collision Avoidance", notes: "Divides attention among all tasks making sure that looking for traffic is not abandoned", order: 13),
            ChecklistItem(title: "15. Lost Procedures", notes: "nstructor introduces realistic distractions requiring use of lost procedures for reorientation", order: 14),
            ChecklistItem(title: "16. Diversion to an Alternate", notes: "Instructor scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel", order: 15),
            ChecklistItem(title: "17. Airport Traffic Pattern", notes: "Appropriate entry, radio calls, complies with instructions and/or procedures, alt ±100'", order: 16),
            ChecklistItem(title: "18. Short Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance", order: 17),
            ChecklistItem(title: "19. Soft Field Takeoff, Climb and Departure", notes: "No-go, controls/config set, earliest liftoff, ground effect until Vx /Vy , +10/-5, turns to heading", order: 18),
            ChecklistItem(title: "20. Soft Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction", order: 19),
            ChecklistItem(title: "21. After Landing, Taxi, Parking, Post Flight Procedures and Refueling", notes: "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan", order: 20),
        ]
    )
    
    static let p3L2NavigationAids = ChecklistTemplate(
        name: "P3-L2: Navigation Aids",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l2_navigation_aids",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist for this flight", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Utilizes all available resources during flight", order: 1),
            ChecklistItem(title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass", order: 2),
            ChecklistItem(title: "4. Electronic Flight Plan", notes: "Enters proscribed flight plan into installed or portable system, checks accuracy, saves", order: 3),
            ChecklistItem(title: "5. Soft Field Takeoff and Climb ", notes: "No-go, controls/config set, earliest liftoff, ground effect until V /V , +10/-5", order: 4),
            ChecklistItem(title: "6. VOR Orientation and Tracking VR", notes: "Tunes & ID,  finds radial, fix w/X-radials, intercepts/tracks course To/Fm VOR, station passage", order: 5),
            ChecklistItem(title: "7. Localizer Course Intercepting and Tracking", notes: "Tunes & ID LOC,  intercepts and tracks  front and back courses", order: 6),
            ChecklistItem(title: "8. GPS Navigation", notes: "Activates flight plan, intercepts/track courses, uses Nearest & Direct To for divert ", order: 7),
            ChecklistItem(title: "9. In-Flight Weather Resources", notes: "Accesses all available in-flight resources (FSS, EFAS, HIWAS, ATIS, Cockpit Display)", order: 8),
            ChecklistItem(title: "10. Fundamental Maneuvers IR (Straight & Level, Turns, Climbs, Descents)", notes: "Coordinated controls, altitude ±150', heading ±15°, airspeed ±10 kts, bank ±10°", order: 9),
            ChecklistItem(title: "11. Recovery from Unusual Attitudes IR", notes: "Promptly to stabilized, level flight, coordinated, correct control sequence", order: 10),
            ChecklistItem(title: "12. Electronic Navigation IR", notes: "Course to destination/alternate, intercepts/tracks course, safe altitude  ±200', 1/2 deflection", order: 11),
            ChecklistItem(title: "13. Federal Airways ", notes: "Identifies airway on chart, selects course in navigation system, intercepts and tracks course", order: 12),
            ChecklistItem(title: "14. Autopilot (if installed)", notes: "Conducts preflight test, explains ways to disengage, uses wing leveling, alt/heading hold & nav", order: 13),
            ChecklistItem(title: "15. Soft Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction", order: 14),
            ChecklistItem(title: "16. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "All operations correct & accurate w/checklists, taxi proper speed & controls", order: 15),
        ]
    )
    
    static let p3L3AllSystemsCrossCountry = ChecklistTemplate(
        name: "P3-L3: All Systems Cross-country",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l3_all_systems_cross_country",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist for this flight and use of the CARE checklist during the flight", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Utilizes all available resources during flight", order: 1),
            ChecklistItem(title: "3. Weight and Balance and Performance Calculations", notes: "Briefs load limits and takeoff/land runway requirements and climb and cruise performance", order: 2),
            ChecklistItem(title: "4. Flight Planning ", notes: "Briefs planned route, checkpoints, alternates, weather, NOTAMS, airspace, terrain, navigation log ", order: 3),
            ChecklistItem(title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass", order: 4),
            ChecklistItem(title: "6. FSS and ATC Radar Service", notes: "Opens flight plan with FSS and contacts appropriate ATC facility for VFR Flight Following", order: 5),
            ChecklistItem(title: "7. En Route Cruise", notes: "Uses power & mixture settings per POH/AFM, TAS and Fuel Flow planning, hdg ±10°, alt ±100'", order: 6),
            ChecklistItem(title: "8. Pilotage and DR", notes: "Maintains navigation log, position within 3 nm, ETA or revised ETA within 3 min.", order: 7),
            ChecklistItem(title: "9. Magnetic Compass", notes: "Simulated HI failure, use compass for headings, hdg ±15°", order: 8),
            ChecklistItem(title: "10. Electronic Navigation and Autopilot (if equipped)", notes: "At least 1 leg VOR, no more than 1 leg GPS, engage A/P (not more than 5 min.) in cruise", order: 9),
            ChecklistItem(title: "11. In-Flight Weather Resources", notes: "Checks available in-flight resources en route (FSS, EFAS, HIWAS, ATIS, Cockpit Display)", order: 10),
            ChecklistItem(title: "12. Cockpit Management", notes: "Equipment and materials organized, easily accessible and restrained", order: 11),
            ChecklistItem(title: "13. Task Management", notes: "Prioritizes and manages tasks by selecting the most appropriate for the moment ", order: 12),
            ChecklistItem(title: "14. Collision Avoidance", notes: "Divides attention among all tasks  making sure that looking for traffic is not abandoned ", order: 13),
            ChecklistItem(title: "15. Lost Procedures", notes: "Instructor introduces realistic distractions requiring use of lost procedures for reorientation", order: 14),
            ChecklistItem(title: "16. Diversion to an Alternate", notes: "Instructor scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel", order: 15),
            ChecklistItem(title: "17. Airport Traffic Pattern", notes: "Appropriate entry, radio calls, complies with instructions and/or procedures, alt ±100'", order: 16),
            ChecklistItem(title: "18. Soft Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction", order: 17),
            ChecklistItem(title: "19. Short Field Takeoff, Climb and Departure", notes: "No-go, config., liftoff a/s per POH/AFM, V X  ± 5 kts until obstacle cleared,  turns to heading", order: 18),
            ChecklistItem(title: "20. Short Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance", order: 19),
            ChecklistItem(title: "21. After Landing, Taxi, Parking, Post Flight Procedures and Refueling", notes: "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan", order: 20),
        ]
    )
    
    static let p3L4NightFlying = ChecklistTemplate(
        name: "P3-L4: Night Flying",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l4_night_flying",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist, focus on pilot rest, aircraft/pilot equipment & weather/moonlight", order: 0),
            ChecklistItem(title: "2. Physiological Aspects of Night Flying", notes: "Explains vision limitations at night, how to protect night vision, how to scan for traffic", order: 1),
            ChecklistItem(title: "3. Single Pilot Resource Management", notes: "Discusses differences in resources at night versus day, emergency equipment", order: 2),
            ChecklistItem(title: "4. CFIT", notes: "Discusses night hazards for Controlled Flight Into Terrain", order: 3),
            ChecklistItem(title: "5. Airport Layout and Lighting", notes: "Briefs notes, NOTAMs, operating hours, layout and lighting for airports to be used", order: 4),
            ChecklistItem(title: "6. Preflight Inspection at Night", notes: "Uses good light, correct/accurate steps w/checklists, checks all lights, fuel load, compass", order: 5),
            ChecklistItem(title: "7. Night Prestart and Starting", notes: "Flashlights readily available, sets cockpit & external lights, uses checklists ", order: 6),
            ChecklistItem(title: "8. Taxiing at Night", notes: "Confirms position w/airport diagram, appropriate speed & lighting, conscious of other aircraft ", order: 7),
            ChecklistItem(title: "9. Before Takeoff Checks at Night", notes: "Brakes locked for runup, correct/accurate steps w/checklists, confirms not moving on mag check", order: 8),
            ChecklistItem(title: "10. Night Take Off", notes: "Lights set, lineup on C/L, power & airspeed check before no go, smooth rotation to climb attitude", order: 9),
            ChecklistItem(title: "11. Climb After Night Takeoff", notes: "Climb attitude on AI, positive rate of climb, Vy  ±10 kts, wings level until minimum 400' AGL,  ", order: 10),
            ChecklistItem(title: "12. Night Local Area Navigation", notes: "Landmark recognition, electronic navigation aids ", order: 11),
            ChecklistItem(title: "13. Constant Airspeed Climb IR", notes: "Stabilized, coordinated, V Y  ±10 kts,  hdg ±15°, level off alt ±200' ", order: 12),
            ChecklistItem(title: "14. Constant Airspeed Descent IR", notes: "Stabilized, coordinated, a/s ±10 kts,  hdg ±15°, level off alt ±200' ", order: 13),
            ChecklistItem(title: "180° Level Turn IR", notes: "Stabilized, coordinated,  alt ±200', airspeed ±10 kts, standard rate turn bank ±10°, hdg ±15°", order: 14),
            ChecklistItem(title: "16. Recovery from Unusual Attitudes IR", notes: "Promptly to stabilized, level flight, coordinated, correct control sequence", order: 15),
            ChecklistItem(title: "17. Night Approach and Landing", notes: "Pattern alt ±100', hdg ±10°, stabilized approach, a/s +10/-5 kts, 6 full stop (2 landing light off)", order: 16),
            ChecklistItem(title: "18. Night Go-Around", notes: "Immediate takeoff power, pitch on AI for Vy , airspeed +10/-5 kts, flaps up per POH", order: 17),
            ChecklistItem(title: "19. Night Taxiing, Parking, Securing and Post Flight Procedures", notes: "Confirms position w/airport diagram, conscious of lights on other aircraft, uses checklists.", order: 18),
        ]
    )
    
    static let p3L5PreSoloXcProgressCheck = ChecklistTemplate(
        name: "P3-L5 Pre-Solo Xc Progress Check",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l5_pre_solo_xc_progress_check",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist including W&B, fuel, & performance, use of the CARE checklist in-flight", order: 0),
            ChecklistItem(title: "2. Emergency Equipment and Survival Gear", notes: "Explains location and use of emergency equipment, evaluates adequacy for this flight", order: 1),
            ChecklistItem(title: "3. Single Pilot Resource Management", notes: "Briefs planned use of available resources during flight", order: 2),
            ChecklistItem(title: "4. Flight Planning", notes: "Briefs planned route, checkpoints, alternates, weather, NOTAMS, airspace, terrain, navigation log", order: 3),
            ChecklistItem(title: "5. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Correct/accurate steps w/checklists, confirms required fuel load, checks compass", order: 4),
            ChecklistItem(title: "6. Short Field Takeoff, Climb and Departure", notes: "No-go, config., liftoff a/s per POH/AFM, V X  ± 5 kts until obstacle cleared, turns to heading", order: 5),
            ChecklistItem(title: "7. FSS and ATC Radar Service", notes: "Opens flight plan with FSS and contacts appropriate ATC facility for VFR Flight Following", order: 6),
            ChecklistItem(title: "8. En Route Cruise", notes: "Uses power & mixture settings per POH/AFM, TAS and Fuel Flow planning, hdg ±10°, alt ±100'", order: 7),
            ChecklistItem(title: "9. Navigation (DR, Pilotage, VOR and GPS)", notes: "Keeps nav log, uses DR, pilotage & electronic nav, track within 2 nm of course, ETA ±3 min", order: 8),
            ChecklistItem(title: "10. Cockpit Management", notes: "Equipment and materials organized, easily accessible and restrained", order: 9),
            ChecklistItem(title: "11. Task Management", notes: "Prioritizes and manages tasks by selecting the most appropriate for the moment ", order: 10),
            ChecklistItem(title: "12. Collision Avoidance", notes: "Divides attention among all tasks making sure that looking for traffic is not abandoned ", order: 11),
            ChecklistItem(title: "13. Heading Indicator Failure", notes: "Simulated HI failure, use compass for headings, hdg ±10°", order: 12),
            ChecklistItem(title: "14. Electrical Failure", notes: "Simulated emergency, reverts to DR & pilotage, decides go to destination, alternate, or return ", order: 13),
            ChecklistItem(title: "15. Lost Procedures", notes: "Instructor introduces realistic distractions requiring use of lost procedures for reorientation", order: 14),
            ChecklistItem(title: "16. Diversion to an Alternate", notes: "Scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel, advises ATC", order: 15),
            ChecklistItem(title: "17. Short Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touchdown within 400', stops in shortest distance", order: 16),
            ChecklistItem(title: "18. Soft Field Takeoff, Climb and Departure", notes: "No-go, controls/config set, earliest liftoff, ground effect until V /V , +10/-5, turns to heading", order: 17),
            ChecklistItem(title: "19. Soft Field Approach and Landing", notes: "Stabilized approach +10/-5 kts, touches down softly, wt. off nose, maintains crosswind correction", order: 18),
            ChecklistItem(title: "20. No Flap Landing", notes: "Slip as necessary, ±10 kts, no drift, smooth touchdown, first 500'", order: 19),
            ChecklistItem(title: "21. After Landing, Taxi, Parking, Post Flight Procedures and Refueling", notes: "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan", order: 20),
        ]
    )
    
    static let p3L5XcSoloPreCheck = ChecklistTemplate(
        name: "P3-L5.1  Xc solo pre-check (61.93(e)-(m)",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l5_1_xc_solo_pre_check",
        items: [
            ChecklistItem(title: "1. FAA Knowledge Test", notes: "Completed with passing score", order: 0),
            ChecklistItem(title: "2. Logbook Endorsements", notes: "", order: 1),
            ChecklistItem(title: "3. Required Documents", notes: "on person", order: 2),
            ChecklistItem(title: "4. Navigation", notes: "Use of aeronautical charts for VFR navigation using pilotage and DR with the aid of a magnetic compass", order: 3),
            ChecklistItem(title: "5. Aircraft performance charts", notes: "calculate Takeoff, and landing distance, and climb performance", order: 4),
            ChecklistItem(title: "6. Weather Briefing", notes: "Procurement and analysis of aeronautical weather reports and forecasts, including recognition of critical weather situations and estimating visibility while in flight", order: 5),
            ChecklistItem(title: "7. Emergency Procedures", notes: "Memory Items", order: 6),
            ChecklistItem(title: "8. Traffic Pattern procedures", notes: "Are departure, area arrival, entry into traffic pattern and appraoch", order: 7),
            ChecklistItem(title: "9. Collision and windshear avoidance, wake turbluance precautions", notes: "", order: 8),
            ChecklistItem(title: "10. CFIT", notes: "Recognition, avoidance, and operational restrictions of hazardous terrain features in the geographical area where the cross-country flight will be flown", order: 9),
            ChecklistItem(title: "11. Use of intruments and equipment", notes: "Procedures for operating the instruments and equipment installed in the aircraft to be flown, including recognition and use of the proper operational procedures and indications", order: 10),
            ChecklistItem(title: "12. Radio Comms", notes: "se of radios for VFR navigation and two-way communication, except that a student pilot seeking a sport pilot certificate must only receive and log flight training on the use of radios installed in the aircraft to be flown", order: 11),
            ChecklistItem(title: "13. Takeoff & Landings", notes: "akeoff, approach, and landing procedures, including short-field, soft-field, and crosswind takeoffs, approaches, and landings", order: 12),
            ChecklistItem(title: "14. Climbs", notes: "Climbs at best angle Vx, and best rate Vy", order: 13),
            ChecklistItem(title: "15. Flight by reference to instruments", notes: "Control and maneuvering solely by reference to flight instruments, including straight and level flight, turns, descents, climbs, use of radio aids, and ATC directives. For student pilots seeking a sport pilot certificate, the provisions of this paragraph only apply when receiving training for cross-country flight in an airplane that has a VH greater than 87 knots CAS.", order: 14),
        ]
    )
    
    static let p3L5XcEndorsements = ChecklistTemplate(
        name: "P3-L5.2 XC endorsements (61.93)",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l5_2_xc_endorsements",
        items: [
            ChecklistItem(title: "1. A.9 Solo cross-country flight 61.93(c)(1) and (2)", notes: "I certify that [first name, MI, last name] has received the required solo cross-country training. I find they have met the applicable requirements of 61.93 and are proficient to make solo cross-country flights in a [make and model] aircraft.", order: 0),
            ChecklistItem(title: "2. A.10 Solo cross-country flight 61.93(c)(3)", notes: "I have reviewed the cross-country planning of [first name, MI, last name]. I find the planning and preparation to be correct to make the solo flight from [Origination Airport] to [Origination Airport] via [route of flight] with landings at [names of the airports] in a [Make and model] aircraft on [date]. [List any applicable conditions or limitations.]", order: 1),
        ]
    )
    
    static let p3L6XcSolo = ChecklistTemplate(
        name: "P3-L6: XC Solo",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l6_xc_solo",
        items: [
            ChecklistItem(title: "1. Route Briefing", notes: "Briefs route, checkpoints, airspace, terrain, boundaries, cross-checks, altitudes, VORs, alternates", order: 0),
            ChecklistItem(title: "2. Weather briefing", notes: "Departure, en route, destination & alternates (current & forecast), NOTAMS, what ifs for delays", order: 1),
            ChecklistItem(title: "3. Destination/Alternates Facilities", notes: "Briefs ATC or CTAF procedures/frequencies, runways, taxiways, servicing, NavAids, NOTAMS ", order: 2),
            ChecklistItem(title: "4. Navigation Plan", notes: "Briefs charts & pubs (current), methods of navigation, nav log, times, fuel reserves", order: 3),
            ChecklistItem(title: "5. Risk Management", notes: "Briefs the PAVE checklist and how to employ the CARE checklist en route", order: 4),
            ChecklistItem(title: "6. Single Pilot Resource Management", notes: "Briefs resources available for assistance in and outside the cockpit including en route weather", order: 5),
            ChecklistItem(title: "7. Lost Procedures", notes: "Briefs steps to follow if unsure of position", order: 6),
            ChecklistItem(title: "8. Weight and Balance and Performance", notes: "Briefs takeoff & landing W&B, takeoff & landing runway required, power settings & performance", order: 7),
            ChecklistItem(title: "9. Emergency Equipment and Survival Gear", notes: "Explains location and use of emergency equipment & its adequacy for this flight", order: 8),
            ChecklistItem(title: "10. Emergency Operations", notes: "Briefs what ifs of engine failure, engine fire, rough engine, electrical failure, NORDO", order: 9),
            ChecklistItem(title: "11. FSS and ATC Radar Service", notes: "Files, opens & closes  flight plan with FSS , employs VFR Flight Following (if available) ", order: 10),
            ChecklistItem(title: "12. Flight to Airport More Than 50 NM Straight Line Distance ", notes: "Full stop normal landing, refueling (as necessary), weather briefing, return to home airport", order: 11),
            ChecklistItem(title: "13. After Landing, Taxi, Parking, Post Flight Procedures and Refueling", notes: "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan", order: 12),
            ChecklistItem(title: "14. Postflight Navigation Log and Conditions Review", notes: "Briefs instructor on planned versus actual GS, ETE, fuel used, track, airport operations & weather ", order: 13),
        ]
    )
    
    static let p3L7Xc100nmNightDual = ChecklistTemplate(
        name: "P3-L7: XC >100nm Night (Dual)",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l7_xc_100nm_night_dual",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist including W&B, fuel, & performance, use of the CARE checklist in-flight", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Briefs resources available for assistance in and outside the cockpit including en route weather", order: 1),
            ChecklistItem(title: "3. Physiological Aspects of Night Flying", notes: "Explains vision limitations at night, how to protect night vision, how to scan for traffic", order: 2),
            ChecklistItem(title: "4. Emergency Equipment and Survival Gear", notes: "Explains location and use of emergency equipment & its adequacy for this flight", order: 3),
            ChecklistItem(title: "5. Route Briefing", notes: "Briefs route, night visible checkpoints, airspace, terrain, boundaries, altitudes, VORs, alternates", order: 4),
            ChecklistItem(title: "6. Weather briefing", notes: "Departure, en route, destination & alternates (current & forecast), NOTAMS, what ifs for delays", order: 5),
            ChecklistItem(title: "7. Destination/Alternates Facilities", notes: "Briefs ATC or CTAF proced/freq, runways, taxiways, lighting, servicing, NavAids, NOTAMS", order: 6),
            ChecklistItem(title: "8. CFIT", notes: "Discusses night hazards on this route for Controlled Flight Into Terrain", order: 7),
            ChecklistItem(title: "9. Night Preflight Inspection and Startup", notes: "Correct/accurate steps w/checklists, uses good light, confirms required fuel load, preps cockpit", order: 8),
            ChecklistItem(title: "10. Night Taxiing and Before Takeoff Checks", notes: "Checks instruments and compass, controlled taxi using airport diagram, correct steps w/checklists", order: 9),
            ChecklistItem(title: "11. Night Take Off and Climb", notes: "Lights, on C/L, pwr & a/s check, climb attitude, positive climb, V Y  ±10 kts, wings level <400' AGL", order: 10),
            ChecklistItem(title: "12. FSS and ATC Radar Service", notes: "Files, opens & closes flight plan with FSS, employs VFR Flight Following (if available) ", order: 11),
            ChecklistItem(title: "13. Navigation (DR, Pilotage, VOR and GPS)", notes: "Keeps nav log, uses DR, pilotage & electronic nav, track within 3 nm of course, ETA ±3 min", order: 12),
            ChecklistItem(title: "14. Collision Avoidance", notes: "Divides attention among all tasks making sure that looking for traffic is not abandoned ", order: 13),
            ChecklistItem(title: "15. Controlling by Flight Instruments (180° Turn and Electronic Navigation)", notes: "Alt ±200', airspeed ±10 kts, standard rate turn bank ±10°, hdg ±15°, CDI 1/2 deflection", order: 14),
            ChecklistItem(title: "16. Lost Procedures", notes: "Instructor introduces realistic distractions requiring use of lost procedures for reorientation", order: 15),
            ChecklistItem(title: "17. Diversion to an Alternate", notes: "Scenario suggests diversion, picks suitable alternate, quick plans hdg, time, & fuel, advises ATC", order: 16),
            ChecklistItem(title: "18. Emergency Operations", notes: "Simulated rough engine, electrical failure, heading indicator  failure, radio failure", order: 17),
            ChecklistItem(title: "19. Night Approach and Landing", notes: "Pattern alt ±100', hdg ±10°, stabilized approach, a/s +10/-5 kts, 6 full stop (2 landing light off)", order: 18),
            ChecklistItem(title: "20. Night Go-Around", notes: "Immediate takeoff power, pitch on AI for V Y , airspeed +10/-5 kts, flaps up per POH", order: 19),
            ChecklistItem(title: "21. Night Taxiing, Parking, Securing and Post Flight Procedures", notes: "Confirms position w/airport diagram, conscious of lights on other aircraft, uses checklists.", order: 20),
        ]
    )
    
    static let p3L8SecondSoloXcBriefing = ChecklistTemplate(
        name: "P3-L8: 2nd Solo Xc Briefing",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l8_second_solo_xc_briefing",
        items: [
            ChecklistItem(title: "1. Logbook and Certificate endorsements and Required documents", notes: "Understands the required endorsements, student pilot privileges & specific instructor restrictions ", order: 0),
            ChecklistItem(title: "2. Route Briefing", notes: "Briefs route, checkpoints, airspace, terrain, boundaries, cross-checks, altitudes, VORs, alternates", order: 1),
            ChecklistItem(title: "3. Weather briefing", notes: "Departure, en route, destination & alternates (current & forecast), NOTAMS, what ifs for delays", order: 2),
            ChecklistItem(title: "4. Destination/Alternates Facilities", notes: "Briefs ATC or CTAF procedures/frequencies, runways, taxiways, servicing, NavAids, NOTAMS", order: 3),
            ChecklistItem(title: "5. Navigation Plan", notes: "Briefs charts & pubs (current), methods of navigation, nav log, times, fuel reserves", order: 4),
            ChecklistItem(title: "6. Risk Management", notes: "Briefs the PAVE checklist and how to employ the CARE checklist en route", order: 5),
            ChecklistItem(title: "7. Single Pilot Resource Management", notes: "Briefs resources available for assistance in and outside the cockpit including en route weather", order: 6),
            ChecklistItem(title: "8. Lost Procedures", notes: "Briefs steps to follow if unsure of position", order: 7),
            ChecklistItem(title: "9. Weight and Balance and Performance", notes: "Briefs takeoff & landing W&B, takeoff & landing runway required, power settings & performance", order: 8),
            ChecklistItem(title: "10. Emergency Equipment and Survival Gear", notes: "Explains location and use of emergency equipment & its adequacy for this flight", order: 9),
            ChecklistItem(title: "11. Emergency Operations", notes: "Briefs what ifs of engine failure, engine fire, rough engine, electrical failure, NORDO", order: 10),
            ChecklistItem(title: "12. FSS and ATC Radar Service", notes: "Files, opens & closes  flight plan with FSS for each leg, employs VFR Flight Following (if available)", order: 11),
            ChecklistItem(title: "13. Flight to Airport More Than 50 NM Straight Line Distance ", notes: "Full stop normal landing, refueling (as necessary), weather briefing, return to home airport", order: 12),
            ChecklistItem(title: "14. After Landing, Taxi, Parking, Post Flight Procedures and Refueling", notes: "Uses checklists, charts for unfamiliar taxi, ensures correct refueling, closes flight plan", order: 13),
            ChecklistItem(title: "15. Postflight Navigation Log and Conditions Review", notes: "Briefs instructor on planned versus actual GS, ETE, fuel used, track, airport operations & weather ", order: 14),
        ]
    )
    
    static let p3L9EmergenciesAndInstrumentReview = ChecklistTemplate(
        name: "P3-L9: Emergencies and Instrument Review",
        category: "PPL",
        phase: "Phase 3",
        templateIdentifier: "default_p3_l9_emergencies_and_instrument_review",
        items: [
            ChecklistItem(title: "1. Risk Management", notes: "Briefs PAVE checklist and CARE checklist focusing on preparedness for in-flight equipment failures", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Briefs planned use of available resources during emergencies", order: 1),
            ChecklistItem(title: "3. Preflight Inspection, Startup, Taxiing, and Before Takeoff Checks", notes: "Briefs safety items, correct/accurate steps w/checklists, proper taxi speed & controls", order: 2),
            ChecklistItem(title: "4. Short Field Takeoff, Climb and Departure", notes: "No-go, config., liftoff a/s per POH/AFM, Vx ± 5 kts until obstacle cleared", order: 3),
            ChecklistItem(title: "5. Soft Field Takeoff and Climb", notes: "No-go, controls/config set, earliest liftoff, ground effect until Vx /Vy , ± 5 kts", order: 4),
            ChecklistItem(title: "6. Rejected Takeoff", notes: "Set go/no-go point, idle, maximum braking, maintain directional control", order: 5),
            ChecklistItem(title: "7. Engine Failure in Climb After Takeoff", notes: "Promptly pitches for best glide, ±10 kts, best field, memory items", order: 6),
            ChecklistItem(title: "8. Engine Fire in Flight, Emergency Descent and Landing (Simulated)", notes: "Fire memory items, emerg descent config, best glide ±10 kts, best field, emerg approach checklist", order: 7),
            ChecklistItem(title: "9. Constant Airspeed Climb IR", notes: "Stabilized, coordinated, Vy ±5 kts,  hdg ±10°, level off alt ±100' ", order: 8),
            ChecklistItem(title: "10. Constant Airspeed Descent IR", notes: "Stabilized, coordinated, a/s ±5 kts,  hdg ±10°, level off alt ±100' ", order: 9),
            ChecklistItem(title: "180° Level Turn IR", notes: "Stabilized, coordinated,  alt ±150', airspeed ±10 kts, standard rate turn bank ±5°, hdg ±10°", order: 10),
            ChecklistItem(title: "12. Electronic Navigation IR", notes: "Tunes, selects course, alt ±150', airspeed ±10 kts, hdg ±10°, CDI 1/2 deflection", order: 11),
            ChecklistItem(title: "13. Recovery from Unusual Attitudes IR", notes: "Promptly to stabilized, level flight, coordinated, correct control sequence", order: 12),
            ChecklistItem(title: "14. Autopilot (if installed) IR", notes: "Preflight test, in simulated IMC engages wing leveling, alt & heading/nav hold to return to VMC", order: 13),
            ChecklistItem(title: "15. Electrical Failure", notes: "Simulated emergency, reverts to DR & pilotage, decides go to destination, alternate, or return ", order: 14),
            ChecklistItem(title: "16. Emergency Communications and ATC Resources", notes: "Explain emergency communication procedures for requesting ATC assistance", order: 15),
            ChecklistItem(title: "17. Short Field Approach and Landing", notes: "Stabilized approach ±5 kts, touchdown within 400', stops in shortest distance", order: 16),
            ChecklistItem(title: "18. Soft Field Approach and Landing", notes: "Stabilized approach ±5 kts, touches down softly, wt. off nose, maintains crosswind correction", order: 17),
            ChecklistItem(title: "19. No Flap Landing", notes: "Slip as necessary, ±10 kts, no drift, smooth touchdown, first 500'", order: 18),
            ChecklistItem(title: "20. After Landing, Taxi, Parking, and Post Flight Procedures", notes: "Uses checklists, complete/accurate", order: 19),
        ]
    )
    
    // MARK: - Phase 4 Templates
    
    static let p4L1PreCheckrideInstructorReview = ChecklistTemplate(
        name: "P4-L1.1: Pre-Checkride Instructor Review",
        category: "PPL",
        phase: "Phase 4",
        templateIdentifier: "default_p4_l1_1_pre_checkride_instructor_review",
        items: [
            ChecklistItem(title: "1. Airman Certification Standards", notes: "introduction (Special Emphasis Areas), Applicant's Checklist &  Areas of Operation and Tasks ", order: 0),
            ChecklistItem(title: "2. Single-Pilot Resource Management", notes: "Private Pilot Airman Certification Standards", order: 1),
            ChecklistItem(title: "3. Risk Management", notes: "Private Pilot Airman Certification Standards", order: 2),
            ChecklistItem(title: "4. Aeronautical Decision-Making", notes: "Private Pilot Airman Certification Standards", order: 3),
            ChecklistItem(title: "5. Task Management", notes: "Private Pilot Airman Certification Standards", order: 4),
            ChecklistItem(title: "6. Situational Awareness", notes: "Private Pilot Airman Certification Standards", order: 5),
            ChecklistItem(title: "7. Controlled Flight into Terrain (CFIT)", notes: "Private Pilot Airman Certification Standards", order: 6),
            ChecklistItem(title: "8. Automation Management", notes: "Private Pilot Airman Certification Standards", order: 7),
            ChecklistItem(title: "9. Positive Exchange of Flight Controls", notes: "Explains and uses the positive three-step exchange of controls", order: 8),
            ChecklistItem(title: "10. Wake Turbulence Avoidance", notes: "Explains procedures for taking off & landing after departing & arriving large aircraft", order: 9),
            ChecklistItem(title: "11. Land and Hold Short Operations (LAHSO)", notes: "Explains where to find if an airport uses LAHSO, procedures, restrictions & options", order: 10),
            ChecklistItem(title: "12. Runway Incursion Avoidance", notes: "Private Pilot Airman Certification Standards", order: 11),
            ChecklistItem(title: "13. Certificates and Documents", notes: "Private Pilot Airman Certification Standards", order: 12),
            ChecklistItem(title: "14. Airworthiness Requirements", notes: "Private Pilot Airman Certification Standards", order: 13),
            ChecklistItem(title: "15. Weather Information", notes: "Private Pilot Airman Certification Standards", order: 14),
            ChecklistItem(title: "16. Cross-Country Flight Planning", notes: "Private Pilot Airman Certification Standards", order: 15),
            ChecklistItem(title: "17. National Airspace System", notes: "Private Pilot Airman Certification Standards", order: 16),
            ChecklistItem(title: "18. Performance and Limitations", notes: "Private Pilot Airman Certification Standards", order: 17),
            ChecklistItem(title: "19. Operation of Systems", notes: "Private Pilot Airman Certification Standards", order: 18),
            ChecklistItem(title: "20. Aeromedical Factors", notes: "Private Pilot Airman Certification Standards", order: 19),
            ChecklistItem(title: "21. Preflight Inspection", notes: "Private Pilot Airman Certification Standards", order: 20),
            ChecklistItem(title: "22. Cockpit Management", notes: "Private Pilot Airman Certification Standards", order: 21),
            ChecklistItem(title: "23. Engine starting", notes: "Private Pilot Airman Certification Standards", order: 22),
            ChecklistItem(title: "24. Taxiing", notes: "Private Pilot Airman Certification Standards", order: 23),
            ChecklistItem(title: "25. Before Takeoff Check", notes: "Private Pilot Airman Certification Standards", order: 24),
            ChecklistItem(title: "26. Radio Communications and ATC Light Signals", notes: "Private Pilot Airman Certification Standards", order: 25),
            ChecklistItem(title: "27. Traffic Patterns", notes: "Private Pilot Airman Certification Standards", order: 26),
            ChecklistItem(title: "28. Airport, Runway and Taxiway Signs, Markings and Lighting", notes: "Private Pilot Airman Certification Standards", order: 27),
            ChecklistItem(title: "29. Normal and Crosswind Takeoff and Climb", notes: "Private Pilot Airman Certification Standards", order: 28),
            ChecklistItem(title: "30. Normal and Crosswind Approach and Landing", notes: "Private Pilot Airman Certification Standards", order: 29),
            ChecklistItem(title: "31. Soft-Field Takeoff and Climb", notes: "Private Pilot Airman Certification Standards", order: 30),
            ChecklistItem(title: "32. Soft-Field Approach and Landing", notes: "Private Pilot Airman Certification Standards", order: 31),
            ChecklistItem(title: "33. Short-Field Takeoff and Maximum Performance Climb", notes: "Private Pilot Airman Certification Standards", order: 32),
            ChecklistItem(title: "34. Short-Field Approach and Landing", notes: "Private Pilot Airman Certification Standards", order: 33),
            ChecklistItem(title: "35. Forward Slip to a Landing", notes: "Private Pilot Airman Certification Standards", order: 34),
            ChecklistItem(title: "36. Go-Around/Rejected Landing", notes: "Private Pilot Airman Certification Standards", order: 35),
            ChecklistItem(title: "37. Steep Turns", notes: "Private Pilot Airman Certification Standards", order: 36),
            ChecklistItem(title: "38. Rectangular Course", notes: "Private Pilot Airman Certification Standards", order: 37),
            ChecklistItem(title: "39. S-Turns", notes: "Private Pilot Airman Certification Standards", order: 38),
            ChecklistItem(title: "40. Turns Around a Point", notes: "Private Pilot Airman Certification Standards", order: 39),
            ChecklistItem(title: "41. Pilotage and Dead Reckoning", notes: "Private Pilot Airman Certification Standards", order: 40),
            ChecklistItem(title: "42. Navigation Systems and Radar Services", notes: "Private Pilot Airman Certification Standards", order: 41),
            ChecklistItem(title: "43. Diversion", notes: "Private Pilot Airman Certification Standards", order: 42),
            ChecklistItem(title: "44. Lost Procedures", notes: "Private Pilot Airman Certification Standards", order: 43),
            ChecklistItem(title: "45. Maneuvering During Slow Flight", notes: "Private Pilot Airman Certification Standards", order: 44),
            ChecklistItem(title: "46. Power-Off Stalls", notes: "Private Pilot Airman Certification Standards", order: 45),
            ChecklistItem(title: "47. Power-On Stalls", notes: "Private Pilot Airman Certification Standards", order: 46),
            ChecklistItem(title: "48. Spin Awareness", notes: "Private Pilot Airman Certification Standards", order: 47),
            ChecklistItem(title: "49. Straight-and-Level Flight IR", notes: "Private Pilot Airman Certification Standards", order: 48),
            ChecklistItem(title: "50. Constant Airspeed Climbs IR", notes: "Private Pilot Airman Certification Standards", order: 49),
            ChecklistItem(title: "51. Constant Airspeed Descents IR", notes: "Private Pilot Airman Certification Standards", order: 50),
            ChecklistItem(title: "52. Turns to Headings IR", notes: "Private Pilot Airman Certification Standards", order: 51),
            ChecklistItem(title: "53. Recovery from Unusual Flight Attitudes IR", notes: "Private Pilot Airman Certification Standards", order: 52),
            ChecklistItem(title: "54. Radio Communications, Navigation Systems/Facilities and Radar Services", notes: "Private Pilot Airman Certification Standards", order: 53),
            ChecklistItem(title: "55. Emergency Descent", notes: "Private Pilot Airman Certification Standards", order: 54),
            ChecklistItem(title: "56. Emergency Approach and Landing (Simulated)", notes: "Private Pilot Airman Certification Standards", order: 55),
            ChecklistItem(title: "57. Systems and Equipment Malfunctions", notes: "Private Pilot Airman Certification Standards", order: 56),
            ChecklistItem(title: "58. Emergency Equipment and Survival Gear", notes: "Private Pilot Airman Certification Standards", order: 57),
            ChecklistItem(title: "59. Night Preparation", notes: "Private Pilot Airman Certification Standards", order: 58),
            ChecklistItem(title: "60. After Landing, Parking and Securing", notes: "Private Pilot Airman Certification Standards", order: 59),
        ]
    )
    
    static let p4L1CheckrideChecklist = ChecklistTemplate(
        name: "P4-L1.2: Checkride Checklist",
        category: "PPL",
        phase: "Phase 4",
        templateIdentifier: "default_p4_l1_2_checkride_checklist",
        items: [
            ChecklistItem(title: "1. Valid Student Pilot Certificate, Sport Pilot Certificate, or Recreational Pilot Certificate.", notes: "", order: 0),
            ChecklistItem(title: "2. Completion of flight training program.", notes: "Flight training program to meet the requirements of part 61 sub part E. The rule provides the specific minimum aeronautical knowledge, flight proficiency and aeronautic experience requirements that the training program must meet.", order: 1),
            ChecklistItem(title: "3. Night Experience Requirements.", notes: "Applicants must meet night experience requirements regardless of medical qualification considerations. Section 61.110 lists the only exception.", order: 2),
            ChecklistItem(title: "4. 3 hours of flight solely by reference to instruments.", notes: "Private pilot airplane and powered lift applicants must also accomplish three hours of flight training on the control and maneuvering of the aircraft solely by reference to instruments in the category and class of aircraft. The three hours of flight training do not have to be conducted by a CF-II.", order: 3),
        ]
    )
    
    static let p4L1PracticalTestEndorsements = ChecklistTemplate(
        name: "P4-L1.3 Practical Test Endorsements",
        category: "PPL",
        phase: "Phase 4",
        templateIdentifier: "default_p4_l1_3_practical_test_endorsements",
        items: [
            ChecklistItem(title: "1. A.33 Flight proficiency/practical test. 61.103(f), 61.107(b), 61.109.", notes: "I certified that [first name, MI, last name] has received the required training in accordance with 61.107 and 61.109. I have determined they are prepared for the [name of] practical test.", order: 0),
            ChecklistItem(title: "2. A.1 Prerequisites for practical test. 61.39(a)(6)(i) and (ii).", notes: "I certified that [first name, MI, last name] has received and logged training time within 2 calendar months preceding the month of application in preparation for the practical test and they are prepared for the required practical test for the issuance of [applicable certificate].", order: 1),
            ChecklistItem(title: "3. A.2 Review of deficiencies identified on airman knowledge test. 61.39(a)(6)(iii) as required.", notes: "I certified that [first name, MI, last name] has demonstrated satisfactory knowledge of the subject areas in which they were deficient on the [applicable] Airmen knowledge test.", order: 2),
        ]
    )
    
    static let p4L3WrittenTestEndorsements = ChecklistTemplate(
        name: "P4-L3: Written Test Endorsements",
        category: "PPL",
        phase: "Phase 4",
        templateIdentifier: "default_p4_l3_written_test_endorsements",
        items: [
            ChecklistItem(title: "1. A.32 Aeronautical knowledge test 61.35(a)(1), 61.103(d), and 61.105", notes: "I certify that [first name, MI, last name] has received the required training in accordance with 61.105. I have determined they are prepared for the [name of] knowledge test.", order: 0),
        ]
    )
    
    // MARK: - All Templates Array
    
    // Lazy loading for memory efficiency
    static var allTemplates: [ChecklistTemplate] {
        return [
        // First Steps
        studentOnboardTrainingOverview,
        
        // Phase 1 - Training Lessons (in order)
        p1L1StraightAndLevelFlight,
        p1L2BasicAircraftOperations,
        p1L3InstrumentsAndInvestigatingSlowFlight,
        p1L4SlowFlightAndStalls,
        p1L5GroundReferenceManeuvers,
        p1L6EmergencyManeuvers,
        p1L7NormalTakeoffAndLandings,
        p1L8CrosswindTakeoffAndLanding,
        p1L9ManeuverReview,
        
        // Pre-Solo/Solo
        preSoloQuizAndDocuments,
        preSoloTrainingCheckoff,
        firstSolo,
        soloEndorsements,
        
        // Phase 2 - Advanced Training
        p2L1ReviewAndSecondSolo,
        p2L2ShortFieldTakeoffAndLanding,
        p2L3BuildingSkillWithManeuversAndLandings,
        p2L4SoftFieldTakeoffAndLandings,
        p2L5Phase2Overview,
        
        // Phase 3 - Cross-Country and Advanced Training
        p3L1PilotageAndDRCrossCountry,
        p3L2NavigationAids,
        p3L3AllSystemsCrossCountry,
        p3L4NightFlying,
        p3L5PreSoloXcProgressCheck,
        p3L5XcSoloPreCheck,
        p3L5XcEndorsements,
        p3L6XcSolo,
        p3L7Xc100nmNightDual,
        p3L8SecondSoloXcBriefing,
        p3L9EmergenciesAndInstrumentReview,
        p3L10LongXcSoloBriefing,
        
        // Phase 4 - Checkride Preparation
        p4L1PreCheckrideInstructorReview,
        p4L1CheckrideChecklist,
        p4L1PracticalTestEndorsements,
        p4L3WrittenTestEndorsements,
        
        // Review Templates
        biAnnualFlightReview,
        instrumentProficiencyCheck,
        
        // Instrument Rating - Phase 1
        i1L1PreflightAndBasicInstrumentControl,
        i1L2ExpandingInstrumentSkills,
        i1L3UsingTheMagneticCompass,
        i1L4IFRFlightPlansAndClearances,
        i1L5PrimaryFlightInstrumentDisplayFailure,
        i1L6ReviewOfInstrumentControlAndProgressCheck,
        
        // Instrument Rating - Phase 2
        i2L1GPSAndVORForIFR,
        i2L2NDBADFNavigationAndDepartureProcedures,
        i2L3BuildingSkillWithGPSVORAndNDBNDBNavigation,
        i2L4DMEARX,
        i2L5HoldingProcedures,
        i2L6ProgressCheck,
        
        // Instrument Rating - Phase 3
        i3L1ILSApproachesAndProcedureTurns,
        i3L2RNAVApproachesWithVerticalGuidance,
        i3L4VORAndNDBApproaches,
        i3L5CirclingApproaches,
        i3L6PartialPanelAndUsingTheAutopilotForApproaches,
        i3L7ProgressCheck,
        
        // Instrument Rating - Phase 4
        i4L1ShortIFRCrossCountry,
        i4L2RefiningApproaches,
        i4L3LongIFRCrossCountryProgressCheck,
        
        // Instrument Rating - Phase 5
        i5L1AirmanCertificationStandards,
        i5L2HoningTheEdge,
        i5L3PreCheckrideProgressCheck,
        i5L4Endorsements,
        
          // Commercial Rating - Stage 1: Learning Professional Cross-Country and Night Procedures
          c1L1DualCrossCountry,
          c1L2DualLocalNight,
          c1L3PICCrossCountry,
          c1L4DualCrossCountryNight,
          c1L5SoloLocalNight,
          c1L6PICCrossCountry,
          c1L7SoloLocalNight,
          c1L8SoloCrossCountryNight,
          c1L9PICCrossCountry,
          c1L10ProgressCheck,
          
          // Commercial Rating - Stage 2: Flying Complex Airplanes and Commercial Maneuvers
          c2L1DualLocalComplex,
          c2L2DualLocalComplex,
          c2L3SteepTurns,
          c2L4Chandelles,
          c2L5LazyEights,
          c2L6EightsOnPylons,
          
          // Commercial Rating - Stage 3: Preparing for Commercial Pilot Check Ride
          c3L1DualLocal,
          c3L2FinalProgressCheck,
          c3L3Endorsements,
        ]
    }
    
    // MARK: - Review Templates
    
    static let biAnnualFlightReview = ChecklistTemplate(
        name: "BiAnnual Flight Review",
        category: "Reviews",
        phase: "Flight Reviews",
        templateIdentifier: "default_bi_annual_flight_review",
        items: [
            // MARK: - Pre-Review Considerations
            ChecklistItem(title: "1.1 Pre-Review - Pilot Preparation", notes: "Pilot has reviewed current regulations, AIM, and appropriate handbooks", order: 0),
            ChecklistItem(title: "1.2 Pre-Review - Recent Experience", notes: "Verify pilot meets recent flight experience requirements per 14 CFR 61.57", order: 1),
            ChecklistItem(title: "1.3 Pre-Review - Medical Certificate", notes: "Verify current medical certificate and any limitations", order: 2),
            ChecklistItem(title: "1.4 Pre-Review - Aircraft Selection", notes: "Select appropriate aircraft for pilot's certificate level and intended operations", order: 3),
            ChecklistItem(title: "1.5 Pre-Review - Weather Planning", notes: "Plan for appropriate weather conditions and have backup plans", order: 4),
            ChecklistItem(title: "1.6 Pre-Review - Personal Currency Program", notes: "Review pilot's personal currency program and proficiency goals", order: 5),
            
            // MARK: - Ground Review - Pilot Knowledge
            ChecklistItem(title: "2.1. Ground - Pilot Responsibilities", notes: "Review PIC authority and responsibilities per 14 CFR 91.3", order: 6),
            ChecklistItem(title: "2.2. Ground - Preflight Actions", notes: "Review preflight planning requirements per 14 CFR 91.103", order: 7),
            ChecklistItem(title: "2.3. Ground - Medical Facts", notes: "Review medical factors affecting flight safety (AIM Chapter 8)", order: 8),
            ChecklistItem(title: "2.4. Ground - Recent Experience", notes: "Verify compliance with recent flight experience requirements", order: 9),
            ChecklistItem(title: "2.5. Ground - Currency Requirements", notes: "Review currency requirements for privileges exercised", order: 10),
            
            // MARK: - Ground Review - Aircraft Systems
            ChecklistItem(title: "3.1. Ground - Fuel Requirements", notes: "Review fuel requirements and planning per 14 CFR 91.167", order: 11),
            ChecklistItem(title: "3.2. Ground - Equipment Requirements", notes: "Review required instruments and equipment per 14 CFR 91.205", order: 12),
            ChecklistItem(title: "3.3. Ground - Navigation Equipment", notes: "Review VOR equipment check requirements per 14 CFR 91.171", order: 13),
            ChecklistItem(title: "3.4. Ground - Communication Equipment", notes: "Review two-way radio communication requirements per 14 CFR 91.183", order: 14),
            ChecklistItem(title: "3.5. Ground - Emergency Equipment", notes: "Review ELT requirements per 14 CFR 91.207 and emergency procedures", order: 15),
            ChecklistItem(title: "3.6. Ground - Aircraft Lights", notes: "Review aircraft lighting requirements per 14 CFR 91.209", order: 16),
            ChecklistItem(title: "3.7. Ground - Inoperative Equipment", notes: "Review procedures for inoperative instruments per 14 CFR 91.213", order: 17),
            ChecklistItem(title: "3.8. Ground - Altimeter Tests", notes: "Review altimeter and pitot-static system test requirements per 14 CFR 91.411", order: 18),
            ChecklistItem(title: "3.9. Ground - Transponder Tests", notes: "Review ATC transponder test requirements per 14 CFR 91.413", order: 19),
            ChecklistItem(title: "3.10. Ground - Malfunction Reports", notes: "Review malfunction reporting requirements per 14 CFR 91.187", order: 20),
            
            // MARK: - Ground Review - Environment and Procedures
            ChecklistItem(title: "4.1. Ground - ATC Instructions", notes: "Review compliance with ATC instructions per 14 CFR 91.123", order: 21),
            ChecklistItem(title: "4.2. Ground - Flight Plans", notes: "Review IFR flight plan requirements per 14 CFR 91.169", order: 22),
            ChecklistItem(title: "4.3. Ground - ATC Clearances", notes: "Review ATC clearance and flight plan requirements per 14 CFR 91.173", order: 23),
            ChecklistItem(title: "4.4. Ground - IFR Operations", notes: "Review IFR takeoff and landing requirements per 14 CFR 91.175", order: 24),
            ChecklistItem(title: "4.5. Ground - Minimum IFR Altitudes", notes: "Review minimum IFR altitude requirements per 14 CFR 91.177", order: 25),
            ChecklistItem(title: "4.6. Ground - IFR Cruising Altitudes", notes: "Review IFR cruising altitude requirements per 14 CFR 91.179", order: 26),
            ChecklistItem(title: "4.7. Ground - Course Requirements", notes: "Review course to be flown requirements per 14 CFR 91.181", order: 27),
            ChecklistItem(title: "4.8. Ground - Navigation Aids", notes: "Review navigation aid procedures and limitations (AIM Chapter 1)", order: 28),
            ChecklistItem(title: "4.9. Ground - ATC Procedures", notes: "Review ATC procedures and communications (AIM Chapter 4)", order: 29),
            ChecklistItem(title: "4.10. Ground - Air Traffic Procedures", notes: "Review air traffic procedures (AIM Chapter 5)", order: 30),
            
            // MARK: - Ground Review - External Pressures and Emergencies
            ChecklistItem(title: "5.1. Ground - Communication Failures", notes: "Review IFR two-way radio communication failure procedures per 14 CFR 91.185", order: 31),
            ChecklistItem(title: "5.2. Ground - Emergency Procedures", notes: "Review emergency procedures (AIM Chapter 6)", order: 32),
            ChecklistItem(title: "5.3. Ground - National Security", notes: "Review national security and interception procedures (AIM Chapter 5, Section 6)", order: 33),
            ChecklistItem(title: "5.4. Ground - Risk Management", notes: "Review risk management and aeronautical decision making", order: 34),
            ChecklistItem(title: "5.5. Ground - Personal Minimums", notes: "Review and update personal minimums and safety margins", order: 35),
            
            // MARK: - Flight Activities - Preflight
            ChecklistItem(title: "1.1. Flight - Preflight Preparation", notes: "Demonstrate proper preflight planning and weather analysis", order: 36),
            ChecklistItem(title: "1.2. Flight - Weather Information", notes: "Obtain and interpret weather information for flight", order: 37),
            ChecklistItem(title: "1.3. Flight - Cross-Country Planning", notes: "Demonstrate cross-country flight planning skills", order: 38),
            ChecklistItem(title: "1.4. Flight - Preflight Procedures", notes: "Demonstrate proper preflight inspection procedures", order: 39),
            ChecklistItem(title: "1.5. Flight - Aircraft Systems", notes: "Demonstrate knowledge of aircraft systems and limitations", order: 40),
            ChecklistItem(title: "1.6. Flight - Flight Instruments", notes: "Demonstrate knowledge of flight instruments and navigation equipment", order: 41),
            ChecklistItem(title: "1.7. Flight - Cockpit Check", notes: "Demonstrate proper cockpit check procedures", order: 42),
            
            // MARK: - Flight Activities - Ground Operations
            ChecklistItem(title: "2.1. Flight - ATC Clearances", notes: "Demonstrate proper ATC clearance procedures", order: 43),
            ChecklistItem(title: "2.2. Flight - Departure Procedures", notes: "Demonstrate proper departure procedures and clearances", order: 44),
            ChecklistItem(title: "2.3. Flight - Taxi Operations", notes: "Demonstrate safe taxi operations and runway safety", order: 45),
            ChecklistItem(title: "2.4. Flight - Runway Incursion Avoidance", notes: "Demonstrate runway incursion avoidance procedures", order: 46),
            ChecklistItem(title: "2.5. Flight - Pre-Takeoff Checks", notes: "Demonstrate proper pre-takeoff checks and procedures", order: 47),
            
            // MARK: - Flight Activities - Takeoff and Departure
            ChecklistItem(title: "3.1. Flight - Normal Takeoff", notes: "Demonstrate normal takeoff procedures", order: 48),
            ChecklistItem(title: "3.2. Flight - Short Field Takeoff", notes: "Demonstrate short field takeoff procedures", order: 49),
            ChecklistItem(title: "3.3. Flight - Soft Field Takeoff", notes: "Demonstrate soft field takeoff procedures", order: 50),
            ChecklistItem(title: "3.4. Flight - Crosswind Takeoff", notes: "Demonstrate crosswind takeoff procedures", order: 51),
            ChecklistItem(title: "3.5. Flight - Engine Failure on Takeoff", notes: "Demonstrate engine failure on takeoff procedures", order: 52),
            ChecklistItem(title: "3.6. Flight - Rejected Takeoff", notes: "Demonstrate rejected takeoff procedures", order: 53),
            
            // MARK: - Flight Activities - En Route Operations
            ChecklistItem(title: "4.1. Flight - Climb Procedures", notes: "Demonstrate proper climb procedures and performance", order: 54),
            ChecklistItem(title: "4.2. Flight - Cruise Operations", notes: "Demonstrate cruise operations and performance", order: 55),
            ChecklistItem(title: "4.3. Flight - Navigation", notes: "Demonstrate navigation skills and procedures", order: 56),
            ChecklistItem(title: "4.4. Flight - Communication", notes: "Demonstrate proper communication procedures", order: 57),
            ChecklistItem(title: "4.5. Flight - Weather Avoidance", notes: "Demonstrate weather avoidance and decision making", order: 58),
            ChecklistItem(title: "4.6. Flight - Fuel Management", notes: "Demonstrate fuel management and planning", order: 59),
            ChecklistItem(title: "4.7. Flight - Holding Procedures", notes: "Demonstrate holding procedures (if applicable)", order: 60),
            
            // MARK: - Flight Activities - Approach and Landing
            ChecklistItem(title: "5.1. Flight - Approach Planning", notes: "Demonstrate approach planning and briefing", order: 61),
            ChecklistItem(title: "5.2. Flight - Traffic Pattern", notes: "Demonstrate proper traffic pattern procedures", order: 62),
            ChecklistItem(title: "5.3. Flight - Normal Landing", notes: "Demonstrate normal landing procedures", order: 63),
            ChecklistItem(title: "5.4. Flight - Short Field Landing", notes: "Demonstrate short field landing procedures", order: 64),
            ChecklistItem(title: "5.5. Flight - Soft Field Landing", notes: "Demonstrate soft field landing procedures", order: 65),
            ChecklistItem(title: "5.6. Flight - Crosswind Landing", notes: "Demonstrate crosswind landing procedures", order: 66),
            ChecklistItem(title: "5.7. Flight - Go-Around Procedures", notes: "Demonstrate go-around procedures", order: 67),
            ChecklistItem(title: "5.8. Flight - Stabilized Approaches", notes: "Demonstrate stabilized approach procedures", order: 68),
            
            // MARK: - Flight Activities - Emergency Operations
            ChecklistItem(title: "6.1. Flight - Emergency Procedures", notes: "Demonstrate emergency procedures knowledge", order: 69),
            ChecklistItem(title: "6.2. Flight - Communication Failures", notes: "Demonstrate communication failure procedures", order: 70),
            ChecklistItem(title: "6.3. Flight - Engine Failures", notes: "Demonstrate engine failure procedures", order: 71),
            ChecklistItem(title: "6.4. Flight - Electrical Failures", notes: "Demonstrate electrical failure procedures", order: 72),
            ChecklistItem(title: "6.5. Flight - Instrument Failures", notes: "Demonstrate instrument failure procedures", order: 73),
            ChecklistItem(title: "6.6. Flight - Automation Failures", notes: "Demonstrate automation failure and manual flight procedures", order: 74),
            ChecklistItem(title: "6.7. Flight - Emergency Landings", notes: "Demonstrate emergency landing procedures", order: 75),
            
            // MARK: - Flight Activities - Advanced Maneuvers
            ChecklistItem(title: "7.1. Flight - Steep Turns", notes: "Demonstrate steep turn procedures", order: 76),
            ChecklistItem(title: "7.2. Flight - Slow Flight", notes: "Demonstrate slow flight procedures", order: 77),
            ChecklistItem(title: "7.3. Flight - Stalls", notes: "Demonstrate stall recognition and recovery", order: 78),
            ChecklistItem(title: "7.4. Flight - Spins", notes: "Demonstrate spin recognition and recovery (if applicable)", order: 79),
            ChecklistItem(title: "7.5. Flight - Unusual Attitudes", notes: "Demonstrate unusual attitude recovery", order: 80),
            ChecklistItem(title: "7.6. Flight - Ground Reference Maneuvers", notes: "Demonstrate ground reference maneuvers", order: 81),
            
            // MARK: - Post-Flight Activities
            ChecklistItem(title: "1.1. Post-Flight - After Landing", notes: "Demonstrate proper after landing procedures", order: 82),
            ChecklistItem(title: "1.2. Post-Flight - Taxi to Parking", notes: "Demonstrate safe taxi to parking procedures", order: 83),
            ChecklistItem(title: "1.3. Post-Flight - Securing Aircraft", notes: "Demonstrate proper aircraft securing procedures", order: 84),
            ChecklistItem(title: "1.4. Post-Flight - Equipment Check", notes: "Demonstrate post-flight equipment check", order: 85),
            
            // MARK: - Post-Review Considerations
            ChecklistItem(title: "2.1. Post-Review - Performance Assessment", notes: "Assess pilot performance and identify areas for improvement", order: 86),
            ChecklistItem(title: "2.2. Post-Review - Strengths Identified", notes: "Identify pilot strengths and areas of proficiency", order: 87),
            ChecklistItem(title: "2.3. Post-Review - Recommendations", notes: "Provide recommendations for continued proficiency", order: 88),
            ChecklistItem(title: "2.4. Post-Review - Personal Currency Program", notes: "Update personal currency program and goals", order: 89),
            ChecklistItem(title: "2.5. Post-Review - Training Plan", notes: "Develop or update training plan for continued proficiency", order: 90),
            ChecklistItem(title: "2.6. Post-Review - Safety Culture", notes: "Discuss safety culture and continuous improvement", order: 91),
            ChecklistItem(title: "2.7. Post-Review - Logbook Entry", notes: "Make appropriate logbook entry for flight review completion", order: 92),
            ChecklistItem(title: "2.8. Post-Review - Endorsement", notes: "I certify that [Pilot's Full Name], [Pilot Certificate, e.g., Private Pilot], [Certificate Number], has satisfactorily completed the flight review required in §61.56(a) on [Date].", order: 93),
        ]
    )
    
    static let instrumentProficiencyCheck = ChecklistTemplate(
        name: "Instrument Proficiency Check",
        category: "Reviews",
        phase: "Flight Reviews",
        templateIdentifier: "default_instrument_proficiency_check",
        items: [
            // MARK: - Step 1: Preparation
            ChecklistItem(title: "1.1 Preparation - Expectations", notes: "Plan at least 90 minutes ground time and 2 hours flight time minimum", order: 0),
            ChecklistItem(title: "1.2 Preparation - Regulatory Review", notes: "Pilot reviewed: Instrument Procedures Handbook, Instrument Flying Handbook, Aviation Weather and Weather Services", order: 1),
            ChecklistItem(title: "1.3 Preparation - Documents Brought", notes: "Pilot brought: PTS, FAR/AIM, charts, A/FD, POH/AFM for aircraft", order: 2),
            ChecklistItem(title: "1.4 Preparation - IPC Prep Course", notes: "Pilot completed IPC Prep Course at faasafety.gov", order: 3),
            ChecklistItem(title: "1.5 Preparation - Cross-Country Assignment", notes: "Assigned representative IFR cross-country route with published approaches", order: 4),
            ChecklistItem(title: "1.6 Preparation - Weather Briefing", notes: "Standard weather briefing obtained for assigned route and date", order: 5),
            
            // MARK: - Step 2: Ground Review - Preflight
            ChecklistItem(title: "2.1 Ground Review - Weather Analysis", notes: "METARs, TAFs, winds aloft, radar, freezing levels, personal minimums compliance", order: 6),
            ChecklistItem(title: "2.2 Ground Review - Flight Planning", notes: "Route selection, alternates, fuel planning, terrain avoidance, passenger planning", order: 7),
            ChecklistItem(title: "2.3 Ground Review - Aircraft Systems", notes: "Pitot-static, gyroscopic instruments, magnetic compass, electrical, navigation, communication", order: 8),
            ChecklistItem(title: "2.4 Ground Review - Performance", notes: "Takeoff distance, climb performance, cruise performance, landing distance", order: 9),
            ChecklistItem(title: "2.5 Ground Review - Taxi/Takeoff/Departure", notes: "Taxi procedures, takeoff procedures, departure procedures, obstacle clearance, communication", order: 10),
            ChecklistItem(title: "2.6 Ground Review - En Route", notes: "Navigation procedures, altitude selection, airspace compliance, weather avoidance, fuel management", order: 11),
            ChecklistItem(title: "2.7 Ground Review - Arrival/Approach", notes: "Arrival procedures, approach briefing, minimums, missed approach procedures, decision points", order: 12),
            ChecklistItem(title: "2.8 Ground Review - Missed Approach", notes: "Missed approach procedures, climb procedures, navigation after missed, communication", order: 13),
            
            // MARK: - Step 3: Flight Activities - Aircraft Control
            ChecklistItem(title: "3.1 Flight - Basic Attitude Instrument Flying", notes: "Straight and level flight, standard rate turns, climbs and descents", order: 14),
            ChecklistItem(title: "3.2 Flight - Unusual Attitudes", notes: "Recovery from unusual attitudes, partial panel operations", order: 15),
            ChecklistItem(title: "3.3 Flight - Systems Knowledge", notes: "Pitot-static system, gyroscopic instruments, magnetic compass, electrical system", order: 16),
            ChecklistItem(title: "3.4 Flight - Navigation Equipment", notes: "Navigation equipment operation, autopilot systems, communication procedures", order: 17),
            ChecklistItem(title: "3.5 Flight - Aeronautical Decision Making", notes: "Weather decision making, risk management, emergency procedures", order: 18),
            
            // MARK: - Step 4: Post-Flight Debriefing
            ChecklistItem(title: "4.1 Post-Flight - Performance Review", notes: "Review pilot performance, identify areas for improvement", order: 19),
            ChecklistItem(title: "4.2 Post-Flight - Strengths Identified", notes: "Identify pilot strengths and areas of proficiency", order: 20),
            ChecklistItem(title: "4.3 Post-Flight - Recommendations", notes: "Provide recommendations for continued proficiency", order: 21),
            ChecklistItem(title: "4.4 Post-Flight - Next Steps", notes: "Discuss next steps and practice plan", order: 22),
            
            // MARK: - Step 5: Instrument Flying Practice Plan
            ChecklistItem(title: "5.1 Practice Plan - Personal Minimums", notes: "Develop weather minimums, wind limits, performance limits", order: 23),
            ChecklistItem(title: "5.2 Practice Plan - Proficiency Goals", notes: "Set monthly IFR hours, approaches, annual goals, cross-country flights", order: 24),
            ChecklistItem(title: "5.3 Practice Plan - Training Plan", notes: "Establish goals, timeline, instructor qualifications, additional training", order: 25),
            
            // MARK: - 3-P Risk Management Process
            ChecklistItem(title: "6.1 Risk Management - Perceive Hazards", notes: "Identify pilot, aircraft, environment, and external pressure factors", order: 26),
            ChecklistItem(title: "6.2 Risk Management - Process Risk", notes: "Evaluate consequences, alternatives, reality, external pressures", order: 27),
            ChecklistItem(title: "6.3 Risk Management - Perform", notes: "Mitigate or eliminate risks, make risk management decisions", order: 28),
            
            // MARK: - Weather Analysis Process
            ChecklistItem(title: "7.1 Weather - Big Picture Overview", notes: "Review overall weather pattern and trends", order: 29),
            ChecklistItem(title: "7.2 Weather - TAFs and METARs", notes: "Analyze terminal aerodrome forecasts and meteorological reports", order: 30),
            ChecklistItem(title: "7.3 Weather - Winds and Temps Aloft", notes: "Review winds and temperatures aloft for route planning", order: 31),
            ChecklistItem(title: "7.4 Weather - Radar and Freezing Levels", notes: "Check radar returns and freezing level information", order: 32),
            ChecklistItem(title: "7.5 Weather - Personal Minimums Compliance", notes: "Verify weather meets established personal minimums", order: 33),
            ChecklistItem(title: "7.6 Weather - Flight Service Briefing", notes: "Obtain standard briefing from Flight Service or DUATS", order: 34),
            ChecklistItem(title: "7.7 Weather - IFR Flight Plan", notes: "File IFR flight plan and verify information", order: 35),
            
            // MARK: - Regional/Seasonal Considerations
            ChecklistItem(title: "8.1 Regional - Topography", notes: "Consider mountains, bodies of water, and other terrain features", order: 36),
            ChecklistItem(title: "8.2 Regional - Seasonal Weather", notes: "Review seasonal weather characteristics and local knowledge", order: 37),
            ChecklistItem(title: "8.3 Regional - Local Factors", notes: "Apply local knowledge and regional weather patterns", order: 38),
            
            // MARK: - Instrument Training and Proficiency Plan
            ChecklistItem(title: "9.1 Training - Certificate Level", notes: "Document certificate level, ratings, and endorsements", order: 39),
            ChecklistItem(title: "9.2 Training - Proficiency Goals", notes: "Set goals for lowering personal minimums and IFR/IMC frequency", order: 40),
            ChecklistItem(title: "9.3 Training - Aeronautical Plan", notes: "Develop comprehensive aeronautical training plan", order: 41),
            
            // MARK: - Completion and Endorsement
            ChecklistItem(title: "10.1 Completion - Overall Assessment", notes: "Complete overall assessment of pilot's instrument proficiency", order: 42),
            ChecklistItem(title: "10.2 Completion - Endorsement", notes: "I certify that [First name, MI, Last name, grade of pilot certificate, certificate number], has satisfactorily completed the instrument proficiency check of § 61.57(d) in a [list make and model of aircraft] on [date].", order: 43),
            ChecklistItem(title: "10.3 Completion - Logbook Entry", notes: "Make appropriate logbook entry for IPC completion", order: 44),
        ]
    )
    
    // MARK: - Instrument Rating Templates
    
    static let i1L1PreflightAndBasicInstrumentControl = ChecklistTemplate(
        name: "I1-L1: Pre-flight and Basic Instrument Control",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i1_l1_preflight_and_basic_instrument_control",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Review & explain the PAVE checklist with emphasis on environmental conditions", order: 0),
            ChecklistItem(title: "2. Positive Exchange of Flight Controls", notes: "Understands and uses the positive three-step exchange of controls", order: 1),
            ChecklistItem(title: "3. Collision Avoidance Procedures", notes: "Clear understanding of responsibilities & procedures for visual & Instrument reference", order: 2),
            ChecklistItem(title: "4. Using the Checklists", notes: "Exercises an effective flow and check process for procedures", order: 3),
            ChecklistItem(title: "5. Preflight for Instrument Flight", notes: "Perform aircraft inspection with emphasis on systems associated with instrument flight", order: 4),
            ChecklistItem(title: "6. Checking the Instruments on the Ground", notes: "Systematically checks instruments & systems for proper indications during ground operations", order: 5),
            ChecklistItem(title: "7. Runway Incursion Avoidance", notes: "Uses airport diagram, notes taxi clearances, requests clarification as needed", order: 6),
            ChecklistItem(title: "8. Normal Takeoff and Climb", notes: "Completes pre-takeoff checks, checks HI on runway, notes airspeed indications on takeoff roll", order: 7),
            ChecklistItem(title: "9. Constant Airspeed Climbs", notes: "Smooth transition level to climb, maintains airspeed ±15kts, heading ±15°, bank ±10°", order: 8),
            ChecklistItem(title: "10. Level-Off from Climb", notes: "Smooth transition climb to level ±100 ft, accelerates to cruise airspeed, trims", order: 9),
            ChecklistItem(title: "11. Straight and Level", notes: "Maintains airspeed ±15kts, heading ±15°, altitude ±150 ft", order: 10),
            ChecklistItem(title: "12. Level Standard Rate Turns to Heading", notes: "Maintains ±15kts, target bank angle ±5°, stops on assigned heading ±10°, ±150 ft", order: 11),
            ChecklistItem(title: "13. Constant Airspeed Descents", notes: "Smooth transition level to descent, maintains airspeed ±15kts, heading ±15°, bank ±10°", order: 12),
            ChecklistItem(title: "14. Level-Off from Descent", notes: "Smooth transition descent to level ±100 ft, returns to cruise airspeed, trims", order: 13),
            ChecklistItem(title: "15. Normal Approach and Landing", notes: "Completes pre-landing checks, smooth landing with appropriate crosswind correction", order: 14),
            ChecklistItem(title: "16. After landing, Taxi, Parking", notes: "Exercises good practices to avoid runway incursions", order: 15),
            ChecklistItem(title: "17. Postflight Procedures", notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies", order: 16),
        ]
    )
    
    static let i1L2ExpandingInstrumentSkills = ChecklistTemplate(
        name: "I1-L2: Expanding Instrument Skills",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i1_l2_expanding_instrument_skills",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist in identifying & mitigating flight risks, briefs the weather", order: 0),
            ChecklistItem(title: "2. Controlled Flight into Terrain Awareness", notes: "Briefs local area vertical obstructions & charted maximum elevation figures", order: 1),
            ChecklistItem(title: "3. Pre-takeoff Calculations", notes: "Briefs Weight & Balance and Takeoff and Landing performance data for conditions", order: 2),
            ChecklistItem(title: "4. Preflight for Instrument Flight", notes: "Complete aircraft inspection with emphasis on systems associated with instrument flight", order: 3),
            ChecklistItem(title: "5. Checking the Instruments on the ground", notes: "Systematically checks instruments & systems for proper indications during ground operations", order: 4),
            ChecklistItem(title: "6. Runway Incursion Avoidance", notes: "Uses airport diagram, notes taxi clearances, requests clarification as needed", order: 5),
            ChecklistItem(title: "7. Constant Rate Climbs", notes: "Smooth transition level to climb, rate ±200 fpm, heading ±15°, levels ±100 ft", order: 6),
            ChecklistItem(title: "8. Constant Rate Descents", notes: "Smooth transition level to descent, rate ±200 fpm, heading ±15°", order: 7),
            ChecklistItem(title: "9. Constant Rate Climbs and Descents with Constant Airspeed", notes: "Notes pitch & power, rate ±200 fpm, airspeed ±15kts, heading ±15°, levels ±100 ft", order: 8),
            ChecklistItem(title: "10. Level Standard Rate Turns to Headings", notes: "Up to 180° of turn, airspeed ±15kts, heading ±10°, alt ±150 ft, bank angle ±5°", order: 9),
            ChecklistItem(title: "11. Climbs and Descents While Turning to a Heading", notes: "Maintains airspeed ±15kts, heading ±15°, bank ±10°, levels ±100 ft", order: 10),
            ChecklistItem(title: "12. Straight and Level While Changing Airspeed", notes: "Maintains ±150 ft, heading ±15°, airspeed ±10kts, correct use of trim", order: 11),
            ChecklistItem(title: "13. After landing, Taxi, Parking", notes: "Exercises good practices to avoid runway incursions", order: 12),
            ChecklistItem(title: "14. Postflight Procedures", notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies", order: 13),
        ]
    )
    
    static let i1L3UsingTheMagneticCompass = ChecklistTemplate(
        name: "I1-L3: Using the Magnetic Compass",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i1_l3_using_the_magnetic_compass",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist, briefs weight & balance, takeoff & landing performance, & weather", order: 0),
            ChecklistItem(title: "2. Controlled Flight into Terrain Avoidance", notes: "Briefs local area minimum safe altitudes for IR operations", order: 1),
            ChecklistItem(title: "3. Automation Management", notes: "Review installed technically advanced systems & application for situation awareness & failures", order: 2),
            ChecklistItem(title: "4. Task Management", notes: "Review priorities regarding aircraft control, equipment failures, navigation & communications", order: 3),
            ChecklistItem(title: "5. Preflight for Instrument Flight", notes: "Complete aircraft inspection with emphasis on systems associated with instrument flight", order: 4),
            ChecklistItem(title: "6. Checking the Instruments on the Ground", notes: "Systematically checks instruments & systems for proper indications during ground operations", order: 5),
            ChecklistItem(title: "7. Runway Incursion Avoidance", notes: "Uses airport diagram, notes taxi clearances, requests clarification as needed", order: 6),
            ChecklistItem(title: "8. Constant Rate Climbs and Descents with Constant Airspeed", notes: "Notes pitch & power, rate ±200 fpm, airspeed ±10kts, heading ±10°, levels ±100 ft", order: 7),
            ChecklistItem(title: "9. Level Standard Rate Turns to Headings", notes: "Up to 180° of turn, alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±10°", order: 8),
            ChecklistItem(title: "10. Climbs and Descents While Turning to a Heading", notes: "Maintains airspeed ± 10kts, heading ±15°, bank ±10°, heading ±10°, levels ± 100 ft", order: 9),
            ChecklistItem(title: "11. Straight and Level While Changing Airspeed", notes: "Maintains ±150 ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 10),
            ChecklistItem(title: "12. Turns to Headings Using Magnetic Compass", notes: "Alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±20°", order: 11),
            ChecklistItem(title: "13. Timed Turns to Headings Using Magnetic Compass", notes: "Alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±20°", order: 12),
            ChecklistItem(title: "14. After Landing, Taxi, Parking", notes: "Exercises good practices to avoid runway incursions", order: 13),
            ChecklistItem(title: "15. Postflight Procedures", notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies", order: 14),
        ]
    )
    
    static let i1L4IFRFlightPlansAndClearances = ChecklistTemplate(
        name: "I1-L4: IFR Flight Plans and Clearances",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i1_l4_ifr_flight_plans_and_clearances",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist, briefs weight & balance, takeoff & landing performance, & weather", order: 0),
            ChecklistItem(title: "2. Enroute Charts", notes: "Review chart symbology for planned route", order: 1),
            ChecklistItem(title: "3. Flight Plan", notes: "Using route provided, prepares an IFR flight plan to a nearby airport", order: 2),
            ChecklistItem(title: "4. Situational Awareness", notes: "Review planned route for leg courses, distances, and ETE for an in-flight mental picture", order: 3),
            ChecklistItem(title: "5. Preflight for Instrument Flight", notes: "Complete aircraft inspection with emphasis on systems associated with instrument flight", order: 4),
            ChecklistItem(title: "6. Checking the Instruments on the Ground", notes: "Systematically checks instruments & systems for proper indications during ground operations", order: 5),
            ChecklistItem(title: "7. Copy and Read Back IFR Clearance", notes: "Simulated: requests clearance, copies simple clearance & correctly reads back clearance", order: 6),
            ChecklistItem(title: "8. Flying an \"ATC\" Route, Vectors and Altitudes", notes: "Conforms to assigned route, vectors, and altitudes in clearance or as assigned by \"ATC\"", order: 7),
            ChecklistItem(title: "9. Constant Rate Climbs and Descents with Constant Airspeed", notes: "Notes pitch & power, rate ± 200 fpm, airspeed ± 10kts, heading ±10°, levels ± 100 ft", order: 8),
            ChecklistItem(title: "10. Level Standard Rate Turns to Headings", notes: "Up to 180° of turn, alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±10°", order: 9),
            ChecklistItem(title: "11. Climbs and Descents While Turning to a Heading", notes: "Maintains airspeed ± 10kts, heading ±15°, bank ±10°, heading ±10°, levels ± 100 ft", order: 10),
            ChecklistItem(title: "12. Straight and Level While Changing Airspeed", notes: "Maintains ±150 ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 11),
            ChecklistItem(title: "13. Turns to Headings Using Magnetic Compass", notes: "Alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±20°", order: 12),
            ChecklistItem(title: "14. Timed Turns to Heading Using Magnetic Compass", notes: "Alt ±150 ft, airspeed ± 10kts, bank angle ±5°, heading ±20°", order: 13),
            ChecklistItem(title: "15. After landing, Taxi, Parking", notes: "Exercises good practices to avoid runway incursions", order: 14),
            ChecklistItem(title: "16. Postflight Procedures", notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies", order: 15),
        ]
    )
    
    static let i1L5PrimaryFlightInstrumentDisplayFailure = ChecklistTemplate(
        name: "I1-L5: Primary Flight Instrument/Display Failure",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i1_l5_primary_flight_instrument_display_failure",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (W&B, Performance, Weather), reviews instrument systems", order: 0),
            ChecklistItem(title: "2. Situational Awareness", notes: "Review aircraft control using standby or partial-panel instruments", order: 1),
            ChecklistItem(title: "3. Aeronautical Decision Making", notes: "Review managing in-flight risk (CARE ) & decisions regarding primary instrument failure", order: 2),
            ChecklistItem(title: "4. Automation Management", notes: "Review autopilot use in the event of primary instruments/display failure", order: 3),
            ChecklistItem(title: "5. Before Instrument Flight Ground Operations", notes: "Complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 4),
            ChecklistItem(title: "6. Copy and Read Back IFR Clearance", notes: "Simulated: requests clearance, copies simple clearance & correctly reads-back clearance", order: 5),
            ChecklistItem(title: "7. Straight and Level Using Standby/Partial-Panel Instruments", notes: "Maintains ±150 ft, heading ±15°, airspeed ±10kts", order: 6),
            ChecklistItem(title: "8. Standard Rate Turns to Headings Standby/Partial-Panel Instruments", notes: "Up to 180° of turn, alt ±150 ft, airspeed ± 10kts, heading ±15°", order: 7),
            ChecklistItem(title: "9. Constant Airspeed Climbs Standby/Partial-Panel Instruments", notes: "Airspeed ± 15kts, heading ±15°, levels ±200 ft", order: 8),
            ChecklistItem(title: "10. Constant Airspeed Descents Standby/Partial-Panel Instruments", notes: "Airspeed ± 15kts, heading ±15°, levels ±200 ft", order: 9),
            ChecklistItem(title: "11. Unusual Attitudes Recovery (Nose High/Low) Full Panel", notes: "Returns to stabilized level flight within operating limitations or not entering unsafe conditions", order: 10),
            ChecklistItem(title: "12. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel", notes: "Returns to stabilized level flight within operating limitations or not entering unsafe conditions", order: 11),
            ChecklistItem(title: "13. Straight and Level While Changing Airspeed", notes: "Maintains ±150 ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 12),
            ChecklistItem(title: "14. Timed Turns to Heading Using Magnetic Compass", notes: "Alt ±150 ft, airspeed ±10kts, bank angle ±5°, heading ±20°", order: 13),
            ChecklistItem(title: "15. After landing, Taxi, Parking", notes: "Exercises good practices to avoid runway incursions", order: 14),
            ChecklistItem(title: "16. Postflight Procedures", notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies", order: 15),
        ]
    )
    
    static let i1L6ReviewOfInstrumentControlAndProgressCheck = ChecklistTemplate(
        name: "I1-L6: Review of Instrument Control and Progress Check",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i1_l6_review_of_instrument_control_and_progress_check",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Weather)", order: 0),
            ChecklistItem(title: "2. Situational Awareness and Controlled Flight into Terrain Awareness", notes: "Briefs ways to maintain situational awareness & avoid terrain in instrument conditions", order: 1),
            ChecklistItem(title: "3. Positive Exchange of Flight Controls", notes: "Briefs the positive three-step exchange of controls", order: 2),
            ChecklistItem(title: "4. Automation Management", notes: "Briefs autopilot use in the event of primary instruments/display failures", order: 3),
            ChecklistItem(title: "5. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 4),
            ChecklistItem(title: "6. Copy and Read-back IFR Clearance", notes: "Simulated: requests clearance, copies simple clearance & correctly reads-back clearance", order: 5),
            ChecklistItem(title: "7. Using the Checklists", notes: "Exercises an effective flow and check process for procedures", order: 6),
            ChecklistItem(title: "8. Collision Avoidance Procedures", notes: "Clear understanding of responsibilities & procedures for visual & Instrument reference", order: 7),
            ChecklistItem(title: "9. Constant Rate Climbs and Descents with Constant Airspeed", notes: "Maintains rate ±150 fpm, airspeed ±10 kts, heading ±10°, levels ±100 ft", order: 8),
            ChecklistItem(title: "10. Straight and Level While Changing Airspeed", notes: "Maintains ±120ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 9),
            ChecklistItem(title: "11. Level Standard Rate Turns to Headings", notes: "Up to 180° of turn, maintains alt ±120 ft, airspeed ±10kts, bank angle ±5°, heading ±10°", order: 10),
            ChecklistItem(title: "12. Climbs and Descents While Turning to a Heading", notes: "Maintains airspeed ±10 kts, heading ±10°, bank ±10°, levels ± 100 ft", order: 11),
            ChecklistItem(title: "13. Straight and Level Using Standby/Partial-Panel Instruments", notes: "Maintains ±150 ft, heading ±15°, airspeed ±10kts", order: 12),
            ChecklistItem(title: "14. Standard Rate Turns to Headings Standby/Partial-Panel Instruments", notes: "Up to 180° of turn, maintains alt ±150 ft, airspeed ±10kts, heading ±15°", order: 13),
            ChecklistItem(title: "15. Constant Airspeed Climbs and Descents Standby/Partial-Panel Instruments", notes: "Maintains airspeed ±15 kts, heading ±15°, levels ±200 ft", order: 14),
            ChecklistItem(title: "16. Timed Turns to Heading Using Magnetic Compass", notes: "Maintains alt ±150 ft, airspeed ±10 kts, bank angle ±5°, heading ±20°", order: 15),
            ChecklistItem(title: "17. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel", notes: "Returns to stabilized level flight within operating limitations or not entering unsafe conditions", order: 16),
            ChecklistItem(title: "18. After landing, Taxi, Parking", notes: "Exercises good practices to avoid runway incursions", order: 17),
            ChecklistItem(title: "19. Postflight Procedures", notes: "Notes equipment operation, conducts postflight inspection, documents discrepancies", order: 18),
        ]
    )
    
    static let i2L1GPSAndVORForIFR = ChecklistTemplate(
        name: "I2-L1: GPS and VOR for IFR",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i2_l1_gps_and_vor_for_ifr",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Weather)", order: 0),
            ChecklistItem(title: "2. Situational Awareness", notes: "Reviews situational awareness issues with RNAV (GPS) and VOR systems", order: 1),
            ChecklistItem(title: "3. Controlled Flight into Terrain Awareness", notes: "Briefs charted minimum altitudes and hazards of off-airway routes", order: 2),
            ChecklistItem(title: "4. Automation Management", notes: "Review autopilot use for instrument flight", order: 3),
            ChecklistItem(title: "5. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 4),
            ChecklistItem(title: "6. Using GPS for IFR Flight", notes: "Review certification level, capabilities & limitations of installed GPS equipment", order: 5),
            ChecklistItem(title: "7. Using VOR for IFR Flight", notes: "Reviews requirements & options for checking whether a VOR is suitable for IFR; does VOR check", order: 6),
            ChecklistItem(title: "8. GPS Flight Plan", notes: "Enters flight plan into GPS(RNAV) unit & confirms that it matches prebriefed route", order: 7),
            ChecklistItem(title: "9. GPS Orientation", notes: "Position with GPS, selects appropriate course/altitude to specified route or waypoint", order: 8),
            ChecklistItem(title: "10. GPS Course Interception and Tracking", notes: "Altitude ±150 ft, airspeed ±10 kts, intercepts and tracks course < full-scale deflection", order: 9),
            ChecklistItem(title: "11. VOR Tune and Identification", notes: "Determines & selects VOR frequency, identifies station by comparing audio code with chart", order: 10),
            ChecklistItem(title: "12. VOR Orientation", notes: "Orientation with 1 VOR & position with 2 or more, selects course/altitude to designated VOR", order: 11),
            ChecklistItem(title: "13. VOR Radial Interception and Tracking", notes: "Altitude ±150 ft, airspeed ±10 kts, intercepts and tracks radial < full-scale deflection", order: 12),
            ChecklistItem(title: "14. Timed Turns to Heading Using Magnetic Compass", notes: "Maintains alt ±120 ft, airspeed ± 10 kts, heading ±15°", order: 13),
            ChecklistItem(title: "15. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 14),
        ]
    )
    
    static let i2L2NDBADFNavigationAndDepartureProcedures = ChecklistTemplate(
        name: "I2-L2: NDB/ADF Navigation and Departure Procedures",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i2_l2_ndb_adf_navigation_and_departure_procedures",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Weather)", order: 0),
            ChecklistItem(title: "2. Situational Awareness", notes: "Reviews situational awareness issues with NDB/ADF and VOR systems and published procedures", order: 1),
            ChecklistItem(title: "3. Controlled Flight into Terrain Awareness", notes: "Reviews climb requirements and minimum altitudes on published procedures", order: 2),
            ChecklistItem(title: "4. Single Pilot Resource Management", notes: "Review the resources available for single-pilot IFR operations", order: 3),
            ChecklistItem(title: "5. Using NDB for IFR Navigation", notes: "Review NBD signals, ADF system operation/limitations & installed instrumentation", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 5),
            ChecklistItem(title: "7. Instrument Departure Procedure", notes: "Conforms to procedure restrictions, courses, & altitudes", order: 6),
            ChecklistItem(title: "8. NDB Orientation", notes: "Tunes, identifies & finds bearing to/from NDB, selects heading/altitude for specified route", order: 7),
            ChecklistItem(title: "9. NDB Bearing Interception and Tracking", notes: "Alt ±150 ft, airspeed ±10 kts, intercepts and tracks ±15° desired bearing inbound/outbound", order: 8),
            ChecklistItem(title: "10. VOR Orientation", notes: "Orientation with 1 VOR & position with 2 or more, selects course/altitude to designated VOR", order: 9),
            ChecklistItem(title: "11. Airway Interception and Tracking", notes: "Intercepts & tracks VOR airway, identifies intersection, alt ±120 ft, airspeed ±10 kts, ≤3/4 CDI", order: 10),
            ChecklistItem(title: "12. Turns, Climbs and Descents Standby/Partial-Panel Instruments", notes: "Alt ±150 ft, airspeed ±15kts, heading ±15°, levels ±150 ft", order: 11),
            ChecklistItem(title: "13. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel", notes: "Returns to stabilized level flight within operating limitations or not entering unsafe conditions", order: 12),
            ChecklistItem(title: "14. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 13),
        ]
    )
    
    static let i2L3BuildingSkillWithGPSVORAndNDBNDBNavigation = ChecklistTemplate(
        name: "I2-L3: Building Skill with GPS, VOR and NDB/NDB Navigation",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i2_l3_building_skill_with_gps_vor_and_ndb_ndb_navigation",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Weather)", order: 0),
            ChecklistItem(title: "2. Situational Awareness", notes: "Briefs situational awareness issues with GPS, NDB & VOR systems and published procedures", order: 1),
            ChecklistItem(title: "3. Controlled Flight into Terrain Awareness", notes: "Briefs climb requirements and minimum altitudes on published procedures", order: 2),
            ChecklistItem(title: "4. Single Pilot Resource Management", notes: "Briefs resources available for single-pilot IFR operations", order: 3),
            ChecklistItem(title: "5. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 5),
            ChecklistItem(title: "7. Instrument Departure Procedure", notes: "Conforms to procedure restrictions, courses, & altitudes", order: 6),
            ChecklistItem(title: "8. GPS Course Interception and Tracking", notes: "Altitude ±100 ft, airspeed ±10 kts, intercepts and tracks course ≤3/4CDI", order: 7),
            ChecklistItem(title: "9. VOR Radial Interception and Tracking", notes: "Intercepts & tracks VOR radial, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 8),
            ChecklistItem(title: "10. Constant Rate Climbs and Descents while Tracking a VOR Radial", notes: "Rate ±100 fpm, airspeed ±10kts, ≤3/4 CDI, levels ±100 ft", order: 9),
            ChecklistItem(title: "11. NDB Bearing Interception and Tracking", notes: "Altitude ±100 ft, airspeed ±10 kts, intercepts and tracks ±10° desired bearing inbound/outbound", order: 10),
            ChecklistItem(title: "12. Airway Interception and Tracking Standby/Partial-Panel", notes: "Intercepts & tracks VOR airway, identifies intersection, alt ±150 ft, airspeed ±10 kts, ≤3/4CDI", order: 11),
            ChecklistItem(title: "13. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 12),
        ]
    )
    
    static let i2L4DMEARX = ChecklistTemplate(
        name: "I2-L4: DME Arcs",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i2_l4_dme_arx",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
            ChecklistItem(title: "2. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 1),
            ChecklistItem(title: "3. Holding Procedures", notes: "Review what ATC expects for holds (concepts, procedures and restrictions)", order: 2),
            ChecklistItem(title: "4. Situational Awareness", notes: "Review ATC reasons for holds, consequences, alternatives, minimum fuel & emergency fuel", order: 3),
            ChecklistItem(title: "5. Single Pilot Resource Management", notes: "Briefs the resources available for single-pilot IFR operations", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 5),
            ChecklistItem(title: "7. DME Arcs Intercepting and Tracking", notes: "Alt ±120 ft, airspeed ±10 kts, heading ±10°, DME ± 1.5 nm, ≤3/4CDI", order: 6),
            ChecklistItem(title: "8. VOR Radial Interception and Tracking", notes: "Intercepts & tracks VOR radial, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 7),
            ChecklistItem(title: "9. NDB Bearing Interception and Tracking", notes: "Altitude ±100 ft, airspeed ±10 kts, intercepts and tracks ±10° desired bearing inbound/outbound", order: 8),
            ChecklistItem(title: "10. GPS Course Interception and Tracking", notes: "Altitude ±100 ft, airspeed ±10 kts, intercepts and tracks course ≤3/4CDI", order: 9),
            ChecklistItem(title: "11. Turns, Climbs and Descents Standby/Partial-Panel Instruments", notes: "Alt ±150 ft, airspeed ±15 kts, heading ±15°, levels ±150 ft", order: 10),
            ChecklistItem(title: "12. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel", notes: "Returns to stabilized level flight within operating limitations or not entering unsafe conditions", order: 11),
            ChecklistItem(title: "13. Airway Interception and Tracking Standby/Partial-Panel", notes: "Intercepts & tracks VOR airway, identifies intersection, alt ±150 ft, airspeed ±10 kts, ≤3/4CDI", order: 12),
            ChecklistItem(title: "14. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 13),
        ]
    )
    
    static let i2L5HoldingProcedures = ChecklistTemplate(
        name: "I2-L5: Holding Procedures",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i2_l5_holding_procedures",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
            ChecklistItem(title: "2. Aeronautical Decision Making", notes: "Review techniques for dealing with ATC imposed changes during a flight, use the CARE checklist", order: 1),
            ChecklistItem(title: "3. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
            ChecklistItem(title: "4. Single Pilot Resource Management", notes: "Briefs the resources available for single-pilot IFR operations", order: 3),
            ChecklistItem(title: "5. Situational Awareness", notes: "Briefs ATC reasons for holds, consequences, alternatives, minimum fuel & emergency fuel", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 5),
            ChecklistItem(title: "7. Holding at a VOR or an NDB", notes: "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction", order: 6),
            ChecklistItem(title: "8. Holding at a VOR with DME or GPS Waypoint", notes: "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction", order: 7),
            ChecklistItem(title: "9. Non-Published Holding at a VOR or an NDB", notes: "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction", order: 8),
            ChecklistItem(title: "10. Non-Published Holding at a VOR Intersection", notes: "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction", order: 9),
            ChecklistItem(title: "11. Holding at a VOR, NDB or GPS Waypoint Standby/Partial-Panel", notes: "Uses recommended entry, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI, wind correction", order: 10),
            ChecklistItem(title: "12. Intercepting and Tracking DME Arcs", notes: "Alt ±100 ft, airspeed ±10 kts, headings ±5°, DME ± 1.0 nm, ≤3/4CDI", order: 11),
            ChecklistItem(title: "13. Airway Interception and Tracking Standby/Partial-Panel", notes: "Intercepts & tracks VOR airway, identifies intersection, alt ±150 ft, airspeed ±10 kts, ≤3/4CDI", order: 12),
            ChecklistItem(title: "14. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 13),
        ]
    )
    
    static let i2L6ProgressCheck = ChecklistTemplate(
        name: "I2-L6: Progress Check",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i2_l6_progress_check",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
            ChecklistItem(title: "2. Situational Awareness and Controlled Flight into Terrain Awareness", notes: "Briefs ways to maintain situational awareness & avoid terrain in instrument conditions", order: 1),
            ChecklistItem(title: "3. Positive Exchange of Flight Controls", notes: "Briefs the positive three-step exchange of controls", order: 2),
            ChecklistItem(title: "4. Automation Management", notes: "Briefs autopilot use in the event of primary instruments/display failures", order: 3),
            ChecklistItem(title: "5. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 4),
            ChecklistItem(title: "6. Copy and Read-back IFR Clearance", notes: "Simulated: requests clearance, copies simple clearance & correctly reads-back clearance", order: 5),
            ChecklistItem(title: "7. Using the Checklists", notes: "Exercises an effective flow and check process for procedures", order: 6),
            ChecklistItem(title: "8. Collision Avoidance Procedures", notes: "Clear understanding of responsibilities & procedures for visual & Instrument reference", order: 7),
            ChecklistItem(title: "9. Constant Rate Climbs and Descents with Constant Airspeed", notes: "Maintains rate ±150 fpm, airspeed ±10 kts, heading ±10°, levels ±100 ft", order: 8),
            ChecklistItem(title: "10. Straight and Level While Changing Airspeed", notes: "Maintains ±120ft, heading ±10°, airspeed ±10kts, correct use of trim", order: 9),
            ChecklistItem(title: "11. Level Standard Rate Turns to Headings", notes: "Up to 180° of turn, maintains alt ±120 ft, airspeed ±10kts, bank angle ±5°, heading ±10°", order: 10),
            ChecklistItem(title: "12. Climbs and Descents While Turning to a Heading", notes: "Maintains airspeed ±10 kts, heading ±10°, bank ±10°, levels ± 100 ft", order: 11),
            ChecklistItem(title: "13. Straight and Level Using Standby/Partial-Panel Instruments", notes: "Maintains ±150 ft, heading ±15°, airspeed ±10kts", order: 12),
            ChecklistItem(title: "14. Standard Rate Turns to Headings Standby/Partial-Panel Instruments", notes: "Up to 180° of turn, maintains alt ±150 ft, airspeed ±10kts, heading ±15°", order: 13),
            ChecklistItem(title: "15. Constant Airspeed Climbs and Descents Standby/Partial-Panel Instruments", notes: "Maintains airspeed ±15 kts, heading ±15°, levels ±200 ft", order: 14),
            ChecklistItem(title: "16. Timed Turns to Heading Using Magnetic Compass", notes: "Maintains alt ±150 ft, airspeed ±10 kts, bank angle ±5°, heading ±20°", order: 15),
            ChecklistItem(title: "17. Unusual Attitudes Recovery (Nose High/Low) Standby/Partial-Panel", notes: "Returns to stabilized level flight within operating limitations or not entering unsafe conditions", order: 16),
            ChecklistItem(title: "18. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 17),
        ]
    )
    
    static let i3L1ILSApproachesAndProcedureTurns = ChecklistTemplate(
        name: "I3-L1: ILS Approaches and Procedure Turns",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i3_l1_ils_approaches_and_procedure_turns",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
            ChecklistItem(title: "2. Situational Awareness", notes: "Briefs situational awareness issues with ILS approaches and published procedures", order: 1),
            ChecklistItem(title: "3. Controlled Flight into Terrain Awareness", notes: "Briefs climb requirements and minimum altitudes on published procedures", order: 2),
            ChecklistItem(title: "4. Single Pilot Resource Management", notes: "Briefs the resources available for single-pilot IFR operations", order: 3),
            ChecklistItem(title: "5. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, taxi, pretakeoff checks with emphasis on instrument flight", order: 5),
            ChecklistItem(title: "7. ILS Approach Briefing", notes: "Briefs ILS approach procedures, minimums, missed approach procedures, and decision heights", order: 6),
            ChecklistItem(title: "8. ILS Approach Intercepting and Tracking", notes: "Intercepts & tracks ILS localizer, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 7),
            ChecklistItem(title: "9. ILS Approach Glideslope Intercepting and Tracking", notes: "Intercepts & tracks ILS glideslope, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 8),
            ChecklistItem(title: "10. ILS Approach Final Approach", notes: "Maintains ILS localizer & glideslope, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 9),
            ChecklistItem(title: "11. ILS Approach Missed Approach", notes: "Executes missed approach procedures, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 10),
            ChecklistItem(title: "12. Procedure Turn", notes: "Executes procedure turn, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI", order: 11),
            ChecklistItem(title: "13. ILS Approach Standby/Partial-Panel", notes: "Intercepts & tracks ILS localizer, alt ±100 ft, airspeed ±10 kts, ≤3/4CDI", order: 12),
            ChecklistItem(title: "14. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 13),
        ]
    )
    
    static let i3L2RNAVApproachesWithVerticalGuidance = ChecklistTemplate(
        name: "I3-L2: RNAV Approaches with Vertical Guidance",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i3_l2_rnav_approaches_with_vertical_guidance",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
            ChecklistItem(title: "3. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
            ChecklistItem(title: "4. Situational Awareness and Controlled Flight into Terrain Awareness", notes: "Briefs navigation systems, backups, minimum altitudes, local minimum safe altitude", order: 3),
            ChecklistItem(title: "5. Checklist Use", notes: "Briefs how will use checklists during instrument approaches and uses them", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight", order: 5),
            ChecklistItem(title: "7. RNAV (GPS) Setup for Approach", notes: "Confirms nav data, calls up & verifies correct procedure/waypoints, notes mode & minima", order: 6),
            ChecklistItem(title: "8. Approach Briefing", notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes", order: 7),
            ChecklistItem(title: "9. Terminal Area Arrival Procedure", notes: "Conforms to published procedure, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI", order: 8),
            ChecklistItem(title: "10. RNAV (GPS WAAS) Approach with Vertical Guidance", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI", order: 9),
            ChecklistItem(title: "11. ILS Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI", order: 10),
            ChecklistItem(title: "12. Missed Approach Procedure", notes: "Initiates at DA/DH if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤3/4CDI", order: 11),
            ChecklistItem(title: "13. Transition to Landing from Straight-In Approach", notes: "From DH/DA normal rate of descent, normal maneuvering, uses visual glideslope", order: 12),
            ChecklistItem(title: "14. Intercepting and Tracking DME Arcs", notes: "Alt ±100 ft, airspeed ±10 kts, headings ±5°, DME ±1 nm, ≤3/4CDI", order: 13),
            ChecklistItem(title: "15. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 14),
        ]
    )
    
    static let i3L4VORAndNDBApproaches = ChecklistTemplate(
        name: "I3-L4: VOR and NDB Approaches",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i3_l4_vor_and_ndb_approaches",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist (Pilot, W&B, Performance, Reserves, Weather)", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
            ChecklistItem(title: "3. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
            ChecklistItem(title: "4. Situational Awareness and Controlled Flight into Terrain Awareness", notes: "Briefs navigation systems, backups, minimum altitudes, local minimum safe altitude", order: 3),
            ChecklistItem(title: "5. Checklist Use", notes: "Uses appropriate checklists during all flight operations", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight", order: 5),
            ChecklistItem(title: "7. Approach Briefing", notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes", order: 6),
            ChecklistItem(title: "8. VOR Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI", order: 7),
            ChecklistItem(title: "9. NDB Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4CDI", order: 8),
            ChecklistItem(title: "10. Localizer Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2CDI", order: 9),
            ChecklistItem(title: "11. Missed Approach Procedure", notes: "Initiates at DA/DH/MAP if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤3/4 CDI", order: 10),
            ChecklistItem(title: "12. Transition to Landing from Straight-In Approach", notes: "From DH/DA/MDA normal rate of descent, normal maneuvering, uses visual glideslope", order: 11),
            ChecklistItem(title: "13. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 12),
        ]
    )
    
    static let i3L5CirclingApproaches = ChecklistTemplate(
        name: "I3-L5: Circling Approaches",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i3_l5_circling_approaches",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Uses PAVE checklist (Pilot, W&B, Performance, Reserves, Weather, day/night, area lighting)", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
            ChecklistItem(title: "3. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
            ChecklistItem(title: "4. Situational Awareness and Controlled Flight into Terrain Awareness", notes: "Briefs nav systems, backups, min altitudes, local min safe altitude, obstructions near airports", order: 3),
            ChecklistItem(title: "5. Checklist Use", notes: "Uses appropriate checklists during all flight operations", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight", order: 5),
            ChecklistItem(title: "7. Approach Briefing", notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes", order: 6),
            ChecklistItem(title: "8. ILS or RNAV (GPS WAAS) Circling Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI", order: 7),
            ChecklistItem(title: "9. VOR or NDB Circling Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI", order: 8),
            ChecklistItem(title: "10. Transition to a Landing from Circling Approach", notes: "Maintains MDA +100/-0 ft, normal rate of descent, normal maneuvering, uses visual glideslope", order: 9),
            ChecklistItem(title: "11. ILS Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2 CDI", order: 10),
            ChecklistItem(title: "12. LNAV Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2 CDI", order: 11),
            ChecklistItem(title: "13. Missed Approach Procedure", notes: "Initiates at DA/DH/MAP if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤ 3/4 CDI", order: 12),
            ChecklistItem(title: "14. Transition to Landing from Straight-In Approach", notes: "From DH/DA/MDA normal rate of descent, normal maneuvering, uses visual glideslope", order: 13),
            ChecklistItem(title: "15. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 14),
        ]
    )
    
    static let i3L6PartialPanelAndUsingTheAutopilotForApproaches = ChecklistTemplate(
        name: "I3-L6: Partial Panel and Using the Autopilot for Approaches",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i3_l6_partial_panel_and_using_the_autopilot_for_approaches",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist, incorporates installed advanced/automated equipment in planning", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
            ChecklistItem(title: "3. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
            ChecklistItem(title: "4. Situational Awareness and Controlled Flight into Terrain Awareness", notes: "Briefs navigation systems, backups, minimum altitudes, local minimum safe altitude", order: 3),
            ChecklistItem(title: "5. Automation Management", notes: "Understands autopilot functions/modes, clear on failure indications and responses", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight", order: 5),
            ChecklistItem(title: "7. Approach Briefing", notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes", order: 6),
            ChecklistItem(title: "8. ILS Approach Standby/Partial-Panel", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI", order: 7),
            ChecklistItem(title: "9. VOR Approach Standby/Partial-Panel", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI", order: 8),
            ChecklistItem(title: "10. NDB Approach Standby/Partial-Panel", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI", order: 9),
            ChecklistItem(title: "11. LNAV or Localizer Approach Standby/Partial-Panel", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤3/4 CDI", order: 10),
            ChecklistItem(title: "12. VOR, NDB, LNAV or Localizer Approach Using Autopilot", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2 CDI", order: 11),
            ChecklistItem(title: "13. ILS Approach Using Autopilot", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2 CDI", order: 12),
            ChecklistItem(title: "14. Missed Approach Procedure", notes: "Initiates at DA/DH/MAP if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤3/4 CDI", order: 13),
            ChecklistItem(title: "15. Transition to a Landing (Straight-in or Circling Approach)", notes: "Maintains MDA +100/-0 ft, normal rate of descent, normal maneuvering, uses visual glideslope", order: 14),
            ChecklistItem(title: "16. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 15),
        ]
    )
    
    static let i3L7ProgressCheck = ChecklistTemplate(
        name: "I3-L7: Progress Check",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i3_l7_progress_check",
        items: [
            ChecklistItem(title: "1. Managing Risk for Instrument Flight", notes: "Employs PAVE checklist, incorporates installed advanced/automated equipment in planning", order: 0),
            ChecklistItem(title: "2. Single Pilot Resource Management", notes: "Briefs the resources available for single-pilot IFR operations", order: 1),
            ChecklistItem(title: "3. Task Management", notes: "Briefs priorities of aircraft control, navigation & communications", order: 2),
            ChecklistItem(title: "4. Situational Awareness and Controlled Flight into Terrain Awareness", notes: "Briefs navigation systems, backups, minimum altitudes, local minimum safe altitude", order: 3),
            ChecklistItem(title: "5. Automation Management", notes: "Briefs autopilot functions/modes, failure indications and responses, approach techniques", order: 4),
            ChecklistItem(title: "6. Before Instrument Flight Ground Operations", notes: "Conducts complete preflight, navigation, taxi, pretakeoff checks for instrument flight", order: 5),
            ChecklistItem(title: "7. Approach Briefing", notes: "Procedure, NAVAID, runway, course, min altitude/visibility, missed approach, notes", order: 6),
            ChecklistItem(title: "8. ILS Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI", order: 7),
            ChecklistItem(title: "9. RNAV (GPS WAAS) Approach with Vertical Guidance", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI", order: 8),
            ChecklistItem(title: "10. VOR or NDB Circling Approach", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI", order: 9),
            ChecklistItem(title: "11. LNAV or Localizer Approach Standby/Partial-Panel", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2CDI", order: 10),
            ChecklistItem(title: "12. VOR, NDB, LNAV or Localizer Approach Using Autopilot", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±10°, ≤1/2CDI", order: 11),
            ChecklistItem(title: "13. Procedure Turn Course Reversal", notes: "Alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI", order: 12),
            ChecklistItem(title: "14. Terminal Area Arrival Procedure", notes: "Conforms to published procedure, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2CDI", order: 13),
            ChecklistItem(title: "15. Holding Pattern Course Reversal", notes: "Correct entry, alt +100/-0 ft after FAF, a/s ±10 kts, heading ±10°, ≤1/2CDI, wind correction", order: 14),
            ChecklistItem(title: "16. Missed Approach Procedure", notes: "Initiates at DA/DH/MAP if no visual reference, +100/-0 ft, a/s ±10 kts, hdg ±10°, ≤1/2CDI", order: 15),
            ChecklistItem(title: "17. Transition to a Landing (Straight-in or Circling Approach)", notes: "Maintains MDA +100/-0 ft, normal rate of descent, normal maneuvering, uses visual glideslope", order: 16),
            ChecklistItem(title: "18. After landing, Taxi, Parking, Postflight", notes: "Exercises good practices to avoid runway incursions, notes & documents discrepancies", order: 17),
        ]
    )
    
    // Phase 4: Instrument Cross Countries
    static let i4L1ShortIFRCrossCountry = ChecklistTemplate(
        name: "I4-L1: Short IFR Cross Country",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i4_l1_short_ifr_cross_country",
        items: [
            ChecklistItem(title: "1. Cross-Country Flight Planning", notes: "Plan IFR cross country to airport >50nm straight-line distance", order: 0),
            ChecklistItem(title: "2. En Route ATC Communications", notes: "Experience en route ATC communications and procedures", order: 1),
            ChecklistItem(title: "3. Navigation Systems", notes: "Practice navigation using various systems during cross-country flight", order: 2),
            ChecklistItem(title: "4. First Instrument Approach", notes: "Fly first instrument approach at destination airport", order: 3),
            ChecklistItem(title: "5. Second Instrument Approach", notes: "Fly second instrument approach (different type)", order: 4),
            ChecklistItem(title: "6. Third Instrument Approach", notes: "Fly third instrument approach (different type)", order: 5),
            ChecklistItem(title: "7. Cross-Country Navigation", notes: "Demonstrate proficiency in cross-country IFR navigation", order: 6),
            ChecklistItem(title: "8. ATC Procedures", notes: "Follow proper ATC procedures throughout flight", order: 7),
            ChecklistItem(title: "9. Weather Considerations", notes: "Plan and execute flight considering weather conditions", order: 8),
            ChecklistItem(title: "10. Fuel Management", notes: "Proper fuel planning and management for cross-country flight", order: 9),
        ]
    )
    
    static let i4L2RefiningApproaches = ChecklistTemplate(
        name: "I4-L2: Refining Approaches",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i4_l2_refining_approaches",
        items: [
            ChecklistItem(title: "1. Single Pilot Resource Management", notes: "Instrument Rating Airman Certification Standards", order: 0),
            ChecklistItem(title: "2. Instrument Cockpit Check", notes: "Instrument Rating Airman Certification Standards", order: 1),
            ChecklistItem(title: "3. ILS Approach", notes: "Instrument Rating Airman Certification Standards", order: 2),
            ChecklistItem(title: "4. RNAV (GPS WAAS) Approach with Vertical Guidance", notes: "Instrument Rating Airman Certification Standards", order: 3),
            ChecklistItem(title: "5. NDB (VOR if NDB not available) Circling Approach", notes: "Instrument Rating Airman Certification Standards", order: 4),
            ChecklistItem(title: "6. VOR Approach Standby/Partial-Panel", notes: "Instrument Rating Airman Certification Standards", order: 5),
            ChecklistItem(title: "7. VOR, NDB, LNAV or Localizer Approach Using Autopilot", notes: "Instrument Rating Airman Certification Standards", order: 6),
            ChecklistItem(title: "8. PAR or ASR Approach (if available)", notes: "Alt ±100 ft until FAF then +100/-0 ft, airspeed ±10 kts, heading ±5°, ≤1/2 CDI", order: 7),
            ChecklistItem(title: "9. Procedure Turn Course Reversal", notes: "Alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2 CDI", order: 8),
            ChecklistItem(title: "10. Terminal Area Arrival Procedure", notes: "Conforms to published procedure, alt ±100 ft, airspeed ±10 kts, heading ±10°, ≤ 1/2 CDI", order: 9),
            ChecklistItem(title: "11. Lost Communications", notes: "Instrument Rating Airman Certification Standards", order: 10),
            ChecklistItem(title: "12. Missed Approach", notes: "Instrument Rating Airman Certification Standards", order: 11),
            ChecklistItem(title: "13. Landing from a Straight-in or Circling Approach", notes: "Instrument Rating Airman Certification Standards", order: 12),
            ChecklistItem(title: "14. Postflight Checking Instruments and Equipment", notes: "Instrument Rating Airman Certification Standards", order: 13),
        ]
    )
    
    static let i4L3LongIFRCrossCountryProgressCheck = ChecklistTemplate(
        name: "I4-L3: Long IFR Cross Country Progress Check",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i4_l3_long_ifr_cross_country_progress_check",
        items: [
            ChecklistItem(title: "1. Single-Pilot Resource Management", notes: "Instrument Rating Airman Certification Standards", order: 0),
            ChecklistItem(title: "2. Aeronautical Decision Making", notes: "Instrument Rating Airman Certification Standards", order: 1),
            ChecklistItem(title: "3. Risk Management", notes: "Instrument Rating Airman Certification Standards", order: 2),
            ChecklistItem(title: "4. Task Management", notes: "Instrument Rating Airman Certification Standards", order: 3),
            ChecklistItem(title: "5. Situational Awareness", notes: "Instrument Rating Airman Certification Standards", order: 4),
            ChecklistItem(title: "6. Controlled Flight into Terrain Awareness", notes: "Instrument Rating Airman Certification Standards", order: 5),
            ChecklistItem(title: "7. Automation Management", notes: "Instrument Rating Airman Certification Standards", order: 6),
            ChecklistItem(title: "8. Required ATC Reports", notes: "Review all required ATC reports", order: 7),
            ChecklistItem(title: "9. Cross-Country Flight Planning", notes: "Instrument Rating Airman Certification Standards", order: 8),
            ChecklistItem(title: "10. Instrument Cockpit Check", notes: "Instrument Rating Airman Certification Standards", order: 9),
            ChecklistItem(title: "11. ATC Clearances", notes: "Instrument Rating Airman Certification Standards", order: 10),
            ChecklistItem(title: "12. Compliance with Departure, En Route, and Arrival Procedures and Clearances", notes: "Instrument Rating Airman Certification Standards", order: 11),
            ChecklistItem(title: "13. Lost Communications", notes: "Instrument Rating Airman Certification Standards", order: 12),
            ChecklistItem(title: "14. Autopilot Use", notes: "Uses autopilot appropriately; instructor simulated failure to ensure demonstrates manual skill", order: 13),
            ChecklistItem(title: "15. Instrument approaches (3 approaches, each a different type nav system)", notes: "Instrument Rating Airman Certification Standards", order: 14),
            ChecklistItem(title: "16. Missed Approach", notes: "Instrument Rating Airman Certification Standards", order: 15),
            ChecklistItem(title: "17. Landing from a Straight-in or Circling Approach", notes: "Instrument Rating Airman Certification Standards", order: 16),
            ChecklistItem(title: "18. Runway Incursion Avoidance", notes: "Studies airport diagram, anticipates post-landing taxi, aware of hot spots", order: 17),
            ChecklistItem(title: "19. Postflight Checking Instruments and Equipment", notes: "Instrument Rating Airman Certification Standards", order: 18),
        ]
    )
    
    // Phase 5: Becoming Instrument Rated
    static let i5L1AirmanCertificationStandards = ChecklistTemplate(
        name: "I5-L1: Airman Certification Standards",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i5_l1_airman_certification_standards",
        items: [
            ChecklistItem(title: "1. Airman Certification Standards", notes: "Introduction, Appendices, Areas of Operation & Tasks", order: 0),
            ChecklistItem(title: "2. Positive Aircraft Control", notes: "Instrument Rating Airman Certification Standards", order: 1),
            ChecklistItem(title: "3. Positive Exchange of Flight Controls", notes: "Instrument Rating Airman Certification Standards", order: 2),
            ChecklistItem(title: "4. Stall/Spin Awareness", notes: "Instrument Rating Airman Certification Standards", order: 3),
            ChecklistItem(title: "5. Collision Avoidance", notes: "Instrument Rating Airman Certification Standards", order: 4),
            ChecklistItem(title: "6. Wake Turbulence Avoidance", notes: "Instrument Rating Airman Certification Standards", order: 5),
            ChecklistItem(title: "7. Land and Hold Short Operations (LAHSO)", notes: "Instrument Rating Airman Certification Standards", order: 6),
            ChecklistItem(title: "8. Runway Incursion Avoidance", notes: "Instrument Rating Airman Certification Standards", order: 7),
            ChecklistItem(title: "9. Checklist Usage", notes: "Instrument Rating Airman Certification Standards", order: 8),
            ChecklistItem(title: "10. Icing Condition Operational Hazards, Anti-icing and Deicing Equipment", notes: "Instrument Rating Airman Certification Standards", order: 9),
            ChecklistItem(title: "11. Single-Pilot Resource Management", notes: "Instrument Rating Airman Certification Standards", order: 10),
            ChecklistItem(title: "12. Aeronautical Decision Making", notes: "Instrument Rating Airman Certification Standards", order: 11),
            ChecklistItem(title: "13. Risk Management", notes: "Instrument Rating Airman Certification Standards", order: 12),
            ChecklistItem(title: "14. Task Management", notes: "Instrument Rating Airman Certification Standards", order: 13),
            ChecklistItem(title: "15. Situational Awareness", notes: "Instrument Rating Airman Certification Standards", order: 14),
            ChecklistItem(title: "16. Controlled Flight into Terrain Awareness", notes: "Instrument Rating Airman Certification Standards", order: 15),
            ChecklistItem(title: "17. Automation Management", notes: "Instrument Rating Airman Certification Standards", order: 16),
            ChecklistItem(title: "18. Pilot Qualifications", notes: "Instrument Rating Airman Certification Standards", order: 17),
            ChecklistItem(title: "19. Weather Information", notes: "Instrument Rating Airman Certification Standards", order: 18),
            ChecklistItem(title: "20. Cross-Country Flight Planning", notes: "Instrument Rating Airman Certification Standards", order: 19),
            ChecklistItem(title: "21. Aircraft Systems Related to IFR Operations", notes: "Instrument Rating Airman Certification Standards", order: 20),
            ChecklistItem(title: "22. Aircraft Flight Instruments and Navigation Equipment", notes: "Instrument Rating Airman Certification Standards", order: 21),
            ChecklistItem(title: "23. Instrument Cockpit Check", notes: "Instrument Rating Airman Certification Standards", order: 22),
            ChecklistItem(title: "24. Air Traffic Control Clearances", notes: "Instrument Rating Airman Certification Standards", order: 23),
        ]
    )
    
    static let i5L2HoningTheEdge = ChecklistTemplate(
        name: "I5-L2: Honing the Edge",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i5_l2_honing_the_edge",
        items: [
            ChecklistItem(title: "25. Compliance with Departure, En Route, and Arrival Procedures and Clearances", notes: "Instrument Rating Airman Certification Standards", order: 0),
            ChecklistItem(title: "26. Holding Procedures", notes: "Instrument Rating Airman Certification Standards", order: 1),
            ChecklistItem(title: "27. Basic Instrument Flight Maneuvers", notes: "Instrument Rating Airman Certification Standards", order: 2),
            ChecklistItem(title: "28. Recovery from Unusual Flight Attitudes", notes: "Instrument Rating Airman Certification Standards", order: 3),
            ChecklistItem(title: "29. Intercepting and Tracking Navigational Systems and DME Arcs", notes: "Instrument Rating Airman Certification Standards", order: 4),
            ChecklistItem(title: "30. Nonprecision Approach", notes: "Instrument Rating Airman Certification Standards", order: 5),
            ChecklistItem(title: "31. Precision Approach", notes: "Instrument Rating Airman Certification Standards", order: 6),
            ChecklistItem(title: "32. Missed Approach", notes: "Instrument Rating Airman Certification Standards", order: 7),
            ChecklistItem(title: "33. Circling Approach", notes: "Instrument Rating Airman Certification Standards", order: 8),
            ChecklistItem(title: "34. Landing from a Straight-In or Circling Approach", notes: "Instrument Rating Airman Certification Standards", order: 9),
            ChecklistItem(title: "35. Loss of Communications", notes: "Instrument Rating Airman Certification Standards", order: 10),
            ChecklistItem(title: "36. Approach with Loss of Primary Flight Instrument Indicators", notes: "Instrument Rating Airman Certification Standards", order: 11),
            ChecklistItem(title: "37. Postflight Checking Instruments and Equipment", notes: "Instrument Rating Airman Certification Standards", order: 12),
        ]
    )
    
    static let i5L3PreCheckrideProgressCheck = ChecklistTemplate(
        name: "I5-L3: Pre-Checkride Progress Check",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i5_l3_pre_checkride_progress_check",
        items: [
            ChecklistItem(title: "1. Airman Certification Standards", notes: "Introduction, Appendices, Areas of Operation & Tasks", order: 0),
            ChecklistItem(title: "2. Positive Aircraft Control", notes: "Instrument Rating Airman Certification Standards", order: 1),
            ChecklistItem(title: "3. Positive Exchange of Flight Controls", notes: "Instrument Rating Airman Certification Standards", order: 2),
            ChecklistItem(title: "4. Stall/Spin Awareness", notes: "Instrument Rating Airman Certification Standards", order: 3),
            ChecklistItem(title: "5. Collision Avoidance", notes: "Instrument Rating Airman Certification Standards", order: 4),
            ChecklistItem(title: "6. Wake Turbulence Avoidance", notes: "Instrument Rating Airman Certification Standards", order: 5),
            ChecklistItem(title: "7. Land and Hold Short Operations (LAHSO)", notes: "Instrument Rating Airman Certification Standards", order: 6),
            ChecklistItem(title: "8. Runway Incursion Avoidance", notes: "Instrument Rating Airman Certification Standards", order: 7),
            ChecklistItem(title: "9. Checklist Usage", notes: "Instrument Rating Airman Certification Standards", order: 8),
            ChecklistItem(title: "10. Icing Condition Operational Hazards, Anti-icing and Deicing Equipment", notes: "Instrument Rating Airman Certification Standards", order: 9),
            ChecklistItem(title: "11. Single-Pilot Resource Management", notes: "Instrument Rating Airman Certification Standards", order: 10),
            ChecklistItem(title: "12. Aeronautical Decision Making", notes: "Instrument Rating Airman Certification Standards", order: 11),
            ChecklistItem(title: "13. Risk Management", notes: "Instrument Rating Airman Certification Standards", order: 12),
            ChecklistItem(title: "14. Task Management", notes: "Instrument Rating Airman Certification Standards", order: 13),
            ChecklistItem(title: "15. Situational Awareness", notes: "Instrument Rating Airman Certification Standards", order: 14),
            ChecklistItem(title: "16. Controlled Flight into Terrain Awareness", notes: "Instrument Rating Airman Certification Standards", order: 15),
            ChecklistItem(title: "17. Automation Management", notes: "Instrument Rating Airman Certification Standards", order: 16),
            ChecklistItem(title: "18. Pilot Qualifications", notes: "Instrument Rating Airman Certification Standards", order: 17),
            ChecklistItem(title: "19. Weather Information", notes: "Instrument Rating Airman Certification Standards", order: 18),
            ChecklistItem(title: "20. Cross-Country Flight Planning", notes: "Instrument Rating Airman Certification Standards", order: 19),
            ChecklistItem(title: "21. Aircraft Systems Related to IFR Operations", notes: "Instrument Rating Airman Certification Standards", order: 20),
            ChecklistItem(title: "22. Aircraft Flight Instruments and Navigation Equipment", notes: "Instrument Rating Airman Certification Standards", order: 21),
            ChecklistItem(title: "23. Instrument Cockpit Check", notes: "Instrument Rating Airman Certification Standards", order: 22),
            ChecklistItem(title: "24. Air Traffic Control Clearances", notes: "Instrument Rating Airman Certification Standards", order: 23),
            ChecklistItem(title: "25. Compliance with Departure, En Route, and Arrival Procedures and Clearances", notes: "Instrument Rating Airman Certification Standards", order: 24),
            ChecklistItem(title: "26. Holding Procedures", notes: "Instrument Rating Airman Certification Standards", order: 25),
            ChecklistItem(title: "27. Basic Instrument Flight Maneuvers", notes: "Instrument Rating Airman Certification Standards", order: 26),
            ChecklistItem(title: "28. Recovery from Unusual Flight Attitudes", notes: "Instrument Rating Airman Certification Standards", order: 27),
            ChecklistItem(title: "29. Intercepting and Tracking Navigational Systems and DME Arcs", notes: "Instrument Rating Airman Certification Standards", order: 28),
            ChecklistItem(title: "30. Nonprecision Approach", notes: "Instrument Rating Airman Certification Standards", order: 29),
            ChecklistItem(title: "31. Precision Approach", notes: "Instrument Rating Airman Certification Standards", order: 30),
            ChecklistItem(title: "32. Missed Approach", notes: "Instrument Rating Airman Certification Standards", order: 31),
            ChecklistItem(title: "33. Circling Approach", notes: "Instrument Rating Airman Certification Standards", order: 32),
            ChecklistItem(title: "34. Landing from a Straight-In or Circling Approach", notes: "Instrument Rating Airman Certification Standards", order: 33),
            ChecklistItem(title: "35. Loss of Communications", notes: "Instrument Rating Airman Certification Standards", order: 34),
            ChecklistItem(title: "36. Approach with Loss of Primary Flight Instrument Indicators", notes: "Instrument Rating Airman Certification Standards", order: 35),
            ChecklistItem(title: "37. Postflight Checking Instruments and Equipment", notes: "Instrument Rating Airman Certification Standards", order: 36),
        ]
    )
    
    static let i5L4Endorsements = ChecklistTemplate(
        name: "I5-L4: Endorsements",
        category: "Instrument",
        phase: "Instrument Rating",
        templateIdentifier: "default_i5_l4_endorsements",
        items: [
            ChecklistItem(title: "1. Instrument Rating Knowledge Test Endorsement", notes: "I certify that [Student Name] has received the required training of §61.65 and has satisfactorily completed the required knowledge test review. I have determined that [Student Name] is prepared for the knowledge test.", order: 0),
            ChecklistItem(title: "2. Instrument Rating Practical Test Endorsement", notes: "I certify that [Student Name] has received the required training of §61.65 and has satisfactorily completed the required practical test review. I have determined that [Student Name] is prepared for the practical test.", order: 1),
            ChecklistItem(title: "3. Instrument Rating Training Endorsement", notes: "I certify that [Student Name] has received the required training of §61.65 and has satisfactorily completed the required instrument training. I have determined that [Student Name] is prepared for instrument operations.", order: 2),
            ChecklistItem(title: "4. Cross-Country Flight Training Endorsement", notes: "I certify that [Student Name] has received the required training of §61.65(c) and has satisfactorily completed the required cross-country flight training. I have determined that [Student Name] is prepared for cross-country instrument operations.", order: 3),
        ]
    )
    
    // MARK: - Commercial Rating Templates
    
    // Stage 1: Learning Professional Cross-Country and Night Procedures
    static let c1L1DualCrossCountry = ChecklistTemplate(
        name: "C1-L1: Dual Cross-Country",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l1_dual_cross_country",
        items: [
            ChecklistItem(title: "1. Cross-Country Flight Planning", notes: "Professional cross-country planning techniques", order: 0),
            ChecklistItem(title: "2. Preflight Inspection/Checklist Use", notes: "Comprehensive preflight inspection procedures", order: 1),
            ChecklistItem(title: "3. Location of Fire Extinguisher", notes: "Identify and verify fire extinguisher location", order: 2),
            ChecklistItem(title: "4. Doors and Safety Belts", notes: "Check doors and safety belt security", order: 3),
            ChecklistItem(title: "5. Engine Starting and Warm-up", notes: "Proper engine starting and warm-up procedures", order: 4),
            ChecklistItem(title: "6. Use of ATIS", notes: "Obtain and use ATIS information", order: 5),
            ChecklistItem(title: "7. Taxiing", notes: "Safe taxiing procedures and communications", order: 6),
            ChecklistItem(title: "8. Before Takeoff Check and Engine Runup", notes: "Complete before takeoff checklist and engine runup", order: 7),
            ChecklistItem(title: "9. Normal and Crosswind Takeoff and Climb", notes: "Execute normal and crosswind takeoffs and climbs", order: 8),
            ChecklistItem(title: "10. Controlled Airports/High Density Airport Operations", notes: "Operate safely at controlled and high density airports", order: 9),
            ChecklistItem(title: "11. Departure", notes: "Execute proper departure procedures", order: 10),
            ChecklistItem(title: "12. Opening/Closing Flight Plans", notes: "Open and close flight plans appropriately", order: 11),
            ChecklistItem(title: "13. Use of Approach and Departure Control", notes: "Communicate with approach and departure control", order: 12),
            ChecklistItem(title: "14. Course Interception", notes: "Intercept and maintain assigned courses", order: 13),
            ChecklistItem(title: "15. Pilotage/Dead Reckoning", notes: "Navigate using pilotage and dead reckoning", order: 14),
            ChecklistItem(title: "16. Attitude Instrument Flying (IR)", notes: "Maintain aircraft control using instruments only", order: 15),
            ChecklistItem(title: "17. Intercepting and Tracking VOR Courses (IR)", notes: "Intercept and track VOR courses using instruments", order: 16),
            ChecklistItem(title: "18. Intercepting and Tracking ADF/GPS Courses (IR)", notes: "Intercept and track ADF/GPS courses using instruments", order: 17),
            ChecklistItem(title: "19. Power Settings and Mixture Control", notes: "Proper power settings and mixture control", order: 18),
            ChecklistItem(title: "20. Diversion to an Alternate", notes: "Execute diversion procedures to alternate airport", order: 19),
            ChecklistItem(title: "21. Lost Procedures", notes: "Execute lost procedures and navigation recovery", order: 20),
            ChecklistItem(title: "22. Simulated System and Engine Failures", notes: "Handle simulated system and engine failures", order: 21),
            ChecklistItem(title: "23. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and estimated time of arrival", order: 22),
            ChecklistItem(title: "24. Position Fix by Navigation Facilities", notes: "Determine position using navigation facilities", order: 23),
            ChecklistItem(title: "25. Flight on Federal Airways", notes: "Navigate on federal airways", order: 24),
            ChecklistItem(title: "26. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 25),
            ChecklistItem(title: "27. At Least One Landing More Than 100 nm from Departure Airport", notes: "Complete landing at airport >100 nm from departure", order: 26),
            ChecklistItem(title: "28. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 27),
            ChecklistItem(title: "29. Collision Avoidance Procedures", notes: "Maintain collision avoidance awareness", order: 28),
            ChecklistItem(title: "30. Parking and Securing", notes: "Proper parking and aircraft securing procedures", order: 29),
            ChecklistItem(title: "31. Postflight Procedures", notes: "Complete postflight procedures and documentation", order: 30),
        ]
    )
    
    static let c1L2DualLocalNight = ChecklistTemplate(
        name: "C1-L2: Dual Local, Night",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l2_dual_local_night",
        items: [
            ChecklistItem(title: "1. Night Flight", notes: "Understand and apply night flight procedures", order: 0),
            ChecklistItem(title: "2. Normal and Crosswind Takeoffs and Climbs", notes: "Execute night takeoffs and climbs", order: 1),
            ChecklistItem(title: "3. Constant Airspeed Climbs", notes: "Maintain constant airspeed during climbs", order: 2),
            ChecklistItem(title: "4. Constant Airspeed Descents", notes: "Maintain constant airspeed during descents", order: 3),
            ChecklistItem(title: "5. Recovery from Unusual Attitudes (IR)", notes: "Recover from unusual attitudes using instruments only", order: 4),
            ChecklistItem(title: "6. Power Off Stall (approach to landing stall)", notes: "Execute power off stalls with proper recovery", order: 5),
            ChecklistItem(title: "7. Power On Stall (takeoff and departure stall)", notes: "Execute power on stalls with proper recovery", order: 6),
            ChecklistItem(title: "8. Local VFR Navigation", notes: "Navigate locally using VFR procedures", order: 7),
            ChecklistItem(title: "9. Normal Approaches and Landings With/Without Landing Light", notes: "Execute night landings with and without landing light", order: 8),
        ]
    )
    
    static let c1L3PICCrossCountry = ChecklistTemplate(
        name: "C1-L3: PIC Cross-Country",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l3_pic_cross_country",
        items: [
            ChecklistItem(title: "1. Cross-Country Flight Planning", notes: "Plan cross-country flight as PIC", order: 0),
            ChecklistItem(title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection", order: 1),
            ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
            ChecklistItem(title: "4. Normal and Crosswind Takeoff and Climb", notes: "Execute takeoffs and climbs", order: 3),
            ChecklistItem(title: "5. Departure", notes: "Execute departure procedures", order: 4),
            ChecklistItem(title: "6. Opening Flight Plan", notes: "Open flight plan with appropriate facility", order: 5),
            ChecklistItem(title: "7. Radar Services", notes: "Use radar services when available", order: 6),
            ChecklistItem(title: "8. Course Interception", notes: "Intercept and maintain assigned courses", order: 7),
            ChecklistItem(title: "9. Pilotage", notes: "Navigate using pilotage techniques", order: 8),
            ChecklistItem(title: "10. Dead Reckoning", notes: "Navigate using dead reckoning", order: 9),
            ChecklistItem(title: "11. VOR Navigation", notes: "Navigate using VOR systems", order: 10),
            ChecklistItem(title: "12. ADF Navigation (if aircraft equipped)", notes: "Navigate using ADF systems if equipped", order: 11),
            ChecklistItem(title: "13. GPS Navigation (if aircraft equipped)", notes: "Navigate using GPS systems if equipped", order: 12),
            ChecklistItem(title: "14. Power Settings and Mixture Control", notes: "Proper power and mixture management", order: 13),
            ChecklistItem(title: "15. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and ETA", order: 14),
            ChecklistItem(title: "16. Position Fix by Navigation Facilities", notes: "Determine position using navigation aids", order: 15),
            ChecklistItem(title: "17. Flight on Federal Airways", notes: "Navigate on federal airways", order: 16),
            ChecklistItem(title: "18. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 17),
            ChecklistItem(title: "19. At Least One Landing More Than 100 nm from Departure Airport", notes: "Complete landing at airport >100 nm from departure", order: 18),
            ChecklistItem(title: "20. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 19),
            ChecklistItem(title: "21. Collision Avoidance Procedures", notes: "Maintain collision avoidance awareness", order: 20),
            ChecklistItem(title: "22. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 21),
            ChecklistItem(title: "23. Parking and Securing", notes: "Proper parking and aircraft securing", order: 22),
        ]
    )
    
    static let c1L4DualCrossCountryNight = ChecklistTemplate(
        name: "C1-L4: Dual Cross-Country, Night",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l4_dual_cross_country_night",
        items: [
            ChecklistItem(title: "1. Cross-Country Flight Planning", notes: "Plan night cross-country flight", order: 0),
            ChecklistItem(title: "2. Pilotage", notes: "Navigate using pilotage at night", order: 1),
            ChecklistItem(title: "3. Dead Reckoning", notes: "Navigate using dead reckoning at night", order: 2),
            ChecklistItem(title: "4. Attitude Instrument Flying (IR)", notes: "Maintain aircraft control using instruments only", order: 3),
            ChecklistItem(title: "5. Intercepting and Tracking Navigation Systems (IR)", notes: "Intercept and track navigation systems using instruments", order: 4),
            ChecklistItem(title: "6. Emergency Operations", notes: "Handle emergency operations at night", order: 5),
            ChecklistItem(title: "7. Go-Around", notes: "Execute go-around procedures at night", order: 6),
            ChecklistItem(title: "8. Use of Unfamiliar Airports", notes: "Operate at unfamiliar airports at night", order: 7),
            ChecklistItem(title: "9. Collision Avoidance Precautions", notes: "Maintain collision avoidance at night", order: 8),
            ChecklistItem(title: "10. Diversion to Alternate", notes: "Execute diversion to alternate airport at night", order: 9),
            ChecklistItem(title: "11. Lost Procedures", notes: "Execute lost procedures at night", order: 10),
            ChecklistItem(title: "12. Normal Approaches and Landings With/Without Landing Light", notes: "Execute night landings with and without landing light", order: 11),
        ]
    )
    
    static let c1L5SoloLocalNight = ChecklistTemplate(
        name: "C1-L5: Solo Local, Night",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l5_solo_local_night",
        items: [
            ChecklistItem(title: "1. Normal and Crosswind Takeoffs and Climbs", notes: "Execute solo night takeoffs and climbs", order: 0),
            ChecklistItem(title: "2. Constant Airspeed Climbs", notes: "Maintain constant airspeed during climbs", order: 1),
            ChecklistItem(title: "3. Constant Airspeed Descents", notes: "Maintain constant airspeed during descents", order: 2),
            ChecklistItem(title: "4. Power Off Stall (approach to landing stall)", notes: "Execute power off stalls with proper recovery", order: 3),
            ChecklistItem(title: "5. Power On Stall (takeoff and departure stall)", notes: "Execute power on stalls with proper recovery", order: 4),
            ChecklistItem(title: "6. Local VFR Navigation", notes: "Navigate locally using VFR procedures at night", order: 5),
            ChecklistItem(title: "7. Normal Approaches and Landings With Landing Light", notes: "Execute night landings with landing light", order: 6),
        ]
    )
    
    static let c1L6PICCrossCountry = ChecklistTemplate(
        name: "C1-L6: PIC Cross-Country",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l6_pic_cross_country",
        items: [
            ChecklistItem(title: "1. Cross-Country Flight Planning", notes: "Plan cross-country flight as PIC", order: 0),
            ChecklistItem(title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection", order: 1),
            ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
            ChecklistItem(title: "4. Normal and Crosswind Takeoff and Climb", notes: "Execute takeoffs and climbs", order: 3),
            ChecklistItem(title: "5. Departure", notes: "Execute departure procedures", order: 4),
            ChecklistItem(title: "6. Opening Flight Plan", notes: "Open flight plan with appropriate facility", order: 5),
            ChecklistItem(title: "7. Radar Services", notes: "Use radar services when available", order: 6),
            ChecklistItem(title: "8. Course Interception", notes: "Intercept and maintain assigned courses", order: 7),
            ChecklistItem(title: "9. Pilotage", notes: "Navigate using pilotage techniques", order: 8),
            ChecklistItem(title: "10. Dead Reckoning", notes: "Navigate using dead reckoning", order: 9),
            ChecklistItem(title: "11. VOR Navigation", notes: "Navigate using VOR systems", order: 10),
            ChecklistItem(title: "12. ADF Navigation (if aircraft equipped)", notes: "Navigate using ADF systems if equipped", order: 11),
            ChecklistItem(title: "13. GPS Navigation (if aircraft equipped)", notes: "Navigate using GPS systems if equipped", order: 12),
            ChecklistItem(title: "14. Power Settings and Mixture Control", notes: "Proper power and mixture management", order: 13),
            ChecklistItem(title: "15. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and ETA", order: 14),
            ChecklistItem(title: "16. Position Fix by Navigation Facilities", notes: "Determine position using navigation aids", order: 15),
            ChecklistItem(title: "17. Flight on Federal Airways", notes: "Navigate on federal airways", order: 16),
            ChecklistItem(title: "18. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 17),
            ChecklistItem(title: "19. At Least One Landing More Than 100 nm from Departure Airport", notes: "Complete landing at airport >100 nm from departure", order: 18),
            ChecklistItem(title: "20. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 19),
            ChecklistItem(title: "21. Collision Avoidance Procedures", notes: "Maintain collision avoidance awareness", order: 20),
            ChecklistItem(title: "22. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 21),
            ChecklistItem(title: "23. Parking and Securing", notes: "Proper parking and aircraft securing", order: 22),
        ]
    )
    
    static let c1L7SoloLocalNight = ChecklistTemplate(
        name: "C1-L7: Solo Local, Night",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l7_solo_local_night",
        items: [
            ChecklistItem(title: "1. Normal and Crosswind Takeoffs and Climbs", notes: "Execute solo night takeoffs and climbs", order: 0),
            ChecklistItem(title: "2. Constant Airspeed Climbs", notes: "Maintain constant airspeed during climbs", order: 1),
            ChecklistItem(title: "3. Constant Airspeed Descents", notes: "Maintain constant airspeed during descents", order: 2),
            ChecklistItem(title: "4. Power Off Stall (approach to landing stall)", notes: "Execute power off stalls with proper recovery", order: 3),
            ChecklistItem(title: "5. Power On Stall (takeoff and departure stall)", notes: "Execute power on stalls with proper recovery", order: 4),
            ChecklistItem(title: "6. Local VFR Navigation", notes: "Navigate locally using VFR procedures at night", order: 5),
            ChecklistItem(title: "7. Normal Approaches and Landings With Landing Light", notes: "Execute night landings with landing light", order: 6),
        ]
    )
    
    static let c1L8SoloCrossCountryNight = ChecklistTemplate(
        name: "C1-L8: Solo Cross-Country, Night",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l8_solo_cross_country_night",
        items: [
            ChecklistItem(title: "1. Cross-Country Flight Planning", notes: "Plan solo night cross-country flight", order: 0),
            ChecklistItem(title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection", order: 1),
            ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
            ChecklistItem(title: "4. Normal and Crosswind Takeoff and Climb", notes: "Execute takeoffs and climbs", order: 3),
            ChecklistItem(title: "5. Departure", notes: "Execute departure procedures", order: 4),
            ChecklistItem(title: "6. Opening Flight Plan", notes: "Open flight plan with appropriate facility", order: 5),
            ChecklistItem(title: "7. Radar Services", notes: "Use radar services when available", order: 6),
            ChecklistItem(title: "8. Course Interception", notes: "Intercept and maintain assigned courses", order: 7),
            ChecklistItem(title: "9. Pilotage", notes: "Navigate using pilotage techniques", order: 8),
            ChecklistItem(title: "10. Dead Reckoning", notes: "Navigate using dead reckoning", order: 9),
            ChecklistItem(title: "11. VOR Navigation", notes: "Navigate using VOR systems", order: 10),
            ChecklistItem(title: "12. ADF Navigation (if aircraft equipped)", notes: "Navigate using ADF systems if equipped", order: 11),
            ChecklistItem(title: "13. GPS Navigation (if aircraft equipped)", notes: "Navigate using GPS systems if equipped", order: 12),
            ChecklistItem(title: "14. Power Settings and Mixture Control", notes: "Proper power and mixture management", order: 13),
            ChecklistItem(title: "15. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and ETA", order: 14),
            ChecklistItem(title: "16. Position Fix by Navigation Facilities", notes: "Determine position using navigation aids", order: 15),
            ChecklistItem(title: "17. Flight on Federal Airways", notes: "Navigate on federal airways", order: 16),
            ChecklistItem(title: "18. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 17),
            ChecklistItem(title: "19. At Least One Leg a Straight-Line Distance More Than 250 nm", notes: "Complete leg >250 nm straight-line distance", order: 18),
            ChecklistItem(title: "20. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 19),
            ChecklistItem(title: "21. Collision Avoidance Procedures", notes: "Maintain collision avoidance awareness", order: 20),
            ChecklistItem(title: "22. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 21),
            ChecklistItem(title: "23. Parking and Securing", notes: "Proper parking and aircraft securing", order: 22),
        ]
    )
    
    static let c1L9PICCrossCountry = ChecklistTemplate(
        name: "C1-L9: PIC Cross-Country",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l9_pic_cross_country",
        items: [
            ChecklistItem(title: "1. Cross-Country Flight Planning", notes: "Plan cross-country flight as PIC", order: 0),
            ChecklistItem(title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection", order: 1),
            ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
            ChecklistItem(title: "4. Normal and Crosswind Takeoff and Climb", notes: "Execute takeoffs and climbs", order: 3),
            ChecklistItem(title: "5. Departure", notes: "Execute departure procedures", order: 4),
            ChecklistItem(title: "6. Opening Flight Plan", notes: "Open flight plan with appropriate facility", order: 5),
            ChecklistItem(title: "7. Radar Services", notes: "Use radar services when available", order: 6),
            ChecklistItem(title: "8. Course Interception", notes: "Intercept and maintain assigned courses", order: 7),
            ChecklistItem(title: "9. Pilotage", notes: "Navigate using pilotage techniques", order: 8),
            ChecklistItem(title: "10. Dead Reckoning", notes: "Navigate using dead reckoning", order: 9),
            ChecklistItem(title: "11. VOR Navigation", notes: "Navigate using VOR systems", order: 10),
            ChecklistItem(title: "12. ADF Navigation (if aircraft equipped)", notes: "Navigate using ADF systems if equipped", order: 11),
            ChecklistItem(title: "13. GPS Navigation (if aircraft equipped)", notes: "Navigate using GPS systems if equipped", order: 12),
            ChecklistItem(title: "14. Power Settings and Mixture Control", notes: "Proper power and mixture management", order: 13),
            ChecklistItem(title: "15. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and ETA", order: 14),
            ChecklistItem(title: "16. Position Fix by Navigation Facilities", notes: "Determine position using navigation aids", order: 15),
            ChecklistItem(title: "17. Flight on Federal Airways", notes: "Navigate on federal airways", order: 16),
            ChecklistItem(title: "18. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 17),
            ChecklistItem(title: "19. At Least One Landing More Than 100 nm from Departure Airport", notes: "Complete landing at airport >100 nm from departure", order: 18),
            ChecklistItem(title: "20. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 19),
            ChecklistItem(title: "21. Collision Avoidance Procedures", notes: "Maintain collision avoidance awareness", order: 20),
            ChecklistItem(title: "22. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 21),
            ChecklistItem(title: "23. Parking and Securing", notes: "Proper parking and aircraft securing", order: 22),
        ]
    )
    
    static let c1L10ProgressCheck = ChecklistTemplate(
        name: "C1-L10: Progress Check",
        category: "Commercial",
        phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
        templateIdentifier: "default_c1_l10_progress_check",
        items: [
            ChecklistItem(title: "1. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb", order: 0),
            ChecklistItem(title: "2. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb", order: 1),
            ChecklistItem(title: "3. Short Field Approach and Landing", notes: "Execute short field approach and landing", order: 2),
            ChecklistItem(title: "4. Soft Field Approach and Landing", notes: "Execute soft field approach and landing", order: 3),
            ChecklistItem(title: "5. Power Off 180° Approach and Landing", notes: "Execute power off 180° approach and landing", order: 4),
            ChecklistItem(title: "6. Partial Panel (IR)", notes: "Maintain aircraft control with partial panel", order: 5),
            ChecklistItem(title: "7. Cross-Country Flight Planning", notes: "Plan cross-country flight", order: 6),
            ChecklistItem(title: "8. Pilotage", notes: "Navigate using pilotage techniques", order: 7),
            ChecklistItem(title: "9. Dead Reckoning", notes: "Navigate using dead reckoning", order: 8),
            ChecklistItem(title: "10. Attitude Instrument Flying (IR)", notes: "Maintain aircraft control using instruments only", order: 9),
            ChecklistItem(title: "11. VOR Navigation (IR)", notes: "Navigate using VOR systems with instruments", order: 10),
            ChecklistItem(title: "12. ADF Navigation (IR) (if equipped)", notes: "Navigate using ADF systems with instruments if equipped", order: 11),
            ChecklistItem(title: "13. GPS Navigation (IR) (if equipped)", notes: "Navigate using GPS systems with instruments if equipped", order: 12),
            ChecklistItem(title: "14. Recovery from Unusual Attitudes (IR)", notes: "Recover from unusual attitudes using instruments only", order: 13),
            ChecklistItem(title: "15. Power Settings and Mixture Control", notes: "Proper power and mixture management", order: 14),
            ChecklistItem(title: "16. Diversion to an Alternate", notes: "Execute diversion procedures to alternate airport", order: 15),
            ChecklistItem(title: "17. Lost Procedures", notes: "Execute lost procedures and navigation recovery", order: 16),
            ChecklistItem(title: "18. Simulated System Failures", notes: "Handle simulated system failures", order: 17),
            ChecklistItem(title: "19. Simulated Engine Failure", notes: "Handle simulated engine failure", order: 18),
            ChecklistItem(title: "20. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and estimated time of arrival", order: 19),
            ChecklistItem(title: "21. Position Fix by Navigation Facilities", notes: "Determine position using navigation facilities", order: 20),
            ChecklistItem(title: "22. Flight on Federal Airways", notes: "Navigate on federal airways", order: 21),
            ChecklistItem(title: "23. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 22),
            ChecklistItem(title: "24. At Least One Landing More Than 100 nm from Departure Airport", notes: "Complete landing at airport >100 nm from departure", order: 23),
            ChecklistItem(title: "25. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 24),
            ChecklistItem(title: "26. Collision Avoidance Procedures", notes: "Maintain collision avoidance awareness", order: 25),
            ChecklistItem(title: "27. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 26),
            ChecklistItem(title: "28. Parking and Securing", notes: "Proper parking and aircraft securing", order: 27),
        ]
    )
    
    // Stage 2: Flying Complex Airplanes and Commercial Maneuvers
    static let c2L1DualLocalComplex = ChecklistTemplate(
        name: "C2-L1: Dual Local, Complex Aircraft",
        category: "Commercial",
        phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
        templateIdentifier: "default_c2_l1_dual_local_complex",
        items: [
            ChecklistItem(title: "1. Complex Airplane Performance and Limitations", notes: "Understand complex airplane performance and limitations", order: 0),
            ChecklistItem(title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection of complex aircraft", order: 1),
            ChecklistItem(title: "3. Engine Starting and Taxiing", notes: "Start engine and taxi complex aircraft", order: 2),
            ChecklistItem(title: "4. Before Takeoff Check", notes: "Complete before takeoff checklist", order: 3),
            ChecklistItem(title: "5. Normal and Crosswind Takeoff and Climb", notes: "Execute normal and crosswind takeoffs and climbs", order: 4),
            ChecklistItem(title: "6. Use of Retractable Landing Gear", notes: "Operate retractable landing gear system", order: 5),
            ChecklistItem(title: "7. Climbs and Descents", notes: "Execute climbs and descents in complex aircraft", order: 6),
            ChecklistItem(title: "8. Power Settings and Mixture Leaning", notes: "Proper power settings and mixture leaning", order: 7),
            ChecklistItem(title: "9. Use of Constant Speed Propeller", notes: "Operate constant speed propeller system", order: 8),
            ChecklistItem(title: "10. Maneuvering During Slow Flight", notes: "Maneuver aircraft during slow flight", order: 9),
            ChecklistItem(title: "11. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 10),
            ChecklistItem(title: "12. Parking and Securing", notes: "Proper parking and aircraft securing", order: 11),
        ]
    )
    
    static let c2L2DualLocalComplex = ChecklistTemplate(
        name: "C2-L2: Dual Local, Complex Aircraft",
        category: "Commercial",
        phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
        templateIdentifier: "default_c2_l2_dual_local_complex",
        items: [
            ChecklistItem(title: "1. Approach to Landing Stalls", notes: "Execute approach to landing stalls", order: 0),
            ChecklistItem(title: "2. Power Off Stall (approach to landing stall)", notes: "Execute power off stalls with proper recovery", order: 1),
            ChecklistItem(title: "3. Power On Stall (takeoff and departure stall)", notes: "Execute power on stalls with proper recovery", order: 2),
            ChecklistItem(title: "4. Go-Around", notes: "Execute go-around procedures", order: 3),
            ChecklistItem(title: "5. Straight and Level Altitude Flight (IR)", notes: "Maintain straight and level flight using instruments only", order: 4),
            ChecklistItem(title: "6. Standard Rate Turns (IR)", notes: "Execute standard rate turns using instruments only", order: 5),
            ChecklistItem(title: "7. Climbs and Climbing Turns (IR)", notes: "Execute climbs and climbing turns using instruments only", order: 6),
            ChecklistItem(title: "8. Descents and Descending Turns (IR)", notes: "Execute descents and descending turns using instruments only", order: 7),
            ChecklistItem(title: "9. Recovery from Unusual Attitudes (IR)", notes: "Recover from unusual attitudes using instruments only", order: 8),
            ChecklistItem(title: "10. Maneuvering During Slow Flight (IR)", notes: "Maneuver aircraft during slow flight using instruments only", order: 9),
            ChecklistItem(title: "11. Complex Airplane Performance and Limitations", notes: "Understand complex airplane performance and limitations", order: 10),
            ChecklistItem(title: "12. Preflight Inspection", notes: "Conduct comprehensive preflight inspection of complex aircraft", order: 11),
            ChecklistItem(title: "13. Engine Starting and Taxiing", notes: "Start engine and taxi complex aircraft", order: 12),
            ChecklistItem(title: "14. Before Takeoff Check", notes: "Complete before takeoff checklist", order: 13),
            ChecklistItem(title: "15. Normal and Crosswind Takeoff and Climb", notes: "Execute normal and crosswind takeoffs and climbs", order: 14),
            ChecklistItem(title: "16. Use of Retractable Landing Gear", notes: "Operate retractable landing gear system", order: 15),
            ChecklistItem(title: "17. Climbs and Descents", notes: "Execute climbs and descents in complex aircraft", order: 16),
            ChecklistItem(title: "18. Power Settings and Mixture Leaning", notes: "Proper power settings and mixture leaning", order: 17),
            ChecklistItem(title: "19. Use of Constant Speed Propeller", notes: "Operate constant speed propeller system", order: 18),
            ChecklistItem(title: "20. Maneuvering During Slow Flight", notes: "Maneuver aircraft during slow flight", order: 19),
            ChecklistItem(title: "21. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 20),
            ChecklistItem(title: "22. Parking and Securing", notes: "Proper parking and aircraft securing", order: 21),
        ]
    )
    
    static let c2L3SteepTurns = ChecklistTemplate(
        name: "C2-L3: Steep Turns",
        category: "Commercial",
        phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
        templateIdentifier: "default_c2_l3_steep_turns",
        items: [
            ChecklistItem(title: "1. Steep Turns", notes: "Execute steep turns to commercial standards", order: 0),
            ChecklistItem(title: "2. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 1),
            ChecklistItem(title: "3. Power Off Stall (approach to landing stall)", notes: "Execute power off stalls with proper recovery", order: 2),
            ChecklistItem(title: "4. Power On Stall (takeoff and departure stall)", notes: "Execute power on stalls with proper recovery", order: 3),
            ChecklistItem(title: "5. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb", order: 4),
            ChecklistItem(title: "6. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb", order: 5),
            ChecklistItem(title: "7. Short Field Approach and Landing", notes: "Execute short field approach and landing", order: 6),
            ChecklistItem(title: "8. Soft Field Approach and Landing", notes: "Execute soft field approach and landing", order: 7),
            ChecklistItem(title: "9. Power Off 180° Approach and Landing", notes: "Execute power off 180° approach and landing", order: 8),
            ChecklistItem(title: "10. Intercepting and Tracking Navigation Systems Partial Panel (IR)", notes: "Intercept and track navigation systems with partial panel", order: 9),
        ]
    )
    
    static let c2L4Chandelles = ChecklistTemplate(
        name: "C2-L4: Chandelles",
        category: "Commercial",
        phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
        templateIdentifier: "default_c2_l4_chandelles",
        items: [
            ChecklistItem(title: "1. Chandelles", notes: "Execute chandelles to commercial standards", order: 0),
            ChecklistItem(title: "2. Steep Turns", notes: "Execute steep turns to commercial standards", order: 1),
            ChecklistItem(title: "3. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 2),
            ChecklistItem(title: "4. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb", order: 3),
            ChecklistItem(title: "5. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb", order: 4),
            ChecklistItem(title: "6. Short Field Approach and Landing", notes: "Execute short field approach and landing", order: 5),
            ChecklistItem(title: "7. Soft Field Approach and Landing", notes: "Execute soft field approach and landing", order: 6),
            ChecklistItem(title: "8. Power Off 180° Approach and Landing", notes: "Execute power off 180° approach and landing", order: 7),
            ChecklistItem(title: "9. Intercepting and Tracking Navigation Systems (IR)", notes: "Intercept and track navigation systems using instruments", order: 8),
        ]
    )
    
    static let c2L5LazyEights = ChecklistTemplate(
        name: "C2-L5: Lazy Eights",
        category: "Commercial",
        phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
        templateIdentifier: "default_c2_l5_lazy_eights",
        items: [
            ChecklistItem(title: "1. Lazy Eights", notes: "Execute lazy eights to commercial standards", order: 0),
            ChecklistItem(title: "2. Chandelles", notes: "Execute chandelles to commercial standards", order: 1),
            ChecklistItem(title: "3. Steep Turns", notes: "Execute steep turns to commercial standards", order: 2),
            ChecklistItem(title: "4. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 3),
            ChecklistItem(title: "5. Intercepting and Tracking Navigation Systems (IR)", notes: "Intercept and track navigation systems using instruments", order: 4),
            ChecklistItem(title: "6. Partial Panel (IR)", notes: "Maintain aircraft control with partial panel", order: 5),
            ChecklistItem(title: "7. Recovery from Unusual Attitudes (IR)", notes: "Recover from unusual attitudes using instruments only", order: 6),
        ]
    )
    
    static let c2L6EightsOnPylons = ChecklistTemplate(
        name: "C2-L6: Eights On Pylons",
        category: "Commercial",
        phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
        templateIdentifier: "default_c2_l6_eights_on_pylons",
        items: [
            ChecklistItem(title: "1. Eights On Pylons", notes: "Execute eights on pylons to commercial standards", order: 0),
            ChecklistItem(title: "2. Chandelles", notes: "Execute chandelles to commercial standards", order: 1),
            ChecklistItem(title: "3. Steep Turns", notes: "Execute steep turns to commercial standards", order: 2),
            ChecklistItem(title: "4. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 3),
            ChecklistItem(title: "5. Lazy Eights", notes: "Execute lazy eights to commercial standards", order: 4),
            ChecklistItem(title: "6. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb", order: 5),
            ChecklistItem(title: "7. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb", order: 6),
            ChecklistItem(title: "8. Short Field Approach and Landing", notes: "Execute short field approach and landing", order: 7),
            ChecklistItem(title: "9. Soft Field Approach and Landing", notes: "Execute soft field approach and landing", order: 8),
            ChecklistItem(title: "10. Power Off 180° Approach and Landing", notes: "Execute power off 180° approach and landing", order: 9),
            ChecklistItem(title: "11. Attitude Instrument Flying (IR)", notes: "Maintain aircraft control using instruments only", order: 10),
            ChecklistItem(title: "12. Intercepting and Tracking Navigation Systems Partial Panel (IR)", notes: "Intercept and track navigation systems with partial panel", order: 11),
            ChecklistItem(title: "13. Recovery from Unusual Attitudes (IR)", notes: "Recover from unusual attitudes using instruments only", order: 12),
        ]
    )
    
    // Stage 3: Preparing for Commercial Pilot Check Ride
    static let c3L1DualLocal = ChecklistTemplate(
        name: "C3-L1: Dual Local",
        category: "Commercial",
        phase: "Stage 3: Preparing for Commercial Pilot Check Ride",
        templateIdentifier: "default_c3_l1_dual_local",
        items: [
            ChecklistItem(title: "1. Chandelles", notes: "Execute chandelles to commercial standards", order: 0),
            ChecklistItem(title: "2. Steep Turns", notes: "Execute steep turns to commercial standards", order: 1),
            ChecklistItem(title: "3. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 2),
            ChecklistItem(title: "4. Lazy Eights", notes: "Execute lazy eights to commercial standards", order: 3),
            ChecklistItem(title: "5. Eights On Pylons", notes: "Execute eights on pylons to commercial standards", order: 4),
            ChecklistItem(title: "6. Power Off Stall (approach to landing stall)", notes: "Execute power off stalls with proper recovery", order: 5),
            ChecklistItem(title: "7. Power On Stall (takeoff and departure stall)", notes: "Execute power on stalls with proper recovery", order: 6),
            ChecklistItem(title: "8. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb", order: 7),
            ChecklistItem(title: "9. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb", order: 8),
            ChecklistItem(title: "10. Short Field Approach and Landing", notes: "Execute short field approach and landing", order: 9),
            ChecklistItem(title: "11. Soft Field Approach and Landing", notes: "Execute soft field approach and landing", order: 10),
            ChecklistItem(title: "12. Power Off 180° Approach and Landing", notes: "Execute power off 180° approach and landing", order: 11),
            ChecklistItem(title: "13. Intercepting and Tracking Navigation Systems (IR)", notes: "Intercept and track navigation systems using instruments", order: 12),
            ChecklistItem(title: "14. Partial Panel (IR)", notes: "Maintain aircraft control with partial panel", order: 13),
            ChecklistItem(title: "15. Recovery from Unusual Attitudes (IR)", notes: "Recover from unusual attitudes using instruments only", order: 14),
        ]
    )
    
    static let c3L2FinalProgressCheck = ChecklistTemplate(
        name: "C3-L2: Final Progress Check",
        category: "Commercial",
        phase: "Stage 3: Preparing for Commercial Pilot Check Ride",
        templateIdentifier: "default_c3_l2_final_progress_check",
        items: [
            ChecklistItem(title: "1. Cross-Country Flight Planning", notes: "Plan cross-country flight to commercial standards", order: 0),
            ChecklistItem(title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection", order: 1),
            ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
            ChecklistItem(title: "4. Doors and Safety Belts", notes: "Check doors and safety belt security", order: 3),
            ChecklistItem(title: "5. Engine Starting and Warm-up", notes: "Proper engine starting and warm-up procedures", order: 4),
            ChecklistItem(title: "6. Use of ATIS", notes: "Obtain and use ATIS information", order: 5),
            ChecklistItem(title: "7. Taxiing", notes: "Safe taxiing procedures and communications", order: 6),
            ChecklistItem(title: "8. Before Takeoff Check and Engine Runup", notes: "Complete before takeoff checklist and engine runup", order: 7),
            ChecklistItem(title: "9. Normal and Crosswind Takeoff and Climb", notes: "Execute normal and crosswind takeoffs and climbs", order: 8),
            ChecklistItem(title: "10. Controlled Airports", notes: "Operate safely at controlled airports", order: 9),
            ChecklistItem(title: "11. Departure", notes: "Execute proper departure procedures", order: 10),
            ChecklistItem(title: "12. Course Interception", notes: "Intercept and maintain assigned courses", order: 11),
            ChecklistItem(title: "13. Pilotage", notes: "Navigate using pilotage techniques", order: 12),
            ChecklistItem(title: "14. Dead Reckoning", notes: "Navigate using dead reckoning", order: 13),
            ChecklistItem(title: "15. VOR Navigation (IR)", notes: "Navigate using VOR systems with instruments", order: 14),
            ChecklistItem(title: "16. ADF Navigation (IR) (if aircraft eq.)", notes: "Navigate using ADF systems with instruments if equipped", order: 15),
            ChecklistItem(title: "17. GPS Navigation (IR) (if aircraft eq.)", notes: "Navigate using GPS systems with instruments if equipped", order: 16),
            ChecklistItem(title: "18. ILS/NDB or VOR Approach (IR)", notes: "Execute ILS/NDB or VOR approach using instruments", order: 17),
            ChecklistItem(title: "19. Partial Panel (IR)", notes: "Maintain aircraft control with partial panel", order: 18),
            ChecklistItem(title: "20. Recovery from Unusual Attitudes (IR)", notes: "Recover from unusual attitudes using instruments only", order: 19),
            ChecklistItem(title: "21. Power Settings and Mixture Control", notes: "Proper power and mixture management", order: 20),
            ChecklistItem(title: "22. Diversion to an Alternate", notes: "Execute diversion procedures to alternate airport", order: 21),
            ChecklistItem(title: "23. Lost Procedures", notes: "Execute lost procedures and navigation recovery", order: 22),
            ChecklistItem(title: "24. Use of Retractable Landing Gear", notes: "Operate retractable landing gear system", order: 23),
            ChecklistItem(title: "25. Simulated System Failures", notes: "Handle simulated system failures", order: 24),
            ChecklistItem(title: "26. Simulated Engine Failure", notes: "Handle simulated engine failure", order: 25),
            ChecklistItem(title: "27. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and estimated time of arrival", order: 26),
            ChecklistItem(title: "28. Position Fix by Navigation Facilities", notes: "Determine position using navigation facilities", order: 27),
            ChecklistItem(title: "29. Flight on Federal Airways", notes: "Navigate on federal airways", order: 28),
            ChecklistItem(title: "30. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 29),
            ChecklistItem(title: "31. Straight and Level Altitude Flight (IR)", notes: "Maintain straight and level flight using instruments only", order: 30),
            ChecklistItem(title: "32. Standard Rate Turns (IR)", notes: "Execute standard rate turns using instruments only", order: 31),
            ChecklistItem(title: "33. Climbs and Climbing Turns (IR)", notes: "Execute climbs and climbing turns using instruments only", order: 32),
            ChecklistItem(title: "34. Descents and Descending Turns (IR)", notes: "Execute descents and descending turns using instruments only", order: 33),
            ChecklistItem(title: "35. Recovery from Unusual Attitudes (IR)", notes: "Recover from unusual attitudes using instruments only", order: 34),
            ChecklistItem(title: "36. Maneuvering During Slow Flight (IR)", notes: "Maneuver aircraft during slow flight using instruments only", order: 35),
            ChecklistItem(title: "37. Power Off Stall (approach to landing stall)", notes: "Execute power off stalls with proper recovery", order: 36),
            ChecklistItem(title: "38. Power On Stall (takeoff and departure stall)", notes: "Execute power on stalls with proper recovery", order: 37),
            ChecklistItem(title: "39. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb", order: 38),
            ChecklistItem(title: "40. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb", order: 39),
            ChecklistItem(title: "41. Short Field Approach and Landing", notes: "Execute short field approach and landing", order: 40),
            ChecklistItem(title: "42. Soft Field Approach and Landing", notes: "Execute soft field approach and landing", order: 41),
            ChecklistItem(title: "43. Power Off 180° Approach and Landing", notes: "Execute power off 180° approach and landing", order: 42),
            ChecklistItem(title: "44. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings", order: 43),
            ChecklistItem(title: "45. Collision Avoidance Procedures", notes: "Maintain collision avoidance awareness", order: 44),
            ChecklistItem(title: "46. Chandelles", notes: "Execute chandelles to commercial standards", order: 45),
            ChecklistItem(title: "47. Steep Turns", notes: "Execute steep turns to commercial standards", order: 46),
            ChecklistItem(title: "48. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 47),
            ChecklistItem(title: "49. Lazy Eights", notes: "Execute lazy eights to commercial standards", order: 48),
            ChecklistItem(title: "50. Eights On Pylons", notes: "Execute eights on pylons to commercial standards", order: 49),
            ChecklistItem(title: "51. Parking and Securing", notes: "Proper parking and aircraft securing", order: 50),
            ChecklistItem(title: "52. Postflight Procedures", notes: "Complete postflight procedures and documentation", order: 51),
        ]
    )
    
    static let c3L3Endorsements = ChecklistTemplate(
        name: "C3-L3: Endorsements",
        category: "Commercial",
        phase: "Stage 3: Preparing for Commercial Pilot Check Ride",
        templateIdentifier: "default_c3_l3_endorsements",
        items: [
            ChecklistItem(title: "1. Commercial Pilot Knowledge Test Endorsement", notes: "I certify that [Student Name] has received the required training of §61.123 and has satisfactorily completed the required knowledge test review. I have determined that [Student Name] is prepared for the knowledge test.", order: 0),
            ChecklistItem(title: "2. Commercial Pilot Practical Test Endorsement", notes: "I certify that [Student Name] has received the required training of §61.123 and has satisfactorily completed the required practical test review. I have determined that [Student Name] is prepared for the practical test.", order: 1),
            ChecklistItem(title: "3. Complex Aircraft Endorsement", notes: "I certify that [Student Name] has received the required training of §61.31(e) and has satisfactorily completed the required complex aircraft training. I have determined that [Student Name] is prepared for complex aircraft operations.", order: 2),
            ChecklistItem(title: "4. High-Performance Aircraft Endorsement", notes: "I certify that [Student Name] has received the required training of §61.31(f) and has satisfactorily completed the required high-performance aircraft training. I have determined that [Student Name] is prepared for high-performance aircraft operations.", order: 3),
            ChecklistItem(title: "5. Tailwheel Endorsement", notes: "I certify that [Student Name] has received the required training of §61.31(i) and has satisfactorily completed the required tailwheel training. I have determined that [Student Name] is prepared for tailwheel operations.", order: 4),
            ChecklistItem(title: "6. High-Altitude Endorsement", notes: "I certify that [Student Name] has received the required training of §61.31(g) and has satisfactorily completed the required high-altitude training. I have determined that [Student Name] is prepared for high-altitude operations.", order: 5),
        ]
    )
}
