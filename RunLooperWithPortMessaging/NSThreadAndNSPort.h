//
//  NSThreadAndNSPort.h
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/21/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThreadAndNSPort : NSObject
-(void)startTheThread:(NSString*)threadName
         WithSelector:(SEL)threadEntryPoint;
@end


#pragma mark -
#pragma mark SEcondary thread
#pragma mark -

@interface WorkerThread : NSObject
+(void)LaunchNewThread:(NSString*)portName;
@end