//
//  NSThreadAndNSPort.m
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/21/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import "NSThreadAndNSPort.h"
@interface NSThreadAndNSPort()<NSPortDelegate>
{
    
}

@property NSThread*     threadLaunchedByThisClass;
@property NSRunLoop*    thisThreadsRunLoop;
@property NSPort*       thisThreadsLocalPort;
@property NSPort*       thisThreadsRemotePort;

@end

@implementation NSThreadAndNSPort

-(NSThread*)LaunchAThread:(NSString*)threadName
{
    NSThread* thelaunchedThread = nil;
    
    thelaunchedThread =
    [[NSThread alloc]initWithTarget:(id)self
                           selector:@selector(ThreadsEntryPoint:)
                             object:nil];
    
    [thelaunchedThread setName:threadName];
    
    return thelaunchedThread;
}

-(void)ThreadsEntryPoint:(id)data
{
    @autoreleasepool
    {
        NS_DURING
        /* Start Thread Specific Code */
        BOOL moreWorkToDo = YES;
        BOOL exitNow = NO;
        
        NSRunLoop* thisThreadsRunLoop = nil;
        thisThreadsRunLoop = [NSRunLoop currentRunLoop];
        
        [self setThisThreadsRunLoop:thisThreadsRunLoop];
        
        // Add the exitNow BOOL to the thread dictionary
        NSMutableDictionary* threadDict = nil;
        threadDict =
        [[NSThread currentThread] threadDictionary];
        
        [threadDict setValue:(id)[NSNumber numberWithBool:exitNow]
                      forKey:@"ThreadShouldExitNB"];
        
        
        NSMessagePort* threadLocalPort = nil;
        threadLocalPort = [NSMessagePort new];
        
        [self setThisThreadsLocalPort:(NSPort *)threadLocalPort];
        
        [threadLocalPort setDelegate:(id<NSPortDelegate>)self];
        
        [[self thisThreadsRunLoop] addPort:(NSPort *)threadLocalPort
                 forMode:NSDefaultRunLoopMode];
        
        NSString* localPortName = nil;
        localPortName = @"thisThreadsLocalPort";
        
        [[NSMessagePortNameServer sharedInstance] registerPort:
         [self thisThreadsLocalPort]
                                                          name:localPortName];
        
        
        
        NS_HANDLER
        @throw localException;
        
        NS_ENDHANDLER
    }
}


#pragma mark - 
#pragma mark NSPortDelegate
#pragma mark -
- (void)handlePortMessage:(NSPortMessage *)message
{
    return;
}


@end
