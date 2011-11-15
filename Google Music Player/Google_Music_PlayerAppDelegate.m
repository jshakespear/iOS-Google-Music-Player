//
//  Google_Music_PlayerAppDelegate.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "Google_Music_PlayerAppDelegate.h"

#import "GMSongCacheViewController.h"

#import "GMSong.h"
#import "GMServerSync.h"

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

#import <MessageUI/MessageUI.h>

#define kToggleButtonSize (35.0f)

@implementation Google_Music_PlayerAppDelegate

@synthesize googleMusicManager;

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

@synthesize playlistView=_playlistView;
@synthesize playPauseButton;
@synthesize playlistViewToggleButton;

@synthesize songLabel;
@synthesize albumLabel;
@synthesize artistLabel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    [self setupRestKit];
    
    songCache = [[GMSongCache alloc] init];
    
    audioPlayer = [[GMAudioPlayer alloc] init];
    
    playlistManager = [[GMPlaylistManager alloc] init];
    playlistManager.audioPlayer = audioPlayer;
    playlistManager.delegate = self;
    
    audioPlayer.delegate = playlistManager;
    
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
    
    for(UIViewController* viewController in self.tabBarController.viewControllers)
    {
        [self adjustViewControllerForPlaylistView:viewController];
    }
    
    playlistViewVisible = YES;

    [songCache loadFromLocalStore];
    
    // Restore cookeis
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray* cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"GoogleAuthCookies"]];
    if(cookies)
    {
        for(NSHTTPCookie* cookie in cookies)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        
        NSLog(@"Restored cookies from previous session.");
    }
    
    
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)setupRestKit
{
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:@"http://music.google.com"];
    
    NSString* databaseName = @"GMDatabase.sqlite";
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName];
    
    objectManager.acceptMIMEType = @"text/plain";
    [[RKParserRegistry sharedRegistry] setParserClass:NSClassFromString(@"RKJSONParserSBJSON") forMIMEType:@"text/plain"];
    
    RKManagedObjectMapping* songMapping = [RKManagedObjectMapping mappingForClass:[GMSong class]];
    songMapping.primaryKeyAttribute = @"identifier";
    [songMapping mapKeyPath:@"genre" toAttribute:@"genre"];
    [songMapping mapKeyPath:@"beatsPerMinute" toAttribute:@"beatsPerMinute"];
    [songMapping mapKeyPath:@"albumArtistNorm" toAttribute:@"albumArtistNorm"];
    [songMapping mapKeyPath:@"artistNorm" toAttribute:@"artistNorm"];
    [songMapping mapKeyPath:@"album" toAttribute:@"album"];
    [songMapping mapKeyPath:@"lastPlayed" toAttribute:@"lastPlayed"];
    [songMapping mapKeyPath:@"disc" toAttribute:@"disc"];
    [songMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [songMapping mapKeyPath:@"composer" toAttribute:@"composer"];
    [songMapping mapKeyPath:@"title" toAttribute:@"title"];
    [songMapping mapKeyPath:@"albumArtist" toAttribute:@"albumArtist"];
    [songMapping mapKeyPath:@"totalTracks" toAttribute:@"totalTracks"];
    [songMapping mapKeyPath:@"name" toAttribute:@"name"];
    [songMapping mapKeyPath:@"totalDisc" toAttribute:@"totalDisc"];
    [songMapping mapKeyPath:@"year" toAttribute:@"year"];
    [songMapping mapKeyPath:@"titleNorm" toAttribute:@"titleNorm"];
    [songMapping mapKeyPath:@"artist" toAttribute:@"artist"];
    [songMapping mapKeyPath:@"albumNorm" toAttribute:@"albumNorm"];
    [songMapping mapKeyPath:@"track" toAttribute:@"track"];
    [songMapping mapKeyPath:@"durationMillis" toAttribute:@"durationMillis"];
    [songMapping mapKeyPath:@"albumArtUrl" toAttribute:@"albumArtUrl"];
    [songMapping mapKeyPath:@"url" toAttribute:@"url"];
    [songMapping mapKeyPath:@"creationDate" toAttribute:@"creationDate"];
    [songMapping mapKeyPath:@"playCount" toAttribute:@"playCount"];
    [songMapping mapKeyPath:@"rating" toAttribute:@"rating"];
    [songMapping mapKeyPath:@"comment" toAttribute:@"comment"];
    
    [objectManager.mappingProvider setMapping:songMapping forKeyPath:@"playlist"];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kGMServerSyncFailedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) {
        
        NSError* error = [notification.userInfo objectForKey:@"rkError"];
        RKObjectLoader* objectLoader = [notification.userInfo objectForKey:@"objectLoader"];
        
        MFMailComposeViewController* mail = [[MFMailComposeViewController alloc] init];
        [mail setToRecipients:[NSArray arrayWithObject:@"juliusparishy@gmail.com"]];
        [mail setMailComposeDelegate:self];
        [mail setSubject:@"Sync error info"];
        
        NSString* xt = nil;    
        NSMutableString* cookiesHeader = [NSMutableString string];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary* cookies = [defaults objectForKey:@"GMCookies"];
        if(cookies != nil)
        {
            for(NSString* key in [cookies allKeys])
            {
                [cookiesHeader appendFormat:@"%@=%@;", key, [cookies objectForKey:key]];
                
                if([key isEqualToString:@"xt"])
                {
                    xt = [cookies valueForKey:key];
                }
            }
        }
        
        NSMutableString* cookiesString = [NSMutableString string];
        
        for(NSHTTPCookie* cookie in objectLoader.response.cookies)
        {
            [cookiesString appendFormat:@"%@=%@\n", cookie.name, cookie.value];
        }
        
        NSString* body = [NSString stringWithFormat:@"%@\nSession cookie:%@\nCookies:%@\nResponse Cookies:\n%@\nMIME Type:%@\nBody:\n\n%@", [error localizedDescription], xt, cookiesString, cookiesHeader, objectLoader.response.MIMEType, objectLoader.response.bodyAsString];
        [mail setMessageBody:body isHTML:NO];
        
        [self.tabBarController.selectedViewController presentModalViewController:mail animated:YES];
        [mail release];
    }];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
    NSString* message = @"Message sent.";
    if(result != MFMailComposeResultSent)
    {
        message = @"Message not sent.";
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Mail" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [self.tabBarController.selectedViewController dismissModalViewControllerAnimated:YES];
}

-(IBAction)togglePlaylistViewVisible
{
    UIViewController* viewController = self.tabBarController.selectedViewController;
    UIView* view = viewController.view;
    
    if(playlistViewVisible)
    {
        CGRect frame = self.playlistView.frame;
        frame.origin.y += frame.size.height - kToggleButtonSize;
        
        CGRect viewFrame = view.frame;
        viewFrame.size.height = frame.origin.y;
        
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.playlistView.frame = frame;
            view.frame = viewFrame;
        }];
        
        playlistViewVisible = NO;
    }
    else
    {
        CGRect frame = self.playlistView.frame;
        frame.origin.y -= frame.size.height - kToggleButtonSize;
        
        CGRect viewFrame = view.frame;
        viewFrame.size.height = frame.origin.y;
        
        [UIView animateWithDuration:0.5f animations:^(void) {
            self.playlistView.frame = frame;
            view.frame = viewFrame;
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

-(IBAction)previousSong
{
    [playlistManager playPreviousSong];
}

-(IBAction)nextSong
{
    [playlistManager playNextSong];
}

-(void)playlistManagerDidPlayItem:(GMPlaylistItem*)item resuming:(BOOL)resuming
{
    self.playPauseButton.selected = YES;
    //[self.playlistViewToggleButton setTitle:[NSString stringWithFormat:@"Playing '%@'", item.song.title] forState:UIControlStateNormal];
    
    self.songLabel.text = item.song.title;
    self.albumLabel.text = item.song.album;
    self.artistLabel.text = item.song.artist;
}

-(void)playlistManagerDidPauseItem:(GMPlaylistItem*)item
{
    self.playPauseButton.selected = NO;
    //[self.playlistViewToggleButton setTitle:[NSString stringWithFormat:@"Paused '%@'", item.song.title] forState:UIControlStateNormal];
}

-(void)playlistManagerDidFinishPlayingItem:(GMPlaylistItem*)item
{
    self.playPauseButton.selected = NO;
    //[self.playlistViewToggleButton setTitle:@"No Song Playing" forState:UIControlStateNormal];
    self.songLabel.text = @"No song playing.";
    self.albumLabel.text = @"";
    self.artistLabel.text = @"";
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
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* googleAuthCookies = [NSMutableArray array];
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for(NSHTTPCookie* cookie in cookies)
    {
        if([cookie.domain rangeOfString:@".google.com"].location != NSNotFound)
        {
#ifdef DEBUG_PRINT_VERBOSE
            NSLog(@"Cookie: %@", cookie.name);
            NSLog(@"\tValue: %@", cookie.value);
            NSLog(@"\tDomain: %@", cookie.domain);
#endif
            
            [googleAuthCookies addObject:cookie];
        }
    }
    
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:googleAuthCookies] forKey:@"GoogleAuthCookies"];
    [defaults synchronize];
    
    NSLog(@"Saved cookeis from current session.");
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
    
    /*
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for(NSHTTPCookie* cookie in cookies)
    {
        NSLog(@"Cookie: %@", cookie.name);
        NSLog(@"\tValue: %@", cookie.value);
        NSLog(@"\tPath: %@", cookie.path);
        NSLog(@"\tDomain: %@", cookie.domain);
    } */
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
    
    [self adjustViewControllerForPlaylistView:viewController];
}

-(void)adjustViewControllerForPlaylistView:(UIViewController *)viewController
{
    // Fix the frame of the current view
    UIView* view = viewController.view;
    
    CGRect frame = self.playlistView.frame;
    
    CGRect viewFrame = view.frame;
    viewFrame.size.height = frame.origin.y;
    view.frame = viewFrame;
    
    [view setNeedsLayout];
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
