class FacebookConstants {
  FacebookConstants._();

  static const String unknownFriend = 'Unknown';
  static const String emptyCategoryMessage = 'Tap the + button to search people';
  
  static const String searchFriendsTitle = 'Search Friends';
  static const String searchFriendsPlaceholder = 'Enter friend name or URL';
  static const String searchFriendsHint = 'Search and add friends to your category';
  static const String cancel = 'Cancel';
  static const String search = 'Search';
  
  static const String friendOptionsTitle = 'Friend Options';
  static const String friendOptionsMessage = 'What would you like to do with';
  static const String cancelButton = 'CANCEL';
  static const String renameButton = 'RENAME';
  static const String moveButton = 'MOVE';
  static const String deleteButton = 'DELETE';
  
  static const String renameFriendTitle = 'Rename Friend';
  static const String friendRenamedTitle = 'Friend Renamed';
  static const String friendRenamedMessage = 'has been renamed to';
  
  static const String moveFriendTitle = 'Move Friend';
  static const String moveFriendMessage = 'Move';
  static const String moveFriendTo = 'to which category?';
  static const String noCategoriesAvailableTitle = 'No Categories Available';
  static const String noCategoriesAvailableMessage = 'There are no categories to move this friend to.';
  static const String friendMovedTitle = 'Friend Moved';
  static const String friendMovedMessage = 'has been moved to';
  
  static const String deleteFriendTitle = 'Delete Friend';
  static const String deleteFriendMessage = 'Are you sure you want to delete';
  static const String deleteFriendFrom = 'from your';
  static const String deleteFriendList = 'list?';
  static const String friendDeletedTitle = 'Friend Deleted';
  static const String friendDeletedMessage = 'has been removed from your';
  
  static const String addFriendTitle = 'Add Friend';
  static const String addFriendMessage = 'Add this person to your';
  static const String addFriendList = 'list?';
  static const String addFriendPlaceholder = 'Friend Name';
  static const String currentUrlLabel = 'Current URL:';
  static const String loading = 'Loading...';
  static const String friendAddedTitle = 'Friend Added Successfully!';
  static const String friendAddedMessage = 'has been added to your';
  
  static const String errorTitle = 'Error';
  static const String errorNavigateToProfile = 'Please navigate to a Facebook profile page first';
  
  static const String assetImageGroup173 = 'assets/images/img_group_173.jpg';
  static const String assetAccountFb = 'assets/images/account_fb.png';
  static const String assetImgFb = 'assets/images/img_fb.png';
  static const String assetPersonAddBlue = 'assets/images/img_person_add_blue.png';
  
  static const String webviewParam1 = '_webview=1';
  static const String webviewParam2 = 'noapp=1';
  static const String siteFacebook = 'site:facebook.com';
  static const String googleSearchBase = 'https://www.google.com/search?q=';
  
  static const String iosUserAgent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1';
  static const String androidUserAgent = 'Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
  
  static const String acceptHeader = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
  static const String acceptLanguageHeader = 'en-US,en;q=0.9';
  
  static const String blockingScript = '''
    (function() {
      if (window.facebookBlockingLoaded) return;
      window.facebookBlockingLoaded = true;
      
      document.addEventListener('click', function(e) {
        let target = e.target;
        let depth = 0;
        while (target && target !== document && depth < 10) {
          if (target.tagName === 'A' && target.href) {
            const href = target.href.toLowerCase();
            if (href.startsWith('fb://') ||
                href.startsWith('fbapi://') ||
                href.startsWith('fbauth2://') ||
                href.includes('applink.facebook.com') ||
                href.includes('apps.apple.com') ||
                href.includes('itunes.apple.com') ||
                href.startsWith('itms://') ||
                href.startsWith('itms-apps://') ||
                href.includes('play.google.com/store') ||
                href.startsWith('market://')) {
              e.preventDefault();
              e.stopPropagation();
              e.stopImmediatePropagation();
              return false;
            }
          }
          target = target.parentElement;
          depth++;
        }
      }, true);
      
      const originalOpen = window.open;
      window.open = function(url, target, features) {
        if (url) {
          const urlLower = url.toLowerCase();
          if (urlLower.startsWith('fb://') ||
              urlLower.startsWith('fbapi://') ||
              urlLower.startsWith('fbauth2://') ||
              urlLower.includes('applink.facebook.com') ||
              urlLower.includes('apps.apple.com') ||
              urlLower.includes('itunes.apple.com')) {
            return null;
          }
        }
        return originalOpen.call(window, url, target, features);
      };
      
      const originalHref = Object.getOwnPropertyDescriptor(window, 'location').get;
      Object.defineProperty(window, 'location', {
        get: function() {
          const loc = originalHref.call(window);
          const originalAssign = loc.assign;
          const originalReplace = loc.replace;
          
          loc.assign = function(url) {
            const urlLower = (url || '').toLowerCase();
            if (urlLower.startsWith('fb://') ||
                urlLower.startsWith('fbapi://') ||
                urlLower.startsWith('fbauth2://') ||
                urlLower.includes('applink.facebook.com')) {
              return;
            }
            return originalAssign.call(loc, url);
          };
          
          loc.replace = function(url) {
            const urlLower = (url || '').toLowerCase();
            if (urlLower.startsWith('fb://') ||
                urlLower.startsWith('fbapi://') ||
                urlLower.startsWith('fbauth2://') ||
                urlLower.includes('applink.facebook.com')) {
              return;
            }
            return originalReplace.call(loc, url);
          };
          
          return loc;
        }
      });
    })();
  ''';
  
  static const String blockingScriptSimple = '''
    (function() {
      document.addEventListener('click', function(e) {
        let target = e.target;
        let depth = 0;
        while (target && target !== document && depth < 10) {
          if (target.tagName === 'A' && target.href) {
            const href = target.href.toLowerCase();
            if (href.startsWith('fb://') ||
                href.startsWith('fbapi://') ||
                href.startsWith('fbauth2://') ||
                href.includes('applink.facebook.com') ||
                href.includes('apps.apple.com') ||
                href.includes('itunes.apple.com') ||
                href.startsWith('itms://') ||
                href.startsWith('itms-apps://') ||
                href.includes('play.google.com/store') ||
                href.startsWith('market://')) {
              e.preventDefault();
              e.stopPropagation();
              e.stopImmediatePropagation();
              return false;
            }
          }
          target = target.parentElement;
          depth++;
        }
      }, true);
    })();
  ''';
  
  static const String blockingScriptWithWindowOpen = '''
    (function() {
      document.addEventListener('click', function(e) {
        let target = e.target;
        let depth = 0;
        while (target && target !== document && depth < 10) {
          if (target.tagName === 'A' && target.href) {
            const href = target.href.toLowerCase();
            if (href.startsWith('fb://') ||
                href.startsWith('fbapi://') ||
                href.startsWith('fbauth2://') ||
                href.includes('applink.facebook.com') ||
                href.includes('apps.apple.com') ||
                href.includes('itunes.apple.com') ||
                href.startsWith('itms://') ||
                href.startsWith('itms-apps://') ||
                href.includes('play.google.com/store') ||
                href.startsWith('market://')) {
              e.preventDefault();
              e.stopPropagation();
              e.stopImmediatePropagation();
              return false;
            }
          }
          target = target.parentElement;
          depth++;
        }
      }, true);
      
      const originalOpen = window.open;
      window.open = function(url, target, features) {
        if (url) {
          const urlLower = url.toLowerCase();
          if (urlLower.startsWith('fb://') ||
              urlLower.startsWith('fbapi://') ||
              urlLower.startsWith('fbauth2://') ||
              urlLower.includes('applink.facebook.com') ||
              urlLower.includes('apps.apple.com') ||
              urlLower.includes('itunes.apple.com')) {
            return null;
          }
        }
        return originalOpen.call(window, url, target, features);
      };
    })();
  ''';
}
