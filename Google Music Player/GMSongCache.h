//
//  GMSongCache.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMSong.h"
#import "GMArtist.h"
#import "GMAlbum.h"

@class GMServerSync;

@interface GMSongCache : NSObject {
    NSArray* songs;
    NSArray* albums;
    NSArray* artists;
    
    GMServerSync* serverSync;
}

@property (nonatomic, retain) NSArray* songs;
@property (nonatomic, retain) NSArray* artists;
@property (nonatomic, retain) NSArray* albums;

-(void)synchronize;
-(void)loadFromLocalStore;

-(void)setupCache;

-(void)postSynchronizedNotification;

-(void)retrieveCoverArt; // Retrieve because it might download it or find it in the cache yo

-(GMAlbum*)albumForSong:(GMSong*)song;

@end
