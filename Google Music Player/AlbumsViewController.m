//
//  AlbumsViewController.m
//  Google Music Player
//
//  Created by Julius Parishy on 7/29/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import "AlbumsViewController.h"

#import "GMAlbum.h"
#import "GMArtist.h"
#import "GMServerSync.h"

#import "SongsViewController.h"

@implementation AlbumsViewController

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

-(void)setupIndices
{
    [indices release];
    indices = [[NSMutableDictionary alloc] init];
    
    //  int count = [songCache.artists count];
    
    
    for(GMAlbum* album in songCache.albums)
    {
        if([album.title isEqualToString:@""])
            continue;
        
        NSString* key = [NSString stringWithFormat:@"%c", [[album.title capitalizedString] characterAtIndex:0]];
        NSMutableArray* albumsForKey = [indices objectForKey:key];
        if(albumsForKey == nil)
        {
            albumsForKey = [[NSMutableArray alloc] init];
            [indices setObject:albumsForKey forKey:key];
        }
        
        [albumsForKey addObject:[NSNumber numberWithInt:[songCache.albums indexOfObject:album]]];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    
    //int section = indexPath.section;
    //int row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    if(songCache != nil)
    {
        NSMutableArray* sectionIndices = [indices objectForKey:[indicesOrder objectForKey:[NSNumber numberWithInt:indexPath.section]]];
        int index = [[sectionIndices objectAtIndex:indexPath.row] intValue];
        GMAlbum* album = [songCache.albums objectAtIndex:index];
    
        [cell.textLabel setText:album.title];
        
        int songCount = [album.songs count];
        NSString* mod = songCount > 1 ? @"s" : @"";
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ (%i song%@)", album.artist.name, songCount, mod]];
    
        if(album.coverArt != nil)
        {
            [cell.imageView setImage:album.coverArt];
        }
        else
        {
            [cell.imageView setImage:nil];
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongsViewController* songs = [[SongsViewController alloc] initWithNibName:@"SongsViewController" bundle:nil];
   
    NSMutableArray* sectionIndices = [indices objectForKey:[indicesOrder objectForKey:[NSNumber numberWithInt:indexPath.section]]];
    int index = [[sectionIndices objectAtIndex:indexPath.row] intValue];
    GMAlbum* album = [songCache.albums objectAtIndex:index];
    
    [songs setSongs:album.songs];
    [songs setTitle:album.title];
    
    [songs setPlaylistManager:playlistManager];
    [songs setAudioPlayer:audioPlayer];
    
    [self.navigationController pushViewController:songs animated:YES];
    
    [songs release];
}

@end
