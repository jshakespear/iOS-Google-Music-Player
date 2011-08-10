//
//  Google_Music_PlayerAppDelegate.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "Google_Music_PlayerAppDelegate.h"

#import "GMSongCacheViewController.h"

#define kToggleButtonSize (35.0f)

@implementation Google_Music_PlayerAppDelegate

@synthesize googleMusicManager;

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

@synthesize playlistView=_playlistView;
@synthesize playPauseButton;
@synthesize playlistViewToggleButton;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //googleMusicManager = [[GMManager alloc] init];
    
    songCache = [[GMSongCache alloc] init];
    
    audioPlayer = [[GMAudioPlayer alloc] init];
    
    playlistManager = [[GMPlaylistManager alloc] init];
    playlistManager.audioPlayer = audioPlayer;
    playlistManager.delegate = self;
    
    for(UIViewController* viewController in self.tabBarController.viewControllers)
    {
        UIViewController* realViewController = viewController;
        
        if([viewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController* navController = (UINavigationController*)viewController;
            realViewController = [navController visibleViewController];
        }
        
        if([realViewController conformsToProtocol:@protocol(GMSongCacheViewController)])
        {
            if([realViewController respondsToSelector:@selector(setSongCache:)])
            {
                [realViewController performSelector:@selector(setSongCache:) withObject:songCache];
            }
            
            if([realViewController respondsToSelector:@selector(setAudioPlayer:)])
            {
                [realViewController performSelector:@selector(setAudioPlayer:) withObject:audioPlayer];
            }
            
            if([realViewController respondsToSelector:@selector(setPlaylistManager:)])
            {
                [realViewController performSelector:@selector(setPlaylistManager:) withObject:playlistManager];
            }
        }
    }
    
    CGRect tabBarFrame = self.tabBarController.tabBar.frame;
    CGRect playlistViewFrame = self.playlistView.frame;
    playlistViewFrame.origin = tabBarFrame.origin;
    playlistViewFrame.origin.y -= self.playlistView.frame.size.height;
    self.playlistView.frame = playlistViewFrame;
    [self.tabBarController.view insertSubview:self.playlistView belowSubview:self.tabBarController.tabBar];
    
    playlistViewVisible = YES;

    [songCache synchronize];
    
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(IBAction)togglePlaylistViewVisible
{
    if(playlistViewVisible)
    {
        CGRect frame = self.playlistView.frame;
        frame.origin.y += frame.size.height - kToggleButtonSize;
        
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.playlistView.frame = frame;
        }];
        
        playlistViewVisible = NO;
    }
    else
    {
        CGRect frame = self.playlistView.frame;
        frame.origin.y -= frame.size.height - kToggleButtonSize;
        
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.playlistView.frame = frame;
        }];
        
        playlistViewVisible = YES;
    }
}

-(IBAction)togglePlayPause
{
    if([audioPlayer playing])
    {
        [audioPlayer pause];
    }
    else
    {
        [audioPlayer play];
    }
}

-(void)playlistManagerDidPlayItem:(GMPlaylistItem*)item resuming:(BOOL)resuming
{
    self.playPauseButton.selected = YES;
    [self.playlistViewToggleButton setTitle:[NSString stringWithFormat:@"Playing '%@'", item.song.title] forState:UIControlStateNormal];
}

-(void)playlistManagerDidPauseItem:(GMPlaylistItem*)item
{
    self.playPauseButton.selected = NO;
    [self.playlistViewToggleButton setTitle:[NSString stringWithFormat:@"Paused '%@'", item.song.title] forState:UIControlStateNormal];
}

-(void)playlistManagerDidFinishPlayingItem:(GMPlaylistItem*)item
{
    self.playPauseButton.selected = NO;
    [self.playlistViewToggleButton setTitle:@"No Song Playing" forState:UIControlStateNormal];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UIViewController* realViewController = viewController;
    
    if([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navController = (UINavigationController*)viewController;
        realViewController = [navController visibleViewController];
    }
    
    if([realViewController conformsToProtocol:@protocol(GMSongCacheViewController)])
    {
        if([realViewController respondsToSelector:@selector(setSongCache:)])
        {
            [realViewController performSelector:@selector(setSongCache:) withObject:songCache];
        }
        
        if([realViewController respondsToSelector:@selector(setAudioPlayer:)])
        {
            [realViewController performSelector:@selector(setAudioPlayer:) withObject:audioPlayer];
        }
        
        if([realViewController respondsToSelector:@selector(setPlaylistManager:)])
        {
            [realViewController performSelector:@selector(setPlaylistManager:) withObject:playlistManager];
        }
    }
}

- (void)dealloc
{
    [songCache release];
    [audioPlayer release];
    [playlistManager release];
    
    [googleMusicManager release];
    
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

@end
