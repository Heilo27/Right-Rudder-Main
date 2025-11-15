# CloudKit Schema Deployment Guide

## Important: One-Time Setup

This is a **ONE-TIME** setup that must be completed **BEFORE** publishing your app to the App Store. After deploying these record types to Production CloudKit, you can create unlimited records automatically - no manual steps needed per student.

## Prerequisites

1. Access to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/)
2. Your Apple Developer account credentials
3. Container: `iCloud.com.heiloprojects.rightrudder`

## Deployment Steps

1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/)
2. Select your container: `iCloud.com.heiloprojects.rightrudder`
3. Navigate to **Schema** > **Record Types**
4. Select **Production** environment (not Development)
5. For each record type below, click **Add Record Type** and configure as specified

## Required Record Types

### 1. Student

**Record Type Name**: `Student`

**Fields**:
- `firstName` (String)
- `lastName` (String)
- `email` (String)
- `telephone` (String)
- `homeAddress` (String)
- `ftnNumber` (String)
- `biography` (String)
- `backgroundNotes` (String)
- `instructorName` (String)
- `instructorCFINumber` (String)
- `lastModified` (Date/Time)
- `studentId` (String) - **Indexed**
- `instructorEmail` (String)
- `goalPPL` (Int64/Number)
- `goalInstrument` (Int64/Number)
- `goalCommercial` (Int64/Number)
- `goalCFI` (Int64/Number)
- `pplGroundSchoolCompleted` (Int64/Number)
- `pplWrittenTestCompleted` (Int64/Number)
- `instrumentGroundSchoolCompleted` (Int64/Number)
- `instrumentWrittenTestCompleted` (Int64/Number)
- `commercialGroundSchoolCompleted` (Int64/Number)
- `commercialWrittenTestCompleted` (Int64/Number)
- `cfiGroundSchoolCompleted` (Int64/Number)
- `cfiWrittenTestCompleted` (Int64/Number)
- `shareTerminated` (Int64/Number)
- `shareTerminatedAt` (Date/Time)

### 2. ChecklistAssignment

**Record Type Name**: `ChecklistAssignment`

**Fields**:
- `assignmentId` (String) - **Indexed**
- `templateId` (String) - **Indexed**
- `templateIdentifier` (String)
- `isCustomChecklist` (Int64/Number)
- `instructorComments` (String)
- `dualGivenHours` (Double)
- `lastModified` (Date/Time)
- `studentId` (String) - **Indexed**
- `assignedAt` (Date/Time)
- `itemProgress` (String) - JSON-encoded array of ItemProgressData

### 3. ItemProgress

**Record Type Name**: `ItemProgress`

**Fields**:
- `templateItemId` (String) - **Indexed**
- `isComplete` (Int64/Number)
- `assignmentId` (String) - **Indexed, Queryable** (CRITICAL for student app queries)
- `notes` (String)
- `completedAt` (Date/Time)
- `lastModified` (Date/Time)

**Important**: The `assignmentId` field MUST be marked as **Queryable** for the student app to query ItemProgress records.

### 4. StudentDocument

**Record Type Name**: `StudentDocument`

**Fields**:
- `documentType` (String)
- `filename` (String)
- `fileData` (Bytes/Asset)
- `uploadedAt` (Date/Time)
- `expirationDate` (Date/Time)
- `notes` (String)
- `studentId` (String) - **Indexed**
- `lastModified` (Date/Time)

### 5. StudentPersonalInfo

**Record Type Name**: `StudentPersonalInfo`

**Fields**:
- `studentId` (String) - **Indexed**
- `firstName` (String)
- `lastName` (String)
- `email` (String)
- `telephone` (String)
- `homeAddress` (String)
- `ftnNumber` (String)
- `profilePhotoData` (Bytes/Asset)
- `documents` (String) - JSON-encoded array
- `lastModified` (Date/Time)
- `lastModifiedBy` (String)

### 6. TrainingGoals

**Record Type Name**: `TrainingGoals`

**Fields**:
- `studentId` (String) - **Indexed**
- `goalPPL` (Int64/Number)
- `goalInstrument` (Int64/Number)
- `goalCommercial` (Int64/Number)
- `goalCFI` (Int64/Number)
- `pplGroundSchoolCompleted` (Int64/Number)
- `pplWrittenTestCompleted` (Int64/Number)
- `instrumentGroundSchoolCompleted` (Int64/Number)
- `instrumentWrittenTestCompleted` (Int64/Number)
- `commercialGroundSchoolCompleted` (Int64/Number)
- `commercialWrittenTestCompleted` (Int64/Number)
- `cfiGroundSchoolCompleted` (Int64/Number)
- `cfiWrittenTestCompleted` (Int64/Number)

### 7. CustomChecklistDefinition

**Record Type Name**: `CustomChecklistDefinition`

**Fields**:
- `templateId` (String) - **Indexed**
- `customName` (String)
- `customCategory` (String)
- `studentId` (String) - **Indexed, Queryable** (CRITICAL for student app queries)
- `lastModified` (Date/Time)
- `customItems` (String) - JSON-encoded array

**Important**: The `studentId` field MUST be marked as **Queryable** for the student app to query custom checklist definitions.

## After Deployment

1. Wait 2-5 minutes for CloudKit to propagate the schema changes
2. Test creating a share link in a Release build
3. Verify that Student records can be created without errors
4. Once verified, you can publish your app - schemas are now deployed and will work for all users

## Verification

After deployment, you can verify schemas are deployed by:
1. Going to CloudKit Dashboard > Schema > Record Types
2. Selecting Production environment
3. Verifying all 7 record types listed above are present
4. Checking that indexed fields are properly marked

## Troubleshooting

If you see "Cannot create new type X in production schema" error:
- Verify the record type is deployed to Production (not just Development)
- Check that all required fields are present
- Ensure indexed fields are marked correctly
- Wait a few minutes after deployment for propagation

## Notes

- This deployment is **permanent** - once deployed, the schemas exist for all users
- You do NOT need to redeploy for each student or each app update
- After deployment, the app automatically creates records without manual steps
- Development environment auto-creates schemas, but Production requires this one-time deployment

