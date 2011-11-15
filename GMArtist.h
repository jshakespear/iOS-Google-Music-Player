//
//  GMArtist.h
//  Google Music Player
//
//  Created by Julius Parishy on 8/22/11.
//  Copyright 2011 DiDev Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMArtist : NSObject

@property (nonatomic, retain) NSString* name;

@property (nonatomic, assign) NSArray* songs;
@property (nonatomic, retain) NSArray* albums;

@end
