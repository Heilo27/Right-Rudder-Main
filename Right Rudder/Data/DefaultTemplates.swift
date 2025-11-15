//
//  DefaultTemplates.swift
//  Right Rudder
//
//  Centralized location for all default checklist templates
//  Templates are organized into category-based files for maintainability
//

import Foundation
import SwiftData

// MARK: - DefaultTemplates

/// Centralized location for all default checklist templates
/// Templates are split into category-based files:
/// - DefaultTemplatesPPL.swift: PPL training templates
/// - DefaultTemplatesIFR.swift: Instrument rating templates
/// - DefaultTemplatesCPL.swift: Commercial rating templates
/// - DefaultTemplatesReview.swift: Review templates
class DefaultTemplates {

  // MARK: - All Templates Array

  /// Returns all default templates in the correct order
  /// Lazy loading for memory efficiency
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
}
