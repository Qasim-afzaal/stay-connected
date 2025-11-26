import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // CRITICAL: Disable Universal Links handling for social media domains
    // This prevents iOS from automatically opening apps when Universal Links are detected
    if #available(iOS 14.0, *) {
      // Note: There's no direct API to disable Universal Links in WKWebView,
      // but we can block them at the AppDelegate level which we're already doing
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Prevent Universal Links from opening social media apps
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    print("AppDelegate: Universal Link received - activityType: \(userActivity.activityType)")
    
    // Check if this is a social media universal link
    if let url = userActivity.webpageURL {
      let urlString = url.absoluteString.lowercased()
      print("AppDelegate: Universal Link URL: \(urlString)")
      
      // Block all social media universal links
      let blockedDomains = [
        "tiktok.com",
        "facebook.com",
        "fb.com",
        "twitter.com",
        "x.com",
        "instagram.com",
        "pinterest.com",
        "reddit.com",
        "snapchat.com",
        "youtube.com",
        "youtu.be"
      ]
      
      for domain in blockedDomains {
        if urlString.contains(domain) {
          print("AppDelegate: CRITICAL - Blocked \(domain) universal link: \(urlString)")
          // Don't call super - completely block it
          return false
        }
      }
    }
    
    // Also check activityType
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      if let url = userActivity.webpageURL {
        let urlString = url.absoluteString.lowercased()
        let blockedDomains = ["tiktok.com", "facebook.com", "fb.com", "twitter.com", "x.com", "instagram.com"]
        for domain in blockedDomains {
          if urlString.contains(domain) {
            print("AppDelegate: CRITICAL - Blocked browsing web activity for \(domain): \(urlString)")
            return false
          }
        }
      }
    }
    
    // Allow other universal links to proceed normally
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
  
  // Prevent URL scheme redirects to ALL social media apps
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    let urlString = url.absoluteString.lowercased()
    
    // Block ALL social media app scheme redirects
    let blockedSchemes = [
      // TikTok
      "tiktok://", "snssdk1233://", "snssdk1180://", "snssdk://", "musical://", "tt://",
      // Facebook
      "fb://", "fbapi://", "fbauth2://", "fbshareextension://",
      // Twitter/X
      "twitter://", "tweetie://", "x://",
      // Instagram
      "instagram://", "instagram-stories://",
      // Pinterest
      "pinterest://",
      // Reddit
      "reddit://",
      // Snapchat
      "snapchat://",
      // YouTube
      "youtube://", "youtubewatch://", "youtubeembed://"
    ]
    
    for scheme in blockedSchemes {
      if urlString.hasPrefix(scheme) {
        print("AppDelegate: Blocked \(scheme) URL scheme: \(urlString)")
        return false
      }
    }
    
    // Block App Store URLs
    if urlString.contains("apps.apple.com") ||
       urlString.contains("itunes.apple.com") ||
       urlString.hasPrefix("itms://") ||
       urlString.hasPrefix("itms-apps://") ||
       urlString.contains("play.google.com/store") ||
       urlString.hasPrefix("market://") {
      print("AppDelegate: Blocked App Store URL: \(urlString)")
      return false
    }
    
    // Allow other URL schemes to proceed
    return super.application(app, open: url, options: options)
  }
}
