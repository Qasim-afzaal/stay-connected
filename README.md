# 🌐 StayConnected - Your Social Universe, Organized Your Networks

Welcome to **StayConnected**, the ultimate Flutter app for managing and accessing all your social connections across multiple platforms in one seamless experience!

## ✨ Features

### 🔍 Multi-Platform Integration
Access all your favorite social media platforms in one app:
- 📘 Facebook
- 📷 Instagram
- 👻 Snapchat
- 📌 Pinterest
- 🤖 Reddit
- 🎵 TikTok
- 🐦 Twitter (X)
- 📺 YouTube

### 🏷️ Smart Categorization
Organize your connections with intuitive categories:
- 🎬 Entertainment
- 🍔 Food & Cooking
- 🌟 Celebrities & Influencers
- 💪 Gym & Fitness
- 📚 Education
- 🎮 Gaming
- 🛒 Shopping
- ...and many more!

### 🔎 Advanced Search & Discovery
- Search for friends across all platforms simultaneously
- Advanced WebView integration with platform-specific optimizations
- Save profiles with custom categories directly from search results
- Real-time loading progress indicators
- Smart URL handling to prevent unwanted redirects

### 💾 Persistent Storage
- Your saved profiles stay organized forever
- Quick access to frequently visited accounts
- Category-based filtering for easy navigation
- Platform-specific profile management

### 🎯 Enhanced WebView Features
- **Platform-Specific Navigation**: Each platform has dedicated webview handling
- **Native App Integration**: TikTok and Instagram support native app redirects for reels/images
- **Smart Redirect Blocking**: Prevents unwanted app redirects while allowing content navigation
- **Add Friend Functionality**: One-tap friend addition with loading progress
- **Google OAuth Support**: Handles OAuth flows without breaking navigation
- **Content Detection**: Automatically detects and handles videos, posts, and profiles

### 🎨 User Interface
- **Consistent AppBar Design**: White background with black text in light mode for optimal readability
- **Visual Separation**: Dividers on all AppBars for clear content boundaries
- **Dark Mode Support**: Seamless theme switching with appropriate color schemes
- **Platform-Specific Styling**: Each platform maintains its unique identity while following design guidelines

## 🚀 How It Works

1. **Select a Platform** - Choose from our supported social networks
2. **Browse or Search** - Use our integrated WebView to explore content
3. **Add Friends** - Click the "Add Friend" button to save profiles with categories
4. **Organize** - View your saved connections by platform or category
5. **Revisit** - Quickly access your curated social universe anytime!

## 🛠️ Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- iOS: Xcode and CocoaPods
- Android: Android Studio and Android SDK

### Setup Instructions

```bash
# Clone the repository
git clone https://github.com/Qasim-afzaal/stayconnected.git

# Navigate to the project directory
cd stayconnected

# Install Flutter dependencies
flutter pub get

# For iOS, install CocoaPods dependencies
cd ios && pod install && cd ..

# Run the app
flutter run
```

### Platform-Specific Setup

#### iOS
```bash
cd ios
pod install
cd ..
flutter run
```

#### Android
```bash
# Ensure Android SDK is properly configured
flutter run
```

## 🏗️ Technical Details

### Architecture
- **Framework**: Flutter
- **State Management**: GetX
- **WebView**: flutter_inappwebview
- **Storage**: Local persistence for profiles and categories

### Key Components
- **Platform-Specific WebViews**: Each social platform has dedicated webview implementation
- **Navigation Control**: Smart URL handling to prevent unwanted redirects
- **JavaScript Injection**: Platform-specific scripts for enhanced functionality
- **Error Handling**: Robust error handling for network and navigation issues

### Recent Improvements
- ✅ Platform-specific webview implementations for all social networks
- ✅ Native app redirect support for TikTok and Instagram content
- ✅ Enhanced Add Friend functionality with loading indicators
- ✅ Improved URL handling and redirect blocking
- ✅ Google OAuth iframe support
- ✅ Screen time prompt handling for TikTok
- ✅ Content detection and smart navigation
- ✅ Consistent AppBar styling across all screens with white background and black text in light mode
- ✅ Added dividers to AppBars for better visual separation


## 📱 Platform-Specific Features

### TikTok & Instagram
- **Native App Redirects**: Reels and images can open in the native app when clicked
- **Video/Post Detection**: Automatic detection and handling of videos and posts
- **Screen Time Prompts**: Automatic dismissal of screen time prompts (TikTok)

### All Platforms
- **Add Friend Button**: Always visible at the bottom with loading progress
- **Smart Navigation**: Prevents unwanted redirects while allowing content navigation
- **Loading Indicators**: Real-time progress tracking during page loads
- **Error Handling**: Graceful handling of network and navigation errors

## 🐛 Known Issues & Limitations

- Some platforms may require additional permissions for full functionality
- WebView behavior may vary slightly between iOS and Android
- Network-dependent features require active internet connection

## 🔄 Recent Updates

### Version 2.1.0
- ✨ **UI/UX Improvements**: Updated AppBar styling across all screens
  - White background with black text in light mode for better readability
  - Added dividers to AppBars for clear visual separation
  - Consistent styling across all platform pages, icon screens, and webview screens
  - Maintained dark mode compatibility with theme-based colors

### Version 2.0.0
- ✨ Added platform-specific webview implementations
- ✨ Implemented native app redirect support for TikTok and Instagram
- ✨ Enhanced Add Friend functionality across all platforms
- ✨ Improved URL handling and redirect blocking
- ✨ Added loading progress indicators
- 🐛 Fixed Google OAuth iframe issues
- 🐛 Fixed white screen issues on various platforms
- 🐛 Improved content detection and navigation

## 🤝 Contributing

We welcome contributions! Please feel free to submit pull requests or open issues for bugs and feature requests.

### Contribution Guidelines
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.


## 🙏 Acknowledgments

- Built with Flutter
- Uses GetX for state management
- flutter_inappwebview for webview functionality

---

<div align="center">
Made with ❤️ for the socially connected world<br/>
**Stay Connected. Stay Organized. Stay You.**
</div>
