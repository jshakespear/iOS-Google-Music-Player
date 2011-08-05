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

#import "GMAudioPlayer.h"

@interface ArtistsViewController : UITableViewController<GMSongCacheViewController> {
    GMSongCache* songCache;
    GMAudioPlayer* audioPlayer;
}

-(void)syncSongCache;

-(void)sortSongs;

@end
