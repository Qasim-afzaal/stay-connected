import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Helper class for injecting dark theme CSS into webviews
class WebViewDarkThemeHelper {
  /// Get dark theme CSS as a UserScript for injection at document start
  static UserScript getDarkThemeUserScript() {
    return UserScript(
      source: '''
        (function() {
          const style = document.createElement('style');
          style.id = 'dark-theme-style';
          style.textContent = `
            :root {
              color-scheme: dark;
            }
            html {
              background-color: #000000 !important;
              filter: invert(1) hue-rotate(180deg) !important;
            }
            img, video, iframe, embed, object, svg, canvas, [style*="background-image"] {
              filter: invert(1) hue-rotate(180deg) !important;
            }
            body {
              background-color: #000000 !important;
              color: #ffffff !important;
            }
            /* Apply dark theme to common elements */
            div, section, article, main, header, footer, nav, aside {
              background-color: transparent !important;
            }
            /* Preserve media colors - re-invert images and videos */
            img[src*=".jpg"], img[src*=".jpeg"], img[src*=".png"], img[src*=".gif"],
            img[src*=".webp"], video, iframe[src*="youtube"], iframe[src*="vimeo"],
            img[src*="tiktok"], video[src*="tiktok"] {
              filter: invert(1) hue-rotate(180deg) !important;
            }
          `;
          if (document.head) {
            document.head.appendChild(style);
          } else {
            document.addEventListener('DOMContentLoaded', function() {
              if (document.head) {
                document.head.appendChild(style);
              }
            });
          }
        })();
      ''',
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    );
  }

  /// Inject dark theme CSS into webview after page loads
  static Future<void> injectDarkTheme(
    InAppWebViewController controller,
    BuildContext context,
  ) async {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      try {
        await controller.evaluateJavascript(source: '''
          (function() {
            // Remove existing dark theme style if any
            const existingStyle = document.getElementById('dark-theme-style');
            if (existingStyle) {
              existingStyle.remove();
            }
            
            // Create and inject dark theme CSS
            const style = document.createElement('style');
            style.id = 'dark-theme-style';
            style.textContent = `
              :root {
                color-scheme: dark;
              }
              html {
                background-color: #000000 !important;
                filter: invert(1) hue-rotate(180deg) !important;
              }
              img, video, iframe, embed, object, svg, canvas, [style*="background-image"] {
                filter: invert(1) hue-rotate(180deg) !important;
              }
              body {
                background-color: #000000 !important;
                color: #ffffff !important;
              }
              /* Apply dark theme to common elements */
              div, section, article, main, header, footer, nav, aside {
                background-color: transparent !important;
              }
              /* Preserve media colors - re-invert images and videos */
              img[src*=".jpg"], img[src*=".jpeg"], img[src*=".png"], img[src*=".gif"],
              img[src*=".webp"], video, iframe[src*="youtube"], iframe[src*="vimeo"],
              img[src*="tiktok"], video[src*="tiktok"] {
                filter: invert(1) hue-rotate(180deg) !important;
              }
            `;
            if (document.head) {
              document.head.appendChild(style);
            } else {
              document.addEventListener('DOMContentLoaded', function() {
                if (document.head) {
                  document.head.appendChild(style);
                }
              });
            }
          })();
        ''');
      } catch (e) {
        print('Error injecting dark theme: $e');
      }
    }
  }
}

