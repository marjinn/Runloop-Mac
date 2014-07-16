//
//  CQMRunLoopPortSource.m
//  RunLooper
//
//  Created by mar Jinn on 7/15/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import "CQMRunLoopPortSource.h"

@import CoreFoundation;
//@import Foundation.NSPortMessage;

@interface CQMRunLoopPortSource() <NSPortDelegate/*,NSMachPortDelegate*/>
{}

@property NSPort* myPort;
@property NSPort* myDistantPort;
@end


#pragma mark //-- Primary Threads Class
@implementation CQMRunLoopPortSource

-(void)launchThread
{
    //this method will be called from another thread other than main thread
    @autoreleasepool
    {
       //--1. Create the NSMachPort
    NSPort* port    = nil;
    port            = (NSPort *)[NSMachPort port];
    
    [self setMyPort:port];
    port = nil;
    
    //--2. Install the port as an input source on the current run Loop
    [[NSRunLoop currentRunLoop] addPort:[self myPort]
                                forMode:NSDefaultRunLoopMode];
    
    [[self myPort] setDelegate:(id<NSPortDelegate>)self];
    //[[self myPort] setDelegate:(id<NSMachPortDelegate>)self];
   
    /*
    Configuring an NSMessagePort Object
    To establish a local connection with an NSMessagePort object, you cannot simply pass port objects between threads. Remote message ports must be acquired by name. Making this possible in Cocoa requires registering your local port with a specific name and then passing that name to the remote thread so that it can obtain an appropriate port object for communication. Listing 3-16 shows the port creation and registration process in cases where you want to use message ports.
     *
    NSPort* localPort = [NSMessagePort new];
    
    // Configure the object and add it to the current run loop.
    [localPort setDelegate:self];
    
    [[NSRunLoop currentRunLoop] addPort:localPort forMode:NSDefaultRunLoopMode];
    
    // Register the port using a specific name. The name must be unique.
    NSString* localPortName = [NSString stringWithFormat:@"MyPortName"];
    
    [[NSMessagePortNameServer sharedInstance] registerPort:localPort
                                                      name:localPortName];
    */
     //Detach Worker Thread
    //To avoid selector not found warning
    if (
        [[MyWorkerClass class]
         respondsToSelector:NSSelectorFromString(@"LaunchThreadWithPort:")]
        )
    {
        [NSThread
         detachNewThreadSelector:NSSelectorFromString(@"LaunchThreadWithPort:")
         toTarget:[MyWorkerClass class]
         withObject:[self myPort]];
        
        
    }
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    }
    return;
}

#define kCheckInMessage 100

-(void)handlePortMessage:(NSPortMessage*)portMessage
{
    uint32_t message = 0;
    message              = [portMessage msgid];
    
    NSPort* distantPort = nil;
    
    if (message == kCheckInMessage)
    {
        //Get the worker threads communication port
        distantPort = [portMessage sendPort];
        
        //retain and save the worker port for later use
        [self storeDistantPort:(NSPort *)distantPort];
    }
    else
    {
        //handle othermessages
        
    }
    return;
}

-(void)storeDistantPort:(NSPort*)distantPort
{
    [self setMyDistantPort:distantPort];
}

#pragma mark -
#pragma mark NSMachPortDelegate"

//NSMachPortDelegate
// if implemented this gets priority over "handlePortMessage" of NSPortDelegate
//- (void)handleMachMessage:(void *)msg
//{
//    
//}
@end




#pragma mark //-- Secondary Threads Class
@interface MyWorkerClass() <NSPortDelegate>
{
    
}
@property BOOL shouldExit;
@property NSPort* remotePort;
@end

@implementation MyWorkerClass

+(void)LaunchThreadWithPort:(id)inData
{
    @autoreleasepool
    {
        //Set up the connection between this thread and main thread
        if ([inData isKindOfClass:[NSPort class]])
        {
            NSPort* distantPort = nil;
            distantPort = (NSPort*)inData;
            
            MyWorkerClass* workerObj = nil;
            workerObj = [[self alloc]init];
            
            [workerObj sendCheckInMessage:distantPort];
            
            distantPort = nil;
            
            
            //let the run loop process things
            do
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                         beforeDate:[NSDate distantFuture]];
            }
            while (![workerObj shouldExit]);
            
            workerObj = nil;
        }
    }
    return;
}

-(void)sendCheckInMessage:(NSPort*)outPort
{
    
    //save remote port
    [self setRemotePort:outPort];
    
    //create and configure the worker thread port
    NSPort* myWorkerPort = nil;
    myWorkerPort = [NSMachPort port];
    
    //set port delegate
    [myWorkerPort setDelegate:(id<NSPortDelegate>)self];
    
    //add port to worker threads run loop
    [[NSRunLoop currentRunLoop] addPort:myWorkerPort
                                forMode:NSDefaultRunLoopMode];
    
    //create check in message
    NSPortMessage* messageObj = nil;
    messageObj = [[NSPortMessage alloc]initWithSendPort:outPort
                                            receivePort:myWorkerPort
                                             components:nil];
    
    if (messageObj)
    {
        //finish configuring the message and send it immediatly
        [messageObj setMsgid:kCheckInMessage];
        
        BOOL messageSendSuccess = NO;
        messageSendSuccess =
        [messageObj sendBeforeDate:[NSDate date]];
        
        NSLog(@"%@",messageSendSuccess ? @"Y" : @"N");
        
    }
    return;
}

@end