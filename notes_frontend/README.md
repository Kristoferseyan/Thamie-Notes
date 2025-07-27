# Thamie Notes - Frontend

A Flutter desktop application for note-taking with Spring Boot backend integration.

## Features

- User authentication (login/signup)
- Desktop-first design (Windows & macOS)
- Environment-based configuration
- State management with Provider
- HTTP API integration

## Setup

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Spring Boot backend running on `http://localhost:8080`

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Environment Configuration

The application uses a `.env` file for configuration. The file is already set up with:

```
BASE_URL=http://localhost:8080
LOGIN_ENDPOINT=/auth/login
CREATE_USER_ENDPOINT=/user/addUser
```

### Backend API Endpoints

The app is configured to work with these Spring Boot endpoints:

- **Create Account**: `POST http://localhost:8080/user/addUser`
- **Login**: `POST http://localhost:8080/auth/login`

### Running the App

For desktop development:

```bash
# For macOS
flutter run -d macos

# For Windows
flutter run -d windows

# For Linux
flutter run -d linux
```

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── services/
│   ├── api_service.dart      # HTTP API service
│   └── auth_service.dart     # Authentication state management
└── screens/
    ├── login_screen.dart     # Login UI
    ├── signup_screen.dart    # Signup UI
    └── home_screen.dart      # Main app screen
```

### Dependencies

- `flutter_dotenv` - Environment variables
- `http` - HTTP client for API calls
- `provider` - State management
- `shared_preferences` - Local storage for user sessions

## API Integration

### Authentication Flow

1. User enters credentials on login/signup screen
2. App sends request to Spring Boot backend
3. On success, user token is stored locally
4. User is redirected to home screen
5. Token is included in subsequent API requests

### Expected API Response Format

**Create Account Request:**
```json
{
  "first_name": "Sean Christopher",
  "last_name": "Nuevo", 
  "username": "seannuevo",
  "password": "seannuevo",
  "email": "sean@gmail.com",
  "role": "USER"
}
```

**Login Request:**
```json
{
  "username": "seannuevo",
  "password": "seannuevo"
}
```

**Login/Signup Success:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "username": "user123",
    "email": "user@example.com"
  }
}
```

**Error Response:**
```json
{
  "message": "Error description here"
}
```

## Next Steps

- Implement note CRUD operations
- Add note categories/folders
- Implement search functionality
- Add offline support
- Implement note synchronization

## Development

This is a Flutter desktop application designed to work specifically with Windows and macOS platforms. The UI is optimized for desktop usage with appropriate sizing and navigation patterns.
