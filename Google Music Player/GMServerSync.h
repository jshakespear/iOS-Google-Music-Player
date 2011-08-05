//
//  GMServerSync.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface GMServerSync : NSObject {
    GMSongCache* songCache;
    
    NSMutableData* responseData;
    
    NSDate* downloadStartTime;
    NSDate* downloadEndTime;
    NSDate* parseStartTime;
    NSDate* parseEndTime;
}

@property (nonatomic, assign) GMSongCache* songCache;

-(void)synchronize;

-(void)parseData;

-(NSArray*)sortSongsAlphabetically:(NSArray*)unorderedSongs;

-(void)sort;

@end
