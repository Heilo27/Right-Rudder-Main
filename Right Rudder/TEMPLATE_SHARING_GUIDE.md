# Template Sharing Feature Guide

## Overview
The Right Rudder app now supports sharing custom checklist templates with other users. This allows instructors to collaborate and share their custom lesson plans, training materials, and checklist templates.

## Features

### 1. Template Tracking
All templates are now tracked with the following attributes:
- **User-Created**: Templates created from scratch by the user
- **User-Modified**: Default templates that have been edited by the user
- **Original Author**: The instructor who created the template (uses instructor name from settings)

### 2. Exporting Templates

#### How to Share Templates:
1. Go to **Settings**
2. Tap **"Share Lesson Lists with Others"**
3. Select the templates you want to share
   - User-created templates appear first (marked with person badge)
   - User-modified templates appear second (marked with pencil icon)
   - Default templates appear last
4. Tap **"Share Selected Templates"**
5. Choose how to send the file:
   - **Email**: Send to instructor colleagues
   - **Messages**: Text to other instructors
   - **AirDrop**: Share directly with nearby devices

#### File Format
Templates are exported as `.rrtl` files (Right Rudder Template List)
- Contains all template data in JSON format
- Includes metadata like export date and author
- Can contain multiple templates in a single file

### 3. Importing Templates

#### Automatic Import:
When you receive a `.rrtl` file:
1. Tap the file on your device
2. Select **"Open in Right Rudder"**
3. The app will automatically:
   - Import all templates from the file
   - Skip any templates that already exist (based on ID)
   - Display confirmation of successful import

#### What Gets Imported:
- Template name, category, and phase
- All checklist items with titles and notes
- Relevant data (study materials, references)
- Original author information
- Creation and modification dates

### 4. Template Organization

All template lists are sorted alphabetically, with custom logic for:
- **User-created templates**: Appear first in sharing menu
- **User-modified templates**: Appear second in sharing menu
- **Default templates**: Appear last in sharing menu
- **Phase grouping**: Templates are grouped by phase (First Steps, Phase 1, Phase 1.5 Pre-Solo/Solo, etc.)
- **Alphabetical order**: Within each category, templates are sorted alphabetically

## Xcode Configuration

### Required Files:
1. **Info-Additions.plist**: Declares the `.rrtl` file type
   - Must be added to the app target
   - Registers the custom UTI (Uniform Type Identifier)
   - Configures document handling

### Build Settings:
In Xcode, ensure:
1. `Info-Additions.plist` is included in the target
2. The app can handle document types
3. URL scheme handling is enabled

## Technical Details

### File Structure (.rrtl):
```json
{
  "templates": [
    {
      "id": "UUID",
      "name": "Template Name",
      "category": "PPL/Instrument/Commercial",
      "phase": "Phase 1/Phase 2/etc",
      "relevantData": "Study materials...",
      "items": [
        {
          "id": "UUID",
          "title": "Item title",
          "notes": "Item notes"
        }
      ],
      "isUserCreated": true,
      "isUserModified": false,
      "originalAuthor": "Instructor Name",
      "createdAt": "ISO8601 date",
      "lastModified": "ISO8601 date"
    }
  ],
  "exportDate": "ISO8601 date",
  "exportedBy": "Instructor Name",
  "appVersion": "2.0"
}
```

### UTI Declaration:
- **UTI**: `com.heiloprojects.rightrudder.template`
- **File Extension**: `.rrtl`
- **MIME Type**: `application/x-rightrudder-template`
- **Conforms To**: `public.data`, `public.content`

## Best Practices

### For Instructors Sharing Templates:
1. **Set Your Name**: Go to Settings → User Information and enter your name
   - This helps recipients know who created the templates
2. **Review Before Sharing**: Double-check template content before exporting
3. **Include Relevant Data**: Add study materials and references in the template
4. **Use Descriptive Names**: Clear template names help other instructors

### For Instructors Receiving Templates:
1. **Review Before Importing**: Check the file source
2. **Check for Duplicates**: The app automatically skips duplicate templates
3. **Customize as Needed**: Edit imported templates to fit your teaching style
4. **Give Credit**: Keep the original author information intact

## Troubleshooting

### App doesn't open .rrtl files:
- Ensure Info-Additions.plist is properly configured in Xcode
- Rebuild the app after adding the plist
- Check that document types are registered in app capabilities

### Import fails:
- Check that the .rrtl file is not corrupted
- Ensure the file was created by Right Rudder app
- Check console logs for detailed error messages

### Templates already exist:
- The app skips templates with matching IDs
- This prevents duplicate imports
- You can manually edit or delete existing templates if needed

## Future Enhancements

Potential improvements for this feature:
- Visual import confirmation dialog
- Preview templates before importing
- Template versioning and updates
- Online template repository
- Rating and review system for shared templates

## Support

For questions or issues with template sharing, check:
- Console logs for detailed error messages
- Xcode debugger for import/export issues
- CloudKit dashboard for sync-related problems

