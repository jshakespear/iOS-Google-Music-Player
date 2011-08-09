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

@protocol GMPlaylistManagerDelegate <NSObject>

-(void)playlistManagerDidPlayNewSong:(GMSong*)song;

@end

@interface GMPlaylistManager : NSObject {
    GMAudioPlayer* audioPlayer;
    
    NSMutableArray* songs;
    GMSong* currentSong;
    
    NSMutableData* currentResponse;
    
    id<GMPlaylistManagerDelegate> delegate;
    
    GMSong* songToPlay;
}

@property (nonatomic, assign) GMAudioPlayer* audioPlayer;
@property (nonatomic, retain) NSMutableArray* songs;
@property (nonatomic, assign) GMSong* currentSong;

@property (nonatomic, assign) id<GMPlaylistManagerDelegate> delegate;

-(void)playSong:(GMSong*)song;

-(void)downloadStreamInfoForSong:(GMSong*)song;
-(void)parseStreamInfo:(NSString*)streamInfo;

-(void)openStreamAtURL:(NSURL*)url;

@end
