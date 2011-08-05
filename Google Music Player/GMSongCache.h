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

@interface GMSongCache : NSObject {
    NSArray* songs;
    NSArray* albums;
    NSArray* artists;
}

@property (nonatomic, retain) NSArray* songs;
@property (nonatomic, retain) NSArray* artists;
@property (nonatomic, retain) NSArray* albums;

-(void)synchronize;

@end
