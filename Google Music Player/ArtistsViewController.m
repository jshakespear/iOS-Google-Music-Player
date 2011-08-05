//
//  ArtistsViewController.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "ArtistsViewController.h"

#import "GMSong.h"
#import "GMServerSync.h"

@implementation ArtistsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)setSongCache:(GMSongCache *)aSongCache
{
    songCache = aSongCache;
}

-(void)setAudioPlayer:(GMAudioPlayer *)anAudioPlayer
{
    audioPlayer = anAudioPlayer;
}

-(void)syncSongCache
{
    [songCache synchronize];
}

-(void)sortSongs
{
   // songs = [songCache.songs sortedArrayUsingComparator:^(id obj1, id obj2) {
   // }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStylePlain target:self action:@selector(syncSongCache)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kGMServerSyncFinishedNotification object:nil queue:nil usingBlock:^(NSNotification* notification) {
        NSLog(@"GMServerSync finished; Refreshing user interface.");
        [self.tableView reloadData];
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(songCache != nil)
    {
        return 1;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(songCache != nil)
    {
        return [songCache.artists count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    if(songCache != nil)
    {
        GMArtist* artist = [songCache.artists objectAtIndex:indexPath.row];
        int numAlbums = [artist.albums count];
        [cell.textLabel setText:artist.name];
        
        NSString* mod = numAlbums > 1 ? @"s" : @"";
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%i album%@", numAlbums, mod]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(songCache != nil && audioPlayer != nil)
    {
        // Play the selected song
    }
}

@end
