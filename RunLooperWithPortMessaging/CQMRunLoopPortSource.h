//
//  CQMRunLoopPortSource.h
//  RunLooper
//
//  Created by mar Jinn on 7/15/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import <Foundation/Foundation.h>
//@import Foundation;

//-- MAin Threads Class
@interface CQMRunLoopPortSource : NSObject

-(void)launchThread;
@end


//-- Secondary Threads Class
@interface MyWorkerClass : NSObject
{
    
}
+(void)LaunchThreadWithPort:(id)inData;

@end