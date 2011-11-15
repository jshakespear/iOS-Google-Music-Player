//
//  GMServerSync.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RestKit/RestKit.h>

#import "GMSong.h"
#import "GMSongCache.h"

/*
 * Syncronizes a GMSongCache object with the
 * the songs on the Google Music server
 * 
 * Should be called from the GMSongCache object
 * when logged in, or when requested by user.
 *
 * All view controllers conforming to GMSongCacheViewController
 * should have access to the GMSongCache, which can
 * then be requested to sync.
 */

#define kGMServerSyncFinishedNotification (@"kGMServerSyncFinishedNotification")
#define kGMServerSyncFailedNotification (@"kGMServerSyncFailedNotification")

@interface GMServerSync : NSObject<RKObjectLoaderDelegate> {
    GMSongCache* songCache;
}

@property (nonatomic, assign) GMSongCache* songCache;

-(void)synchronize;

@end
