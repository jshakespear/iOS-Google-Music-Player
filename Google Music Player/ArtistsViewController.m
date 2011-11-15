//
//  ArtistsViewController.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "ArtistsViewController.h"

#import "GMSong.h"
#import "GMAlbum.h"
#import "GMArtist.h"
#import "GMServerSync.h"

#import "ArtistAlbumsViewController.h"
#import "ArtistTableViewCell.h"

@implementation ArtistsViewController

@synthesize artistCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    [indices release];
    [indicesOrder release];
    [indicesKeys release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)setSongCache:(GMSongCache *)aSongCache
{
    if(songCache == nil)
    {
        songCache = aSongCache;
        
        [self setupSongSync];
    }
}

-(void)setAudioPlayer:(GMAudioPlayer *)anAudioPlayer
{
    audioPlayer = anAudioPlayer;
}

-(void)setPlaylistManager:(GMPlaylistManager *)aPlaylistManager
{
    playlistManager = aPlaylistManager;
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

-(void)setupIndices
{
    [indices release];
    indices = [[NSMutableDictionary alloc] init];
    
  //  int count = [songCache.artists count];
    
    
    for(GMArtist* artist in songCache.artists)
    {
        if([artist.name isEqualToString:@""])
            continue;
        
        NSString* key = [NSString stringWithFormat:@"%c", [[artist.name capitalizedString] characterAtIndex:0]];
        NSMutableArray* artistsForKey = [indices objectForKey:key];
        if(artistsForKey == nil)
        {
            artistsForKey = [[NSMutableArray alloc] init];
            [indices setObject:artistsForKey forKey:key];
        }
        
        [artistsForKey addObject:[NSNumber numberWithInt:[songCache.artists indexOfObject:artist]]];
    } 
    
    // Now order the keys
    
    [indicesOrder release];
    indicesOrder = [[NSMutableDictionary alloc] init];
    
    NSArray* orderedKeys = [[indices allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    indicesKeys = [orderedKeys retain];
    
    for(int i = 0; i < [orderedKeys count]; ++i)
    {
        [indicesOrder setObject:[[orderedKeys objectAtIndex:i] copy] forKey:[NSNumber numberWithInt:i]];
    }
}

-(void)setupSongSync
{
    [[NSNotificationCenter defaultCenter] addObserverForName:kGMServerSyncFinishedNotification object:nil queue:nil usingBlock:^(NSNotification* notification) {
        NSLog(@"GMServerSync finished; Refreshing user interface.");
        
        [self setupIndices];
        [self.tableView reloadData];
    }];
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
    
  //  artistCell = [[ArtistTableViewCell alloc] init];
   // [[NSBundle mainBundle] loadNibNamed:@"ArtistL owner:<#(id)#> options:<#(NSDictionary *)#>
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

-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indicesKeys;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(artistCell != nil)
    {
        return artistCell.frame.size.height;
    }
    
    return 164.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(songCache != nil)
    {
        return [indices count];
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(songCache != nil)
    {
        return [[indices objectForKey:[indicesOrder objectForKey:[NSNumber numberWithInt:section]]] count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ArtistTableViewCell *cell = (ArtistTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[ArtistTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        [[NSBundle mainBundle] loadNibNamed:@"ArtistTableViewCell" owner:self options:nil];
        
        cell = self.artistCell;
        self.artistCell = nil;
    }
    
    // Configure the cell...
    
    if(songCache != nil)
    {
        NSMutableArray* sectionIndices = [indices objectForKey:[indicesOrder objectForKey:[NSNumber numberWithInt:indexPath.section]]];
        int index = [[sectionIndices objectAtIndex:indexPath.row] intValue];
        GMArtist* artist = [songCache.artists objectAtIndex:index];
        
        int numAlbums = [artist.albums count];
        [cell.artistName setText:artist.name];
        
        NSString* mod = numAlbums > 1 ? @"s" : @"";
        [cell.songCount setText:[NSString stringWithFormat:@"%i album%@", numAlbums, mod]];
        
        GMAlbum* firstAlbum = [artist.albums objectAtIndex:0];
        if(firstAlbum.coverArt != nil)
        {
            [cell.coverArt setImage:firstAlbum.coverArt];
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* sectionIndices = [indices objectForKey:[indicesOrder objectForKey:[NSNumber numberWithInt:indexPath.section]]];
    int index = [[sectionIndices objectAtIndex:indexPath.row] intValue];
    GMArtist* artist = [songCache.artists objectAtIndex:index];
    
    ArtistAlbumsViewController* artistAlbums = [[ArtistAlbumsViewController alloc] initWithNibName:@"ArtistAlbumsViewController" bundle:nil];
    [artistAlbums setArtist:artist];
    [artistAlbums setPlaylistManager:playlistManager];
    
    [self.navigationController pushViewController:artistAlbums animated:YES];
    
    [artistAlbums release];
}

@end
