//
//  GMAudioPlayer.h
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "AudioStreamer.h"

/*
 * GMAudioPlayerDelegate
 * Receives notifications when a song is played, paused,
 * stopped, or finished playing.
 */

@class GMAudioPlayer;

@protocol GMAudioPlayerDelegate <NSObject>

@required
-(void)audioPlayerStartedPlaying;
-(void)audioPlayerPaused;
-(void)audioPlayerStopped;
-(void)audioPlayerFinished;

@end

/*
 * GMAudioPlayer
 * Streams audio from an HTTP stream that Google Music supplies.
 */

@interface GMAudioPlayer : NSObject {
    AudioStreamer* audioStreamer;
    
    AVPlayer* player;
    //AVQueuePlayer* queuePlayer;
    
    id<GMAudioPlayerDelegate> delegate;
}

@property (nonatomic, assign) id<GMAudioPlayerDelegate> delegate;

-(void)playStreamWithURL:(NSURL*)streamURL;

-(void)play;
-(void)pause;
-(void)stop;

-(BOOL)playing;
-(BOOL)paused;

@end
