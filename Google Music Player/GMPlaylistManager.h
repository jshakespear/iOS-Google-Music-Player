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
#import "GMPlaylistItem.h"

/*
 * GMPlaylistManager
 *
 * Manages the currently playing songs. Playlist here refers to songs
 * being played, not playlists stored on GM's servers.
 */

@protocol GMPlaylistManagerDelegate <NSObject>

-(void)playlistManagerDidPlayItem:(GMPlaylistItem*)song resuming:(BOOL)resuming;
-(void)playlistManagerDidPauseItem:(GMPlaylistItem*)song;
-(void)playlistManagerDidFinishPlayingItem:(GMPlaylistItem*)song;

@end

@interface GMPlaylistManager : NSObject<GMAudioPlayerDelegate> {
    GMAudioPlayer* audioPlayer;
    
    
    NSMutableArray* items;
    GMPlaylistItem* currentItem;
    
    NSMutableData* currentResponse;
    
    id<GMPlaylistManagerDelegate> delegate;
    
    GMSong* songToPlay;
    
    AudioStreamerState lastStreamerState;
}

@property (nonatomic, assign) GMAudioPlayer* audioPlayer;
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, retain) GMPlaylistItem* currentItem;

@property (nonatomic, assign) id<GMPlaylistManagerDelegate> delegate;

-(void)playSong:(GMSong*)song;
-(void)playItem:(GMPlaylistItem*)item;

/*
 * Why are these here you ask? I dunno, songs/items keeps getting confusing,
 * they just call the item versions.
 */
-(void)playNextSong;
-(void)playPreviousSong;

-(void)playNextItem;
-(void)playPreviousItem;

-(BOOL)isFinished;

-(void)setItemsWithSongs:(NSArray*)songs firstIndex:(int)index;

-(void)downloadStreamInfoForSong:(GMSong*)song;
-(void)parseStreamInfo:(NSString*)streamInfo;

-(void)openStreamAtURL:(NSURL*)url;

-(void)registerForAudioStreamerStateChanges;

@end
