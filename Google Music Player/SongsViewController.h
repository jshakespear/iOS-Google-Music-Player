//
//  SongsViewController.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GMSongCache.h"
#import "GMSongCacheViewController.h"
#import "GMAudioPlayer.h"

@interface SongsViewController : UITableViewController<GMSongCacheViewController> {
    GMSongCache* songCache;
    GMAudioPlayer* audioPlayer;
    GMPlaylistManager* playlistManager;
    
    NSMutableDictionary* indices;
    NSMutableDictionary* indicesOrder;
    NSArray* indicesKeys;
    
    BOOL useSongCache;
}

//  Set if you want to use a custom array, otherwise it will use the GMSongCache if it's set
@property (nonatomic, retain) NSArray* songs;

-(void)setupSongSync;

-(void)syncSongCache;
-(void)setupIndices;

@end
