//
//  NSThreadAndNSPort.m
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/21/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import "NSThreadAndNSPort.h"
#define kCheckinMessage 100
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
             WithSelector:(SEL)threadEntryPoint
                   object:(id)obj
{
    NSThread* thelaunchedThread = nil;
    
    thelaunchedThread =
    [[NSThread alloc]initWithTarget:(id)self
                           selector:threadEntryPoint
                             object:obj];
    
    [thelaunchedThread setName:threadName];
    
    return thelaunchedThread;
}

#pragma mark -
#pragma mark Primary Thread 

-(void)startTheThread:(NSString*)threadName
         WithSelector:(SEL)threadEntryPoint
{
    NSThread* thread = nil;
    thread = [self LaunchAThread:threadName
                    WithSelector:@selector(ThreadsEntryPoint:)
                          object:nil];
    if (thread)
    {
        [thread start];
    }
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
        thisThreadsRunLoop = nil;
        
        [self setThisThreadsRunLoop:thisThreadsRunLoop];
        
        //-- Add the exitNow BOOL to the thread dictionary
        NSMutableDictionary* threadDict = nil;
        threadDict =
        [[NSThread currentThread] threadDictionary];
        
        [threadDict setValue:(id)[NSNumber numberWithBool:exitNow]
                      forKey:@"ThreadShouldExitNB"];
        
        //--Input Source
        NSMessagePort* threadLocalPort = nil;
        threadLocalPort = [NSMessagePort new];
        
        //--retain local port
        [self setThisThreadsLocalPort:(NSPort *)threadLocalPort];
        threadLocalPort = nil;
        
        //--Input Source handler function will be the NSPortDelegate function
        [[self thisThreadsLocalPort] setDelegate:(id<NSPortDelegate>)self];
        
        //--add input source to runLoop
        [[self thisThreadsRunLoop] addPort:(NSPort *)threadLocalPort
                 forMode:NSDefaultRunLoopMode];
        
        //--name local port
        NSString* localPortName = nil;
        localPortName = @"thisThreadsLocalPort";
        
        //register the NSMessagePort (local port) with the NSMessagePortNameServer
        [[NSMessagePortNameServer sharedInstance] registerPort:
         [self thisThreadsLocalPort]
                                                          name:localPortName];
        
//        while (moreWorkToDo && !exitNow)
//        {
//            // Do one chunk of a larger body of work here.
//            // Change the value of the moreWorkToDo Boolean when done.
//            // Run the run loop but timeout immediately if the input source isn't
//            // waiting to fire.
//            
//            //Any Time Consuming Work Can be Done Here
//        //eg: URL Operations
//            
//            [[self thisThreadsRunLoop] runUntilDate:[NSDate date]];
//            
//            // Check to see if an input source handler changed the exitNow value.
//            exitNow =
//            [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
//        }
        
        //-- LaunchSecondary thread
        SEL secondaryThreadsSelector = nil;
        secondaryThreadsSelector = @selector(LaunchNewThread:);
        
        [NSThread detachNewThreadSelector:secondaryThreadsSelector
                                 toTarget:(id)[WorkerThread class]
                               withObject:localPortName];
        
        
        
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
//    [[[self threadLaunchedByThisClass]threadDictionary]
//     setValue:(id)[NSNumber numberWithBool:YES]
//                                                          forKey:@"ThreadShouldExitNow"];
    
    
    unsigned int mes__sage = [message msgid];
    NSPort* distantPort = nil;
    if (mes__sage == kCheckinMessage)
    {
        // Get the worker thread’s communications port.
        distantPort = [message sendPort];
        // Retain and save the worker port for later use.
        //[self storeDistantPort:distantPort];
    }
    else {
        // Handle other messages.
    }
    
    return;
}





@end



#pragma mark -
#pragma mark SEcondary thread
#pragma mark -
@interface WorkerThread()<NSPortDelegate>
{

}
//-When Work is doen this iVar shoudl be set to YES
//- This will exit The runLOOP and hence the thread
@property BOOL shouldExit;
@property NSString* remotePortName;
@end

@implementation WorkerThread

+(void)LaunchNewThread:(NSString*)portName
{
    @autoreleasepool
    {
        NS_DURING
        
        //-- Get Launcher Threads Local Port
        //-- This will be Worker threads remote port
        NSMessagePort* remotePortSecondary = nil;
        remotePortSecondary = (NSMessagePort*)
        [[NSMessagePortNameServer sharedInstance] portForName:portName];
        
        
        //-- Send Check In message To notify the primary thread
        WorkerThread* myWorkerClass = nil;
        myWorkerClass = [WorkerThread new];
        
        [myWorkerClass sendCheckinMessage:portName];
        remotePortSecondary = nil;
        
        //-- Start the Run LOOP
        do
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate distantFuture]];
        }
        while (![myWorkerClass shouldExit]);
        
        NS_HANDLER
         @throw localException;
        
        NS_ENDHANDLER
    }
    
    return;
}

#pragma mark -
#pragma mark NSPortDelegate
#pragma mark -
- (void)handlePortMessage:(NSPortMessage *)message
{
    
    return;
}

-(void)sendCheckinMessage:(NSString*)outPortName
{
    NSMessagePort* outPort = nil;
    outPort = (NSMessagePort*)
    [[NSMessagePortNameServer sharedInstance] portForName:outPortName];
    
    [self setValue:(id)outPort forKey:@"remotePortName"];
    
    //Create the worker thraeds local port
    NSMessagePort* workerThreadLocalPort = nil;
    workerThreadLocalPort = (NSMessagePort*)
    [NSMessagePort port];
    
    [[NSMessagePortNameServer sharedInstance] registerPort:(NSPort *)workerThreadLocalPort
                                                      name:(NSString *)@"workerThreadLocalPort"];
    
    [workerThreadLocalPort setDelegate:(id<NSPortDelegate>)self];
    
    [[NSRunLoop currentRunLoop] addPort:workerThreadLocalPort
                                forMode:NSDefaultRunLoopMode];
    
    
    //Create the check-in message
    NSPortMessage* messageObj = nil;
    messageObj =
    [[NSPortMessage alloc]initWithSendPort:(NSPort *)outPort receivePort:(NSPort *)workerThreadLocalPort components:nil];
    
    if(messageObj)
    {
        //finish configuring the message and send it immediately
        [messageObj setMsgid:(uint32_t)kCheckinMessage];
        
        [messageObj sendBeforeDate:[NSDate date]];
    }
    
    return;
}

@end