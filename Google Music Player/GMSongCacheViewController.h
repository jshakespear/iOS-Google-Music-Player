//
//  GMSongCacheViewController.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMSongCache.h"
#import "GMAudioPlayer.h"
#import "GMPlaylistManager.h"

@protocol GMSongCacheViewController <NSObject>

-(void)setSongCache:(GMSongCache*)aSongCache;
-(void)setAudioPlayer:(GMAudioPlayer*)anAudioPlayer;
-(void)setPlaylistManager:(GMPlaylistManager*)aPlaylistManager;

@end
