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
        
        //queuePlayer = [[AVQueuePlayer alloc] init];
        
        player = [[AVPlayer alloc] init];
        [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:0];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        NSError *setCategoryError = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
        if (setCategoryError) { /* handle the error condition */ }
        
        NSError *activationError = nil;
        [audioSession setActive:YES error:&activationError];
        if (activationError) { /* handle the error condition */ }
    }
    
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == player)
    {
        if([keyPath isEqualToString:@"status"])
        {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
            if(status == AVPlayerStatusUnknown)
            {
                NSLog(@"Status: Unknown");
            }
            else if(status == AVPlayerStatusReadyToPlay)
            {
                NSLog(@"Status: ReadyToPlay");
            }
            else if(status == AVPlayerStatusFailed)
            {
                NSError* error = [player error];
                NSLog(@"An error occurred! Message: %@", [error localizedDescription]);
            }
        }
    }
}

-(void)playStreamWithURL:(NSURL*)streamURL
{
    /*
    [audioStreamer stop];
    [audioStreamer release];
    audioStreamer = [[AudioStreamer alloc] initWithURL:streamURL]; */
    
    /*
    [queuePlayer pause];
    [queuePlayer removeAllItems];
    
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:streamURL];
    [queuePlayer insertItem:playerItem afterItem:nil];
    
    [queuePlayer play];*/
    
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:streamURL];
    [player replaceCurrentItemWithPlayerItem:playerItem];
    
    [player play];
    [self.delegate audioPlayerStartedPlaying];
}

-(void)play
{
    /*
    if(audioStreamer != nil)
    {
        if(audioStreamer.state != AS_PLAYING)
        {
            [audioStreamer start];
        }
    } */
    
    if(![self playing])
    {
        [player play];
        [self.delegate audioPlayerStartedPlaying];
    }
}

-(void)pause
{
    /*
    if(audioStreamer != nil)
    {
        if(audioStreamer.state != AS_PAUSED)
        {
            [audioStreamer pause];
        }
    } */
    
    if(![self paused])
    {
        [player pause];
        [self.delegate audioPlayerPaused];
    }
}

-(void)stop
{
    /*
    if(audioStreamer != nil)
    {
        if(audioStreamer.state != AS_STOPPED && audioStreamer.state != audioStreamer.state != AS_STOPPING)
        {
            [audioStreamer stop];
        }
    } */
    
    [self pause];
}

-(BOOL)playing
{
    //return audioStreamer.isPlaying;
    return (player.rate != 0.0);
}

-(BOOL)paused
{
    //return audioStreamer.isPaused;
    return (player.rate == 0.0);
}

/*
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
} */

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //[queuePlayer release];
    
    [super dealloc];
}

@end
