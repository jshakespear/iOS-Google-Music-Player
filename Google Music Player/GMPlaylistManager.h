//
//  GMPlaylistManager.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/30/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMSong.h"
#import "GMAudioPlayer.h"

@interface GMPlaylistManager : NSObject {
    GMAudioPlayer* audioPlayer;
    
    NSMutableArray* songs;
    
    NSMutableData* currentResponse;
}

@property (nonatomic, assign) GMAudioPlayer* audioPlayer;
@property (nonatomic, retain) NSMutableArray* songs;

-(void)playSong:(GMSong*)song;

-(void)downloadStreamInfoForSong:(GMSong*)song;
-(void)parseStreamInfo:(NSString*)streamInfo;

-(void)openStreamAtURL:(NSURL*)url;

@end
