//
//  Google_Music_PlayerAppDelegate.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GMManager.h"

#import "GMSongCache.h"
#import "GMAudioPlayer.h"
#import "GMPlaylistManager.h"

@interface Google_Music_PlayerAppDelegate : NSObject <UIApplicationDelegate, UITabBarDelegate> {
    GMManager* googleMusicManager;
    
    GMSongCache* songCache;
    GMAudioPlayer* audioPlayer;
    GMPlaylistManager* playlistManager;
}

@property (nonatomic, readonly) GMManager* googleMusicManager;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
