# Pet Care App Technical Context

## Technology Stack

### Frontend Framework
- Flutter SDK
- Dart programming language
- Material 3 design system
- Provider state management

### Backend Services
- Supabase
  - Authentication
  - Database
  - Real-time subscriptions
  - Storage
  - Edge Functions

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  provider: ^6.0.0
  supabase_flutter: ^1.0.0
  google_sign_in: ^6.0.0
  shared_preferences: ^2.0.0
  flutter_secure_storage: ^8.0.0
  intl: ^0.18.0
```

## Development Setup

### Environment Requirements
- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- Android SDK for Android development
- Xcode for iOS development
- Git for version control

### Configuration Files
1. `lib/utils/app_config.dart`
```dart
class AppConfig {
  static const supabaseUrl = 'YOUR_SUPABASE_URL';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

2. `android/app/build.gradle`
```gradle
defaultConfig {
    applicationId "com.example.petcare"
    minSdkVersion 21
    targetSdkVersion 33
}
```

3. `ios/Runner/Info.plist`
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.example.petcare</string>
        </array>
    </dict>
</array>
```

## Technical Constraints

### Platform Support
- Android 5.0 (API 21) and above
- iOS 11.0 and above
- Web support (progressive)

### Performance Targets
- App size < 30MB
- Launch time < 3 seconds
- Frame rate > 60fps
- Network timeout < 10 seconds

### Security Requirements
- HTTPS for all network calls
- Secure storage for tokens
- Input sanitization
- Data encryption at rest

## Development Guidelines

### Code Style
- Follow Flutter style guide
- Use lint rules
- Consistent naming conventions
- Documentation for public APIs

### Architecture Rules
1. Presentation Layer
   - Screens and widgets
   - UI logic only
   - No direct API calls

2. Business Logic Layer
   - Services and providers
   - Data transformation
   - Business rules

3. Data Layer
   - Models and repositories
   - API integration
   - Local storage

### Error Handling
1. Network Errors
```dart
try {
  await api.call();
} on SocketException {
  // Handle network error
} on TimeoutException {
  // Handle timeout
} catch (e) {
  // Handle other errors
}
```

2. UI Error Handling
```dart
MessageUtils.showMessage(
  context,
  message: error.toString(),
  type: MessageType.error,
);
```

## Testing Strategy

### Unit Tests
- Business logic
- Data transformations
- Utility functions
- Error handling

### Widget Tests
- UI components
- Screen layouts
- User interactions
- State management

### Integration Tests
- User flows
- API integration
- Navigation
- Data persistence

## Deployment Process

### Release Channels
1. Development
   - Debug builds
   - Mock services
   - Verbose logging

2. Staging
   - Release builds
   - Test environment
   - Limited logging

3. Production
   - Release builds
   - Production environment
   - Minimal logging

### Build Configuration
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

## Monitoring and Analytics

### Performance Monitoring
- App start time
- Screen load time
- API response time
- Memory usage
- Battery impact

### Error Tracking
- Crash reporting
- Error logging
- User feedback
- Performance issues

### Usage Analytics
- Screen views
- Feature usage
- User engagement
- Conversion rates

## Documentation

### API Documentation
- Endpoint descriptions
- Request/response formats
- Error codes
- Authentication

### Code Documentation
- Class and method docs
- Complex logic explanation
- Usage examples
- Known limitations

### User Documentation
- Setup guide
- Configuration
- Troubleshooting
- FAQs 