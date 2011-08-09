//
//  GMAudioPlayer.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/28/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "GMAudioPlayer.h"

@interface GMAudioPlayer ()

-(void)audioStreamerStateChanged:(NSNotification*)aNotification;

@end

@implementation GMAudioPlayer

@synthesize delegate;

-(id)init
{
    if((self = [super init]) != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioStreamerStateChanged:) name:ASStatusChangedNotification object:nil];
    }
    
    return self;
}

-(void)playStreamWithURL:(NSURL*)streamURL
{
    [audioStreamer stop];
    [audioStreamer release];
    audioStreamer = [[AudioStreamer alloc] initWithURL:streamURL];
}

-(void)play
{
    if(audioStreamer != nil)
    {
        if(audioStreamer.state != AS_PLAYING)
        {
            [audioStreamer start];
        }
    }
}

-(void)pause
{
    if(audioStreamer != nil)
    {
        if(audioStreamer.state != AS_PAUSED)
        {
            [audioStreamer pause];
        }
    }
}

-(void)stop
{
    if(audioStreamer != nil)
    {
        if(audioStreamer.state != AS_STOPPED && audioStreamer.state != audioStreamer.state != AS_STOPPING)
        {
            [audioStreamer stop];
        }
    }
}

-(BOOL)playing
{
    return audioStreamer.isPlaying;
}

-(BOOL)paused
{
    return audioStreamer.isPaused;
}

-(void)audioStreamerStateChanged:(NSNotification*)aNotification
{
    switch (audioStreamer.state) {
        case AS_PLAYING:
            [delegate audioPlayerStartedPlaying];
            break;
            
        case AS_PAUSED:
            [delegate audioPlayerPaused];
            break;
            
        case AS_STOPPED:
            [delegate audioPlayerStopped];
            break;
            
        default:
            break;
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [audioStreamer release];
    [super dealloc];
}

@end
