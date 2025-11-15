//
//  DefaultTemplatesCPL.swift
//  Right Rudder
//
//  CPL (Commercial Pilot License) default checklist templates
//

import Foundation
import SwiftData

// MARK: - DefaultTemplates + CPL

extension DefaultTemplates {
  // MARK: - Commercial Rating Templates

  // Stage 1: Learning Professional Cross-Country and Night Procedures
  static let c1L1DualCrossCountry = ChecklistTemplate(
    name: "C1-L1: Dual Cross-Country",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l1_dual_cross_country",
    items: [
      ChecklistItem(
        title: "1. Cross-Country Flight Planning",
        notes: "Professional cross-country planning techniques", order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection/Checklist Use",
        notes: "Comprehensive preflight inspection procedures", order: 1),
      ChecklistItem(
        title: "3. Location of Fire Extinguisher",
        notes: "Identify and verify fire extinguisher location", order: 2),
      ChecklistItem(
        title: "4. Doors and Safety Belts", notes: "Check doors and safety belt security", order: 3),
      ChecklistItem(
        title: "5. Engine Starting and Warm-up",
        notes: "Proper engine starting and warm-up procedures", order: 4),
      ChecklistItem(title: "6. Use of ATIS", notes: "Obtain and use ATIS information", order: 5),
      ChecklistItem(
        title: "7. Taxiing", notes: "Safe taxiing procedures and communications", order: 6),
      ChecklistItem(
        title: "8. Before Takeoff Check and Engine Runup",
        notes: "Complete before takeoff checklist and engine runup", order: 7),
      ChecklistItem(
        title: "9. Normal and Crosswind Takeoff and Climb",
        notes: "Execute normal and crosswind takeoffs and climbs", order: 8),
      ChecklistItem(
        title: "10. Controlled Airports/High Density Airport Operations",
        notes: "Operate safely at controlled and high density airports", order: 9),
      ChecklistItem(
        title: "11. Departure", notes: "Execute proper departure procedures", order: 10),
      ChecklistItem(
        title: "12. Opening/Closing Flight Plans",
        notes: "Open and close flight plans appropriately", order: 11),
      ChecklistItem(
        title: "13. Use of Approach and Departure Control",
        notes: "Communicate with approach and departure control", order: 12),
      ChecklistItem(
        title: "14. Course Interception", notes: "Intercept and maintain assigned courses",
        order: 13),
      ChecklistItem(
        title: "15. Pilotage/Dead Reckoning", notes: "Navigate using pilotage and dead reckoning",
        order: 14),
      ChecklistItem(
        title: "16. Attitude Instrument Flying (IR)",
        notes: "Maintain aircraft control using instruments only", order: 15),
      ChecklistItem(
        title: "17. Intercepting and Tracking VOR Courses (IR)",
        notes: "Intercept and track VOR courses using instruments", order: 16),
      ChecklistItem(
        title: "18. Intercepting and Tracking ADF/GPS Courses (IR)",
        notes: "Intercept and track ADF/GPS courses using instruments", order: 17),
      ChecklistItem(
        title: "19. Power Settings and Mixture Control",
        notes: "Proper power settings and mixture control", order: 18),
      ChecklistItem(
        title: "20. Diversion to an Alternate",
        notes: "Execute diversion procedures to alternate airport", order: 19),
      ChecklistItem(
        title: "21. Lost Procedures", notes: "Execute lost procedures and navigation recovery",
        order: 20),
      ChecklistItem(
        title: "22. Simulated System and Engine Failures",
        notes: "Handle simulated system and engine failures", order: 21),
      ChecklistItem(
        title: "23. Estimates of Ground Speed and ETA",
        notes: "Calculate ground speed and estimated time of arrival", order: 22),
      ChecklistItem(
        title: "24. Position Fix by Navigation Facilities",
        notes: "Determine position using navigation facilities", order: 23),
      ChecklistItem(
        title: "25. Flight on Federal Airways", notes: "Navigate on federal airways", order: 24),
      ChecklistItem(
        title: "26. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 25
      ),
      ChecklistItem(
        title: "27. At Least One Landing More Than 100 nm from Departure Airport",
        notes: "Complete landing at airport >100 nm from departure", order: 26),
      ChecklistItem(
        title: "28. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 27),
      ChecklistItem(
        title: "29. Collision Avoidance Procedures",
        notes: "Maintain collision avoidance awareness", order: 28),
      ChecklistItem(
        title: "30. Parking and Securing", notes: "Proper parking and aircraft securing procedures",
        order: 29),
      ChecklistItem(
        title: "31. Postflight Procedures",
        notes: "Complete postflight procedures and documentation", order: 30),
    ]
  )

  static let c1L2DualLocalNight = ChecklistTemplate(
    name: "C1-L2: Dual Local, Night",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l2_dual_local_night",
    items: [
      ChecklistItem(
        title: "1. Night Flight", notes: "Understand and apply night flight procedures", order: 0),
      ChecklistItem(
        title: "2. Normal and Crosswind Takeoffs and Climbs",
        notes: "Execute night takeoffs and climbs", order: 1),
      ChecklistItem(
        title: "3. Constant Airspeed Climbs", notes: "Maintain constant airspeed during climbs",
        order: 2),
      ChecklistItem(
        title: "4. Constant Airspeed Descents", notes: "Maintain constant airspeed during descents",
        order: 3),
      ChecklistItem(
        title: "5. Recovery from Unusual Attitudes (IR)",
        notes: "Recover from unusual attitudes using instruments only", order: 4),
      ChecklistItem(
        title: "6. Power Off Stall (approach to landing stall)",
        notes: "Execute power off stalls with proper recovery", order: 5),
      ChecklistItem(
        title: "7. Power On Stall (takeoff and departure stall)",
        notes: "Execute power on stalls with proper recovery", order: 6),
      ChecklistItem(
        title: "8. Local VFR Navigation", notes: "Navigate locally using VFR procedures", order: 7),
      ChecklistItem(
        title: "9. Normal Approaches and Landings With/Without Landing Light",
        notes: "Execute night landings with and without landing light", order: 8),
    ]
  )

  static let c1L3PICCrossCountry = ChecklistTemplate(
    name: "C1-L3: PIC Cross-Country",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l3_pic_cross_country",
    items: [
      ChecklistItem(
        title: "1. Cross-Country Flight Planning", notes: "Plan cross-country flight as PIC",
        order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection",
        order: 1),
      ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
      ChecklistItem(
        title: "4. Normal and Crosswind Takeoff and Climb", notes: "Execute takeoffs and climbs",
        order: 3),
      ChecklistItem(title: "5. Departure", notes: "Execute departure procedures", order: 4),
      ChecklistItem(
        title: "6. Opening Flight Plan", notes: "Open flight plan with appropriate facility",
        order: 5),
      ChecklistItem(
        title: "7. Radar Services", notes: "Use radar services when available", order: 6),
      ChecklistItem(
        title: "8. Course Interception", notes: "Intercept and maintain assigned courses", order: 7),
      ChecklistItem(title: "9. Pilotage", notes: "Navigate using pilotage techniques", order: 8),
      ChecklistItem(title: "10. Dead Reckoning", notes: "Navigate using dead reckoning", order: 9),
      ChecklistItem(title: "11. VOR Navigation", notes: "Navigate using VOR systems", order: 10),
      ChecklistItem(
        title: "12. ADF Navigation (if aircraft equipped)",
        notes: "Navigate using ADF systems if equipped", order: 11),
      ChecklistItem(
        title: "13. GPS Navigation (if aircraft equipped)",
        notes: "Navigate using GPS systems if equipped", order: 12),
      ChecklistItem(
        title: "14. Power Settings and Mixture Control",
        notes: "Proper power and mixture management", order: 13),
      ChecklistItem(
        title: "15. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and ETA",
        order: 14),
      ChecklistItem(
        title: "16. Position Fix by Navigation Facilities",
        notes: "Determine position using navigation aids", order: 15),
      ChecklistItem(
        title: "17. Flight on Federal Airways", notes: "Navigate on federal airways", order: 16),
      ChecklistItem(
        title: "18. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 17
      ),
      ChecklistItem(
        title: "19. At Least One Landing More Than 100 nm from Departure Airport",
        notes: "Complete landing at airport >100 nm from departure", order: 18),
      ChecklistItem(
        title: "20. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 19),
      ChecklistItem(
        title: "21. Collision Avoidance Procedures",
        notes: "Maintain collision avoidance awareness", order: 20),
      ChecklistItem(
        title: "22. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 21
      ),
      ChecklistItem(
        title: "23. Parking and Securing", notes: "Proper parking and aircraft securing", order: 22),
    ]
  )

  static let c1L4DualCrossCountryNight = ChecklistTemplate(
    name: "C1-L4: Dual Cross-Country, Night",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l4_dual_cross_country_night",
    items: [
      ChecklistItem(
        title: "1. Cross-Country Flight Planning", notes: "Plan night cross-country flight",
        order: 0),
      ChecklistItem(title: "2. Pilotage", notes: "Navigate using pilotage at night", order: 1),
      ChecklistItem(
        title: "3. Dead Reckoning", notes: "Navigate using dead reckoning at night", order: 2),
      ChecklistItem(
        title: "4. Attitude Instrument Flying (IR)",
        notes: "Maintain aircraft control using instruments only", order: 3),
      ChecklistItem(
        title: "5. Intercepting and Tracking Navigation Systems (IR)",
        notes: "Intercept and track navigation systems using instruments", order: 4),
      ChecklistItem(
        title: "6. Emergency Operations", notes: "Handle emergency operations at night", order: 5),
      ChecklistItem(
        title: "7. Go-Around", notes: "Execute go-around procedures at night", order: 6),
      ChecklistItem(
        title: "8. Use of Unfamiliar Airports", notes: "Operate at unfamiliar airports at night",
        order: 7),
      ChecklistItem(
        title: "9. Collision Avoidance Precautions", notes: "Maintain collision avoidance at night",
        order: 8),
      ChecklistItem(
        title: "10. Diversion to Alternate",
        notes: "Execute diversion to alternate airport at night", order: 9),
      ChecklistItem(
        title: "11. Lost Procedures", notes: "Execute lost procedures at night", order: 10),
      ChecklistItem(
        title: "12. Normal Approaches and Landings With/Without Landing Light",
        notes: "Execute night landings with and without landing light", order: 11),
    ]
  )

  static let c1L5SoloLocalNight = ChecklistTemplate(
    name: "C1-L5: Solo Local, Night",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l5_solo_local_night",
    items: [
      ChecklistItem(
        title: "1. Normal and Crosswind Takeoffs and Climbs",
        notes: "Execute solo night takeoffs and climbs", order: 0),
      ChecklistItem(
        title: "2. Constant Airspeed Climbs", notes: "Maintain constant airspeed during climbs",
        order: 1),
      ChecklistItem(
        title: "3. Constant Airspeed Descents", notes: "Maintain constant airspeed during descents",
        order: 2),
      ChecklistItem(
        title: "4. Power Off Stall (approach to landing stall)",
        notes: "Execute power off stalls with proper recovery", order: 3),
      ChecklistItem(
        title: "5. Power On Stall (takeoff and departure stall)",
        notes: "Execute power on stalls with proper recovery", order: 4),
      ChecklistItem(
        title: "6. Local VFR Navigation", notes: "Navigate locally using VFR procedures at night",
        order: 5),
      ChecklistItem(
        title: "7. Normal Approaches and Landings With Landing Light",
        notes: "Execute night landings with landing light", order: 6),
    ]
  )

  static let c1L6PICCrossCountry = ChecklistTemplate(
    name: "C1-L6: PIC Cross-Country",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l6_pic_cross_country",
    items: [
      ChecklistItem(
        title: "1. Cross-Country Flight Planning", notes: "Plan cross-country flight as PIC",
        order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection",
        order: 1),
      ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
      ChecklistItem(
        title: "4. Normal and Crosswind Takeoff and Climb", notes: "Execute takeoffs and climbs",
        order: 3),
      ChecklistItem(title: "5. Departure", notes: "Execute departure procedures", order: 4),
      ChecklistItem(
        title: "6. Opening Flight Plan", notes: "Open flight plan with appropriate facility",
        order: 5),
      ChecklistItem(
        title: "7. Radar Services", notes: "Use radar services when available", order: 6),
      ChecklistItem(
        title: "8. Course Interception", notes: "Intercept and maintain assigned courses", order: 7),
      ChecklistItem(title: "9. Pilotage", notes: "Navigate using pilotage techniques", order: 8),
      ChecklistItem(title: "10. Dead Reckoning", notes: "Navigate using dead reckoning", order: 9),
      ChecklistItem(title: "11. VOR Navigation", notes: "Navigate using VOR systems", order: 10),
      ChecklistItem(
        title: "12. ADF Navigation (if aircraft equipped)",
        notes: "Navigate using ADF systems if equipped", order: 11),
      ChecklistItem(
        title: "13. GPS Navigation (if aircraft equipped)",
        notes: "Navigate using GPS systems if equipped", order: 12),
      ChecklistItem(
        title: "14. Power Settings and Mixture Control",
        notes: "Proper power and mixture management", order: 13),
      ChecklistItem(
        title: "15. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and ETA",
        order: 14),
      ChecklistItem(
        title: "16. Position Fix by Navigation Facilities",
        notes: "Determine position using navigation aids", order: 15),
      ChecklistItem(
        title: "17. Flight on Federal Airways", notes: "Navigate on federal airways", order: 16),
      ChecklistItem(
        title: "18. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 17
      ),
      ChecklistItem(
        title: "19. At Least One Landing More Than 100 nm from Departure Airport",
        notes: "Complete landing at airport >100 nm from departure", order: 18),
      ChecklistItem(
        title: "20. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 19),
      ChecklistItem(
        title: "21. Collision Avoidance Procedures",
        notes: "Maintain collision avoidance awareness", order: 20),
      ChecklistItem(
        title: "22. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 21
      ),
      ChecklistItem(
        title: "23. Parking and Securing", notes: "Proper parking and aircraft securing", order: 22),
    ]
  )

  static let c1L7SoloLocalNight = ChecklistTemplate(
    name: "C1-L7: Solo Local, Night",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l7_solo_local_night",
    items: [
      ChecklistItem(
        title: "1. Normal and Crosswind Takeoffs and Climbs",
        notes: "Execute solo night takeoffs and climbs", order: 0),
      ChecklistItem(
        title: "2. Constant Airspeed Climbs", notes: "Maintain constant airspeed during climbs",
        order: 1),
      ChecklistItem(
        title: "3. Constant Airspeed Descents", notes: "Maintain constant airspeed during descents",
        order: 2),
      ChecklistItem(
        title: "4. Power Off Stall (approach to landing stall)",
        notes: "Execute power off stalls with proper recovery", order: 3),
      ChecklistItem(
        title: "5. Power On Stall (takeoff and departure stall)",
        notes: "Execute power on stalls with proper recovery", order: 4),
      ChecklistItem(
        title: "6. Local VFR Navigation", notes: "Navigate locally using VFR procedures at night",
        order: 5),
      ChecklistItem(
        title: "7. Normal Approaches and Landings With Landing Light",
        notes: "Execute night landings with landing light", order: 6),
    ]
  )

  static let c1L8SoloCrossCountryNight = ChecklistTemplate(
    name: "C1-L8: Solo Cross-Country, Night",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l8_solo_cross_country_night",
    items: [
      ChecklistItem(
        title: "1. Cross-Country Flight Planning", notes: "Plan solo night cross-country flight",
        order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection",
        order: 1),
      ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
      ChecklistItem(
        title: "4. Normal and Crosswind Takeoff and Climb", notes: "Execute takeoffs and climbs",
        order: 3),
      ChecklistItem(title: "5. Departure", notes: "Execute departure procedures", order: 4),
      ChecklistItem(
        title: "6. Opening Flight Plan", notes: "Open flight plan with appropriate facility",
        order: 5),
      ChecklistItem(
        title: "7. Radar Services", notes: "Use radar services when available", order: 6),
      ChecklistItem(
        title: "8. Course Interception", notes: "Intercept and maintain assigned courses", order: 7),
      ChecklistItem(title: "9. Pilotage", notes: "Navigate using pilotage techniques", order: 8),
      ChecklistItem(title: "10. Dead Reckoning", notes: "Navigate using dead reckoning", order: 9),
      ChecklistItem(title: "11. VOR Navigation", notes: "Navigate using VOR systems", order: 10),
      ChecklistItem(
        title: "12. ADF Navigation (if aircraft equipped)",
        notes: "Navigate using ADF systems if equipped", order: 11),
      ChecklistItem(
        title: "13. GPS Navigation (if aircraft equipped)",
        notes: "Navigate using GPS systems if equipped", order: 12),
      ChecklistItem(
        title: "14. Power Settings and Mixture Control",
        notes: "Proper power and mixture management", order: 13),
      ChecklistItem(
        title: "15. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and ETA",
        order: 14),
      ChecklistItem(
        title: "16. Position Fix by Navigation Facilities",
        notes: "Determine position using navigation aids", order: 15),
      ChecklistItem(
        title: "17. Flight on Federal Airways", notes: "Navigate on federal airways", order: 16),
      ChecklistItem(
        title: "18. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 17
      ),
      ChecklistItem(
        title: "19. At Least One Leg a Straight-Line Distance More Than 250 nm",
        notes: "Complete leg >250 nm straight-line distance", order: 18),
      ChecklistItem(
        title: "20. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 19),
      ChecklistItem(
        title: "21. Collision Avoidance Procedures",
        notes: "Maintain collision avoidance awareness", order: 20),
      ChecklistItem(
        title: "22. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 21
      ),
      ChecklistItem(
        title: "23. Parking and Securing", notes: "Proper parking and aircraft securing", order: 22),
    ]
  )

  static let c1L9PICCrossCountry = ChecklistTemplate(
    name: "C1-L9: PIC Cross-Country",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l9_pic_cross_country",
    items: [
      ChecklistItem(
        title: "1. Cross-Country Flight Planning", notes: "Plan cross-country flight as PIC",
        order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection",
        order: 1),
      ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
      ChecklistItem(
        title: "4. Normal and Crosswind Takeoff and Climb", notes: "Execute takeoffs and climbs",
        order: 3),
      ChecklistItem(title: "5. Departure", notes: "Execute departure procedures", order: 4),
      ChecklistItem(
        title: "6. Opening Flight Plan", notes: "Open flight plan with appropriate facility",
        order: 5),
      ChecklistItem(
        title: "7. Radar Services", notes: "Use radar services when available", order: 6),
      ChecklistItem(
        title: "8. Course Interception", notes: "Intercept and maintain assigned courses", order: 7),
      ChecklistItem(title: "9. Pilotage", notes: "Navigate using pilotage techniques", order: 8),
      ChecklistItem(title: "10. Dead Reckoning", notes: "Navigate using dead reckoning", order: 9),
      ChecklistItem(title: "11. VOR Navigation", notes: "Navigate using VOR systems", order: 10),
      ChecklistItem(
        title: "12. ADF Navigation (if aircraft equipped)",
        notes: "Navigate using ADF systems if equipped", order: 11),
      ChecklistItem(
        title: "13. GPS Navigation (if aircraft equipped)",
        notes: "Navigate using GPS systems if equipped", order: 12),
      ChecklistItem(
        title: "14. Power Settings and Mixture Control",
        notes: "Proper power and mixture management", order: 13),
      ChecklistItem(
        title: "15. Estimates of Ground Speed and ETA", notes: "Calculate ground speed and ETA",
        order: 14),
      ChecklistItem(
        title: "16. Position Fix by Navigation Facilities",
        notes: "Determine position using navigation aids", order: 15),
      ChecklistItem(
        title: "17. Flight on Federal Airways", notes: "Navigate on federal airways", order: 16),
      ChecklistItem(
        title: "18. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 17
      ),
      ChecklistItem(
        title: "19. At Least One Landing More Than 100 nm from Departure Airport",
        notes: "Complete landing at airport >100 nm from departure", order: 18),
      ChecklistItem(
        title: "20. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 19),
      ChecklistItem(
        title: "21. Collision Avoidance Procedures",
        notes: "Maintain collision avoidance awareness", order: 20),
      ChecklistItem(
        title: "22. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 21
      ),
      ChecklistItem(
        title: "23. Parking and Securing", notes: "Proper parking and aircraft securing", order: 22),
    ]
  )

  static let c1L10ProgressCheck = ChecklistTemplate(
    name: "C1-L10: Progress Check",
    category: "Commercial",
    phase: "Stage 1: Learning Professional Cross-Country and Night Procedures",
    templateIdentifier: "default_c1_l10_progress_check",
    items: [
      ChecklistItem(
        title: "1. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb",
        order: 0),
      ChecklistItem(
        title: "2. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb",
        order: 1),
      ChecklistItem(
        title: "3. Short Field Approach and Landing",
        notes: "Execute short field approach and landing", order: 2),
      ChecklistItem(
        title: "4. Soft Field Approach and Landing",
        notes: "Execute soft field approach and landing", order: 3),
      ChecklistItem(
        title: "5. Power Off 180° Approach and Landing",
        notes: "Execute power off 180° approach and landing", order: 4),
      ChecklistItem(
        title: "6. Partial Panel (IR)", notes: "Maintain aircraft control with partial panel",
        order: 5),
      ChecklistItem(
        title: "7. Cross-Country Flight Planning", notes: "Plan cross-country flight", order: 6),
      ChecklistItem(title: "8. Pilotage", notes: "Navigate using pilotage techniques", order: 7),
      ChecklistItem(title: "9. Dead Reckoning", notes: "Navigate using dead reckoning", order: 8),
      ChecklistItem(
        title: "10. Attitude Instrument Flying (IR)",
        notes: "Maintain aircraft control using instruments only", order: 9),
      ChecklistItem(
        title: "11. VOR Navigation (IR)", notes: "Navigate using VOR systems with instruments",
        order: 10),
      ChecklistItem(
        title: "12. ADF Navigation (IR) (if equipped)",
        notes: "Navigate using ADF systems with instruments if equipped", order: 11),
      ChecklistItem(
        title: "13. GPS Navigation (IR) (if equipped)",
        notes: "Navigate using GPS systems with instruments if equipped", order: 12),
      ChecklistItem(
        title: "14. Recovery from Unusual Attitudes (IR)",
        notes: "Recover from unusual attitudes using instruments only", order: 13),
      ChecklistItem(
        title: "15. Power Settings and Mixture Control",
        notes: "Proper power and mixture management", order: 14),
      ChecklistItem(
        title: "16. Diversion to an Alternate",
        notes: "Execute diversion procedures to alternate airport", order: 15),
      ChecklistItem(
        title: "17. Lost Procedures", notes: "Execute lost procedures and navigation recovery",
        order: 16),
      ChecklistItem(
        title: "18. Simulated System Failures", notes: "Handle simulated system failures", order: 17
      ),
      ChecklistItem(
        title: "19. Simulated Engine Failure", notes: "Handle simulated engine failure", order: 18),
      ChecklistItem(
        title: "20. Estimates of Ground Speed and ETA",
        notes: "Calculate ground speed and estimated time of arrival", order: 19),
      ChecklistItem(
        title: "21. Position Fix by Navigation Facilities",
        notes: "Determine position using navigation facilities", order: 20),
      ChecklistItem(
        title: "22. Flight on Federal Airways", notes: "Navigate on federal airways", order: 21),
      ChecklistItem(
        title: "23. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 22
      ),
      ChecklistItem(
        title: "24. At Least One Landing More Than 100 nm from Departure Airport",
        notes: "Complete landing at airport >100 nm from departure", order: 23),
      ChecklistItem(
        title: "25. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 24),
      ChecklistItem(
        title: "26. Collision Avoidance Procedures",
        notes: "Maintain collision avoidance awareness", order: 25),
      ChecklistItem(
        title: "27. Closing Your Flight Plan", notes: "Close flight plan upon completion", order: 26
      ),
      ChecklistItem(
        title: "28. Parking and Securing", notes: "Proper parking and aircraft securing", order: 27),
    ]
  )

  // Stage 2: Flying Complex Airplanes and Commercial Maneuvers
  static let c2L1DualLocalComplex = ChecklistTemplate(
    name: "C2-L1: Dual Local, Complex Aircraft",
    category: "Commercial",
    phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
    templateIdentifier: "default_c2_l1_dual_local_complex",
    items: [
      ChecklistItem(
        title: "1. Complex Airplane Performance and Limitations",
        notes: "Understand complex airplane performance and limitations", order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection",
        notes: "Conduct comprehensive preflight inspection of complex aircraft", order: 1),
      ChecklistItem(
        title: "3. Engine Starting and Taxiing", notes: "Start engine and taxi complex aircraft",
        order: 2),
      ChecklistItem(
        title: "4. Before Takeoff Check", notes: "Complete before takeoff checklist", order: 3),
      ChecklistItem(
        title: "5. Normal and Crosswind Takeoff and Climb",
        notes: "Execute normal and crosswind takeoffs and climbs", order: 4),
      ChecklistItem(
        title: "6. Use of Retractable Landing Gear",
        notes: "Operate retractable landing gear system", order: 5),
      ChecklistItem(
        title: "7. Climbs and Descents", notes: "Execute climbs and descents in complex aircraft",
        order: 6),
      ChecklistItem(
        title: "8. Power Settings and Mixture Leaning",
        notes: "Proper power settings and mixture leaning", order: 7),
      ChecklistItem(
        title: "9. Use of Constant Speed Propeller",
        notes: "Operate constant speed propeller system", order: 8),
      ChecklistItem(
        title: "10. Maneuvering During Slow Flight", notes: "Maneuver aircraft during slow flight",
        order: 9),
      ChecklistItem(
        title: "11. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 10),
      ChecklistItem(
        title: "12. Parking and Securing", notes: "Proper parking and aircraft securing", order: 11),
    ]
  )

  static let c2L2DualLocalComplex = ChecklistTemplate(
    name: "C2-L2: Dual Local, Complex Aircraft",
    category: "Commercial",
    phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
    templateIdentifier: "default_c2_l2_dual_local_complex",
    items: [
      ChecklistItem(
        title: "1. Approach to Landing Stalls", notes: "Execute approach to landing stalls",
        order: 0),
      ChecklistItem(
        title: "2. Power Off Stall (approach to landing stall)",
        notes: "Execute power off stalls with proper recovery", order: 1),
      ChecklistItem(
        title: "3. Power On Stall (takeoff and departure stall)",
        notes: "Execute power on stalls with proper recovery", order: 2),
      ChecklistItem(title: "4. Go-Around", notes: "Execute go-around procedures", order: 3),
      ChecklistItem(
        title: "5. Straight and Level Altitude Flight (IR)",
        notes: "Maintain straight and level flight using instruments only", order: 4),
      ChecklistItem(
        title: "6. Standard Rate Turns (IR)",
        notes: "Execute standard rate turns using instruments only", order: 5),
      ChecklistItem(
        title: "7. Climbs and Climbing Turns (IR)",
        notes: "Execute climbs and climbing turns using instruments only", order: 6),
      ChecklistItem(
        title: "8. Descents and Descending Turns (IR)",
        notes: "Execute descents and descending turns using instruments only", order: 7),
      ChecklistItem(
        title: "9. Recovery from Unusual Attitudes (IR)",
        notes: "Recover from unusual attitudes using instruments only", order: 8),
      ChecklistItem(
        title: "10. Maneuvering During Slow Flight (IR)",
        notes: "Maneuver aircraft during slow flight using instruments only", order: 9),
      ChecklistItem(
        title: "11. Complex Airplane Performance and Limitations",
        notes: "Understand complex airplane performance and limitations", order: 10),
      ChecklistItem(
        title: "12. Preflight Inspection",
        notes: "Conduct comprehensive preflight inspection of complex aircraft", order: 11),
      ChecklistItem(
        title: "13. Engine Starting and Taxiing", notes: "Start engine and taxi complex aircraft",
        order: 12),
      ChecklistItem(
        title: "14. Before Takeoff Check", notes: "Complete before takeoff checklist", order: 13),
      ChecklistItem(
        title: "15. Normal and Crosswind Takeoff and Climb",
        notes: "Execute normal and crosswind takeoffs and climbs", order: 14),
      ChecklistItem(
        title: "16. Use of Retractable Landing Gear",
        notes: "Operate retractable landing gear system", order: 15),
      ChecklistItem(
        title: "17. Climbs and Descents", notes: "Execute climbs and descents in complex aircraft",
        order: 16),
      ChecklistItem(
        title: "18. Power Settings and Mixture Leaning",
        notes: "Proper power settings and mixture leaning", order: 17),
      ChecklistItem(
        title: "19. Use of Constant Speed Propeller",
        notes: "Operate constant speed propeller system", order: 18),
      ChecklistItem(
        title: "20. Maneuvering During Slow Flight", notes: "Maneuver aircraft during slow flight",
        order: 19),
      ChecklistItem(
        title: "21. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 20),
      ChecklistItem(
        title: "22. Parking and Securing", notes: "Proper parking and aircraft securing", order: 21),
    ]
  )

  static let c2L3SteepTurns = ChecklistTemplate(
    name: "C2-L3: Steep Turns",
    category: "Commercial",
    phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
    templateIdentifier: "default_c2_l3_steep_turns",
    items: [
      ChecklistItem(
        title: "1. Steep Turns", notes: "Execute steep turns to commercial standards", order: 0),
      ChecklistItem(
        title: "2. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 1),
      ChecklistItem(
        title: "3. Power Off Stall (approach to landing stall)",
        notes: "Execute power off stalls with proper recovery", order: 2),
      ChecklistItem(
        title: "4. Power On Stall (takeoff and departure stall)",
        notes: "Execute power on stalls with proper recovery", order: 3),
      ChecklistItem(
        title: "5. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb",
        order: 4),
      ChecklistItem(
        title: "6. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb",
        order: 5),
      ChecklistItem(
        title: "7. Short Field Approach and Landing",
        notes: "Execute short field approach and landing", order: 6),
      ChecklistItem(
        title: "8. Soft Field Approach and Landing",
        notes: "Execute soft field approach and landing", order: 7),
      ChecklistItem(
        title: "9. Power Off 180° Approach and Landing",
        notes: "Execute power off 180° approach and landing", order: 8),
      ChecklistItem(
        title: "10. Intercepting and Tracking Navigation Systems Partial Panel (IR)",
        notes: "Intercept and track navigation systems with partial panel", order: 9),
    ]
  )

  static let c2L4Chandelles = ChecklistTemplate(
    name: "C2-L4: Chandelles",
    category: "Commercial",
    phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
    templateIdentifier: "default_c2_l4_chandelles",
    items: [
      ChecklistItem(
        title: "1. Chandelles", notes: "Execute chandelles to commercial standards", order: 0),
      ChecklistItem(
        title: "2. Steep Turns", notes: "Execute steep turns to commercial standards", order: 1),
      ChecklistItem(
        title: "3. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 2),
      ChecklistItem(
        title: "4. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb",
        order: 3),
      ChecklistItem(
        title: "5. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb",
        order: 4),
      ChecklistItem(
        title: "6. Short Field Approach and Landing",
        notes: "Execute short field approach and landing", order: 5),
      ChecklistItem(
        title: "7. Soft Field Approach and Landing",
        notes: "Execute soft field approach and landing", order: 6),
      ChecklistItem(
        title: "8. Power Off 180° Approach and Landing",
        notes: "Execute power off 180° approach and landing", order: 7),
      ChecklistItem(
        title: "9. Intercepting and Tracking Navigation Systems (IR)",
        notes: "Intercept and track navigation systems using instruments", order: 8),
    ]
  )

  static let c2L5LazyEights = ChecklistTemplate(
    name: "C2-L5: Lazy Eights",
    category: "Commercial",
    phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
    templateIdentifier: "default_c2_l5_lazy_eights",
    items: [
      ChecklistItem(
        title: "1. Lazy Eights", notes: "Execute lazy eights to commercial standards", order: 0),
      ChecklistItem(
        title: "2. Chandelles", notes: "Execute chandelles to commercial standards", order: 1),
      ChecklistItem(
        title: "3. Steep Turns", notes: "Execute steep turns to commercial standards", order: 2),
      ChecklistItem(
        title: "4. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 3),
      ChecklistItem(
        title: "5. Intercepting and Tracking Navigation Systems (IR)",
        notes: "Intercept and track navigation systems using instruments", order: 4),
      ChecklistItem(
        title: "6. Partial Panel (IR)", notes: "Maintain aircraft control with partial panel",
        order: 5),
      ChecklistItem(
        title: "7. Recovery from Unusual Attitudes (IR)",
        notes: "Recover from unusual attitudes using instruments only", order: 6),
    ]
  )

  static let c2L6EightsOnPylons = ChecklistTemplate(
    name: "C2-L6: Eights On Pylons",
    category: "Commercial",
    phase: "Stage 2: Flying Complex Airplanes and Commercial Maneuvers",
    templateIdentifier: "default_c2_l6_eights_on_pylons",
    items: [
      ChecklistItem(
        title: "1. Eights On Pylons", notes: "Execute eights on pylons to commercial standards",
        order: 0),
      ChecklistItem(
        title: "2. Chandelles", notes: "Execute chandelles to commercial standards", order: 1),
      ChecklistItem(
        title: "3. Steep Turns", notes: "Execute steep turns to commercial standards", order: 2),
      ChecklistItem(
        title: "4. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 3),
      ChecklistItem(
        title: "5. Lazy Eights", notes: "Execute lazy eights to commercial standards", order: 4),
      ChecklistItem(
        title: "6. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb",
        order: 5),
      ChecklistItem(
        title: "7. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb",
        order: 6),
      ChecklistItem(
        title: "8. Short Field Approach and Landing",
        notes: "Execute short field approach and landing", order: 7),
      ChecklistItem(
        title: "9. Soft Field Approach and Landing",
        notes: "Execute soft field approach and landing", order: 8),
      ChecklistItem(
        title: "10. Power Off 180° Approach and Landing",
        notes: "Execute power off 180° approach and landing", order: 9),
      ChecklistItem(
        title: "11. Attitude Instrument Flying (IR)",
        notes: "Maintain aircraft control using instruments only", order: 10),
      ChecklistItem(
        title: "12. Intercepting and Tracking Navigation Systems Partial Panel (IR)",
        notes: "Intercept and track navigation systems with partial panel", order: 11),
      ChecklistItem(
        title: "13. Recovery from Unusual Attitudes (IR)",
        notes: "Recover from unusual attitudes using instruments only", order: 12),
    ]
  )

  // Stage 3: Preparing for Commercial Pilot Check Ride
  static let c3L1DualLocal = ChecklistTemplate(
    name: "C3-L1: Dual Local",
    category: "Commercial",
    phase: "Stage 3: Preparing for Commercial Pilot Check Ride",
    templateIdentifier: "default_c3_l1_dual_local",
    items: [
      ChecklistItem(
        title: "1. Chandelles", notes: "Execute chandelles to commercial standards", order: 0),
      ChecklistItem(
        title: "2. Steep Turns", notes: "Execute steep turns to commercial standards", order: 1),
      ChecklistItem(
        title: "3. Steep Spirals", notes: "Execute steep spirals to commercial standards", order: 2),
      ChecklistItem(
        title: "4. Lazy Eights", notes: "Execute lazy eights to commercial standards", order: 3),
      ChecklistItem(
        title: "5. Eights On Pylons", notes: "Execute eights on pylons to commercial standards",
        order: 4),
      ChecklistItem(
        title: "6. Power Off Stall (approach to landing stall)",
        notes: "Execute power off stalls with proper recovery", order: 5),
      ChecklistItem(
        title: "7. Power On Stall (takeoff and departure stall)",
        notes: "Execute power on stalls with proper recovery", order: 6),
      ChecklistItem(
        title: "8. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb",
        order: 7),
      ChecklistItem(
        title: "9. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb",
        order: 8),
      ChecklistItem(
        title: "10. Short Field Approach and Landing",
        notes: "Execute short field approach and landing", order: 9),
      ChecklistItem(
        title: "11. Soft Field Approach and Landing",
        notes: "Execute soft field approach and landing", order: 10),
      ChecklistItem(
        title: "12. Power Off 180° Approach and Landing",
        notes: "Execute power off 180° approach and landing", order: 11),
      ChecklistItem(
        title: "13. Intercepting and Tracking Navigation Systems (IR)",
        notes: "Intercept and track navigation systems using instruments", order: 12),
      ChecklistItem(
        title: "14. Partial Panel (IR)", notes: "Maintain aircraft control with partial panel",
        order: 13),
      ChecklistItem(
        title: "15. Recovery from Unusual Attitudes (IR)",
        notes: "Recover from unusual attitudes using instruments only", order: 14),
    ]
  )

  static let c3L2FinalProgressCheck = ChecklistTemplate(
    name: "C3-L2: Final Progress Check",
    category: "Commercial",
    phase: "Stage 3: Preparing for Commercial Pilot Check Ride",
    templateIdentifier: "default_c3_l2_final_progress_check",
    items: [
      ChecklistItem(
        title: "1. Cross-Country Flight Planning",
        notes: "Plan cross-country flight to commercial standards", order: 0),
      ChecklistItem(
        title: "2. Preflight Inspection", notes: "Conduct comprehensive preflight inspection",
        order: 1),
      ChecklistItem(title: "3. Checklist Use", notes: "Use checklists throughout flight", order: 2),
      ChecklistItem(
        title: "4. Doors and Safety Belts", notes: "Check doors and safety belt security", order: 3),
      ChecklistItem(
        title: "5. Engine Starting and Warm-up",
        notes: "Proper engine starting and warm-up procedures", order: 4),
      ChecklistItem(title: "6. Use of ATIS", notes: "Obtain and use ATIS information", order: 5),
      ChecklistItem(
        title: "7. Taxiing", notes: "Safe taxiing procedures and communications", order: 6),
      ChecklistItem(
        title: "8. Before Takeoff Check and Engine Runup",
        notes: "Complete before takeoff checklist and engine runup", order: 7),
      ChecklistItem(
        title: "9. Normal and Crosswind Takeoff and Climb",
        notes: "Execute normal and crosswind takeoffs and climbs", order: 8),
      ChecklistItem(
        title: "10. Controlled Airports", notes: "Operate safely at controlled airports", order: 9),
      ChecklistItem(
        title: "11. Departure", notes: "Execute proper departure procedures", order: 10),
      ChecklistItem(
        title: "12. Course Interception", notes: "Intercept and maintain assigned courses",
        order: 11),
      ChecklistItem(title: "13. Pilotage", notes: "Navigate using pilotage techniques", order: 12),
      ChecklistItem(title: "14. Dead Reckoning", notes: "Navigate using dead reckoning", order: 13),
      ChecklistItem(
        title: "15. VOR Navigation (IR)", notes: "Navigate using VOR systems with instruments",
        order: 14),
      ChecklistItem(
        title: "16. ADF Navigation (IR) (if aircraft eq.)",
        notes: "Navigate using ADF systems with instruments if equipped", order: 15),
      ChecklistItem(
        title: "17. GPS Navigation (IR) (if aircraft eq.)",
        notes: "Navigate using GPS systems with instruments if equipped", order: 16),
      ChecklistItem(
        title: "18. ILS/NDB or VOR Approach (IR)",
        notes: "Execute ILS/NDB or VOR approach using instruments", order: 17),
      ChecklistItem(
        title: "19. Partial Panel (IR)", notes: "Maintain aircraft control with partial panel",
        order: 18),
      ChecklistItem(
        title: "20. Recovery from Unusual Attitudes (IR)",
        notes: "Recover from unusual attitudes using instruments only", order: 19),
      ChecklistItem(
        title: "21. Power Settings and Mixture Control",
        notes: "Proper power and mixture management", order: 20),
      ChecklistItem(
        title: "22. Diversion to an Alternate",
        notes: "Execute diversion procedures to alternate airport", order: 21),
      ChecklistItem(
        title: "23. Lost Procedures", notes: "Execute lost procedures and navigation recovery",
        order: 22),
      ChecklistItem(
        title: "24. Use of Retractable Landing Gear",
        notes: "Operate retractable landing gear system", order: 23),
      ChecklistItem(
        title: "25. Simulated System Failures", notes: "Handle simulated system failures", order: 24
      ),
      ChecklistItem(
        title: "26. Simulated Engine Failure", notes: "Handle simulated engine failure", order: 25),
      ChecklistItem(
        title: "27. Estimates of Ground Speed and ETA",
        notes: "Calculate ground speed and estimated time of arrival", order: 26),
      ChecklistItem(
        title: "28. Position Fix by Navigation Facilities",
        notes: "Determine position using navigation facilities", order: 27),
      ChecklistItem(
        title: "29. Flight on Federal Airways", notes: "Navigate on federal airways", order: 28),
      ChecklistItem(
        title: "30. CTAF (FSS or UNICOM) Airports", notes: "Communicate at CTAF airports", order: 29
      ),
      ChecklistItem(
        title: "31. Straight and Level Altitude Flight (IR)",
        notes: "Maintain straight and level flight using instruments only", order: 30),
      ChecklistItem(
        title: "32. Standard Rate Turns (IR)",
        notes: "Execute standard rate turns using instruments only", order: 31),
      ChecklistItem(
        title: "33. Climbs and Climbing Turns (IR)",
        notes: "Execute climbs and climbing turns using instruments only", order: 32),
      ChecklistItem(
        title: "34. Descents and Descending Turns (IR)",
        notes: "Execute descents and descending turns using instruments only", order: 33),
      ChecklistItem(
        title: "35. Recovery from Unusual Attitudes (IR)",
        notes: "Recover from unusual attitudes using instruments only", order: 34),
      ChecklistItem(
        title: "36. Maneuvering During Slow Flight (IR)",
        notes: "Maneuver aircraft during slow flight using instruments only", order: 35),
      ChecklistItem(
        title: "37. Power Off Stall (approach to landing stall)",
        notes: "Execute power off stalls with proper recovery", order: 36),
      ChecklistItem(
        title: "38. Power On Stall (takeoff and departure stall)",
        notes: "Execute power on stalls with proper recovery", order: 37),
      ChecklistItem(
        title: "39. Short Field Takeoff and Climb", notes: "Execute short field takeoff and climb",
        order: 38),
      ChecklistItem(
        title: "40. Soft Field Takeoff and Climb", notes: "Execute soft field takeoff and climb",
        order: 39),
      ChecklistItem(
        title: "41. Short Field Approach and Landing",
        notes: "Execute short field approach and landing", order: 40),
      ChecklistItem(
        title: "42. Soft Field Approach and Landing",
        notes: "Execute soft field approach and landing", order: 41),
      ChecklistItem(
        title: "43. Power Off 180° Approach and Landing",
        notes: "Execute power off 180° approach and landing", order: 42),
      ChecklistItem(
        title: "44. Normal and Crosswind Landing", notes: "Execute normal and crosswind landings",
        order: 43),
      ChecklistItem(
        title: "45. Collision Avoidance Procedures",
        notes: "Maintain collision avoidance awareness", order: 44),
      ChecklistItem(
        title: "46. Chandelles", notes: "Execute chandelles to commercial standards", order: 45),
      ChecklistItem(
        title: "47. Steep Turns", notes: "Execute steep turns to commercial standards", order: 46),
      ChecklistItem(
        title: "48. Steep Spirals", notes: "Execute steep spirals to commercial standards",
        order: 47),
      ChecklistItem(
        title: "49. Lazy Eights", notes: "Execute lazy eights to commercial standards", order: 48),
      ChecklistItem(
        title: "50. Eights On Pylons", notes: "Execute eights on pylons to commercial standards",
        order: 49),
      ChecklistItem(
        title: "51. Parking and Securing", notes: "Proper parking and aircraft securing", order: 50),
      ChecklistItem(
        title: "52. Postflight Procedures",
        notes: "Complete postflight procedures and documentation", order: 51),
    ]
  )

  static let c3L3Endorsements = ChecklistTemplate(
    name: "C3-L3: Endorsements",
    category: "Commercial",
    phase: "Stage 3: Preparing for Commercial Pilot Check Ride",
    templateIdentifier: "default_c3_l3_endorsements",
    items: [
      ChecklistItem(
        title: "1. Commercial Pilot Knowledge Test Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.123 and has satisfactorily completed the required knowledge test review. I have determined that [Student Name] is prepared for the knowledge test.",
        order: 0),
      ChecklistItem(
        title: "2. Commercial Pilot Practical Test Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.123 and has satisfactorily completed the required practical test review. I have determined that [Student Name] is prepared for the practical test.",
        order: 1),
      ChecklistItem(
        title: "3. Complex Aircraft Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.31(e) and has satisfactorily completed the required complex aircraft training. I have determined that [Student Name] is prepared for complex aircraft operations.",
        order: 2),
      ChecklistItem(
        title: "4. High-Performance Aircraft Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.31(f) and has satisfactorily completed the required high-performance aircraft training. I have determined that [Student Name] is prepared for high-performance aircraft operations.",
        order: 3),
      ChecklistItem(
        title: "5. Tailwheel Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.31(i) and has satisfactorily completed the required tailwheel training. I have determined that [Student Name] is prepared for tailwheel operations.",
        order: 4),
      ChecklistItem(
        title: "6. High-Altitude Endorsement",
        notes:
          "I certify that [Student Name] has received the required training of §61.31(g) and has satisfactorily completed the required high-altitude training. I have determined that [Student Name] is prepared for high-altitude operations.",
        order: 5),
    ]
  )
}
