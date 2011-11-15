//
//  ArtistsViewController.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GMSongCache.h"
#import "GMSongCacheViewController.h"
#import "GMPlaylistManager.h"
#import "GMAudioPlayer.h"

@class ArtistTableViewCell;

@interface ArtistsViewController : UITableViewController<GMSongCacheViewController> {
    GMSongCache* songCache;
    GMAudioPlayer* audioPlayer;
    GMPlaylistManager* playlistManager;
    
    NSMutableDictionary* indices;
    NSMutableDictionary* indicesOrder;
    NSArray* indicesKeys;
}

@property (nonatomic, retain) IBOutlet ArtistTableViewCell* artistCell;

-(void)setupSongSync;

-(void)syncSongCache;
-(void)setupIndices;

-(void)sortSongs;

@end
