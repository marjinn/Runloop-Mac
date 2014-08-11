//
//  main.m
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/15/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CQMRunLoopPortSource.h"
#import "CQMCFRunLoop.h"
#import "PosixThreadandCFPorts.h"

#import "NSThreadAndNSPort.h"

#import "ThreadSynchorniZations.h"

int main(int argc, const char * argv[])
{
    
    /*
    CQMRunLoopPortSource* cqm = nil;
    cqm = [CQMRunLoopPortSource new];
    
    [NSThread detachNewThreadSelector:@selector(launchThread)
                             toTarget:(id)cqm withObject:nil];
    //[cqm launchThread];
    
    
    //[[NSRunLoop currentRunLoop] run];
    */
    
    
    
    
    /*
    pthread_t* thread =
    (LaunchAPosixThread(NULL));
    
    //after use free
    free((void *)thread);
    
    CQMCFRunLoop* cfRunLoopDmeo = nil;
    cfRunLoopDmeo = [CQMCFRunLoop new];
    
    [cfRunLoopDmeo callMySpawnThread];
    
    */
    
    
    /*
    [[NSThreadAndNSPort new] startTheThread:@"co.axis.of.evil" WithSelector:nil];
    */
    
    demoSYNC();
    
    
     [[NSRunLoop currentRunLoop] run];
    return NSApplicationMain(argc, argv);
}
