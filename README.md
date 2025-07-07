# score_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Folder Structure
css
Copy
Edit
lib/
|── provider/
    └── inspection_provider.dart
|── structure/
    └── inspection_item.dart
├── main.dart
├── screen/
│   └── scorecardscreen.dart
├── widgets/
│   └── score_input.dart
assets/
pubspec.yaml

Key Features Implemented
 Station & train details form
 Date picker for inspection
 Dynamic coach-wise and platform-wise scoring
 Expandable tiles for each coach
 Score validations using TextFormField
 Upload photo using camera or gallery
 Generate and export PDF report
 Responsive UI for small/large screens
 Form field validation (required, numeric-only, etc.)


Assumptions & Known Limitations
Assumptions
Only basic validation is applied (e.g., required fields, numeric check).
PDF generation logic is implemented in _generatePdf() (requires you to customize format).
Image upload is single-image only
Platform and section names are fixed in code.




