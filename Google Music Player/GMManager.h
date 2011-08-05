//
//  GMManager.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMAudioPlayer.h"
#import "GMSong.h"

#import "SBJson/SBJson.h"

@protocol GMManagerDelegate <NSObject>

-(void)songsListedSuccessfully;

@end

@interface GMManager : NSObject {

    NSURLConnection* songListConnection; // Gets the list of songs
    NSURLConnection* songStreamInfoConnection; // Gets the song info, ie. stream url
    NSURLConnection* songStreamConnection; // Actually gets the song

    NSMutableData* currentResponse;
    
    NSString* xtValue;
    
    GMAudioPlayer* audioPlayer;
    
    NSMutableArray* songs;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableArray* songs;

-(NSURLConnection*)sendGoogleMusicRequest:(NSString*)path method:(NSString*)method;

-(void)downloadLibrary;
-(void)handleLibrary;

-(void)downloadStreamInfoForSong:(NSString*)songId;
-(void)handleStreamInfo;

-(void)openAudioStreamWithUrl:(NSString*)streamUrl;

-(void)playSong:(GMSong*)song;

@end
