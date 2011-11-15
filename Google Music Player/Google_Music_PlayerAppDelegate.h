//
//  Google_Music_PlayerAppDelegate.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import <RestKit/RestKit.h>

#import "GMManager.h"

#import "GMSongCache.h"
#import "GMAudioPlayer.h"
#import "GMPlaylistManager.h"

@interface Google_Music_PlayerAppDelegate : NSObject <UIApplicationDelegate, UITabBarDelegate, GMPlaylistManagerDelegate, MFMailComposeViewControllerDelegate> {
    GMManager* googleMusicManager;
    
    GMSongCache* songCache;
    GMAudioPlayer* audioPlayer;
    GMPlaylistManager* playlistManager;
    
    BOOL playlistViewVisible;
}

@property (nonatomic, readonly) GMManager* googleMusicManager;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) IBOutlet UIView* playlistView;
@property (nonatomic, retain) IBOutlet UIButton* playPauseButton;
@property (nonatomic, retain) IBOutlet UIButton* playlistViewToggleButton;

@property (nonatomic, retain) IBOutlet UILabel* songLabel;
@property (nonatomic, retain) IBOutlet UILabel* albumLabel;
@property (nonatomic, retain) IBOutlet UILabel* artistLabel;

-(IBAction)togglePlaylistViewVisible;

-(IBAction)togglePlayPause;

-(IBAction)previousSong;
-(IBAction)nextSong;

-(void)adjustViewControllerForPlaylistView:(UIViewController*)viewController;

-(void)setupRestKit;

@end
