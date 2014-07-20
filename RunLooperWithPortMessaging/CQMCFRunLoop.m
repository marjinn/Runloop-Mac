//
//  CQMCFRunLoop.m
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/17/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import "CQMCFRunLoop.h"
@import CoreFoundation;

#include <pthread.h>

@implementation CQMCFRunLoop

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


-(void)callMySpawnThread
{
    MySpawnThread();
    return;
    
}

/*
//-- Core Foundation

 1. Launch a  new Thread
 2. Create a new Port - worker threda needs port name
 */
 
/**/


#define kThreadStackSize     (8*4096)
/*
 Table 2-1  Thread creation costs
 Item
 Approximate cost
 Notes
 Kernel data structures
 Approximately 1 KB
 This memory is used to store the thread data structures and attributes, much of which is allocated as wired memory and therefore cannot be paged to disk.
 
 Stack space
 512 KB (secondary threads)
 8 MB (OS X main thread)
 1 MB (iOS main thread)
 The minimum allowed stack size for secondary threads is 16 KB and the stack size must be a multiple of 4 KB. The space for this memory is set aside in your process space at thread creation time, but the actual pages associated with that memory are not created until they are needed.
 
 Creation time
 Approximately 90 microseconds
 This value reflects the time between the initial call to create the thread and the time at which the thread’s entry point routine began executing. The figures were determined by analyzing the mean and median values generated during thread creation on an Intel-based iMac with a 2 GHz Core Duo processor and 1 GB of RAM running OS X v10.5.
 */



OSStatus MySpawnThread(void)
{
    OSStatus returnStatus           = 0;
    
    
    
    
    //runLoopSource
    CFRunLoopSourceRef rlSource    = NULL;
    
    //messagePortContext
    /*
    typedef struct {
        CFIndex	version;
        void *	info;
        const void *(*retain)(const void *info);
        void	(*release)(const void *info);
        CFStringRef	(*copyDescription)(const void *info);
    } CFMessagePortContext;
*/
    CFMessagePortContext context;
    context.version         = 0; /* Must be Zero as per Doc */
    context.info            = NULL; /* Custom data */
    context.retain          = NULL;
    context.release         = NULL;
    context.copyDescription = NULL;
    
    //ShoudlFree
    Boolean shouldFreeInfo = false;
    
    //port Name
    CFStringRef myPortName          = NULL;
    /*
     CF_EXPORT
     CFStringRef CFStringCreateWithFormat(CFAllocatorRef alloc, CFDictionaryRef formatOptions, CFStringRef format, ...) CF_FORMAT_FUNCTION(3,4);
     */
    myPortName =
    CFStringCreateWithFormat
    (
        CFAllocatorGetDefault(),
        NULL,
        CFSTR("com.myapp.MainThread")
     );
    
    //port
    CFMessagePortRef myPort         = NULL;
    /*
     CF_EXPORT CFMessagePortRef	CFMessagePortCreateLocal(CFAllocatorRef allocator, CFStringRef name, CFMessagePortCallBack callout, CFMessagePortContext *context, Boolean *shouldFreeInfo);
     */
    myPort =
    CFMessagePortCreateLocal
    (
        CFAllocatorGetDefault(),
        myPortName,
        (CFMessagePortCallBack)&CFMessagePortCallBack_MainThread ,
        (CFMessagePortContext*)&context,
        (Boolean *)&shouldFreeInfo
     );

    if(myPort != NULL)
    {
        //Create run looop source
        /*
         CF_EXPORT CFRunLoopSourceRef	CFMessagePortCreateRunLoopSource(CFAllocatorRef allocator, CFMessagePortRef local, CFIndex order);
         */
        rlSource = CFMessagePortCreateRunLoopSource(NULL, myPort, 0);
        
        if (rlSource)
        {
            //Add the source to current Run Loop
            CFRunLoopAddSource(
                               CFRunLoopGetCurrent(),
                               rlSource,
                               kCFRunLoopDefaultMode
                               );
            
            //free Port and rlSource
            CFRelease((CFTypeRef)myPort);
            CFRelease((CFTypeRef)rlSource);
        }
      
    }
    
    //Create the thread
    //MPTaskID  taskID;
    
    //returnStatus =
    //Apple's Example uses MP - Carbons MultiProcessing Framework methods
    //which are depricated
    ///The thread needs to be launched using POSIX API or NSThread
    
    //POSIX THreads
    //Steps
    //-----
    /*
     1. Include pthreed.h
     2. Initilaize pthread_attr_t structure
            using pthread_attr_init(pthread_attr_t *)
     3. Set the threads detach state ie either detached  or joined
        pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
     4.Create the thread
            pthread_create(&posixThreadID, &attr,
                    &PosixThreadMainRoutine, NULL);
     5. ALSO supply a function that the thread will run
     7. Destroy the pthread_attr_t structure
                pthread_attr_destroy(&attr);
     
     */
    
    /* int pthread_attr_init(pthread_attr_t *); */
    /* 0 - Success */
    pthread_attr_t attr;
    int thread_attr_init_rval = INT_MAX;
    thread_attr_init_rval = pthread_attr_init((pthread_attr_t *)&attr);
    
    int thread_detach_state_rval = INT_MAX;
    if (thread_attr_init_rval == 0)
    {
        /* int pthread_attr_setdetachstate(pthread_attr_t *, int); */
        thread_detach_state_rval =
        pthread_attr_setdetachstate(
                                    (pthread_attr_t *)&attr,
                                    PTHREAD_CREATE_DETACHED
                                    );
        
        int thread_create_rval = INT_MAX;
        pthread_t posix_thread_ID;
        if (thread_detach_state_rval == 0)
        {
            /* 
             int pthread_create(pthread_t * __restrict, const pthread_attr_t * __restrict,
             void *(*)(void *), void * __restrict);
             */
//            static void* dataArray[2] ;
//            dataArray[0] = (void*)myPortName;
//            dataArray[1] = (void*)&posix_thread_ID;
            
            
            thread_create_rval =
            pthread_create(
                           (pthread_t *)&posix_thread_ID,
                           (const pthread_attr_t *)&attr,
                           (void *(*)(void *))&PosixThreadMainRoutine,
                           (void*)myPortName);
        
            int thread_attr_destroy_rval = INT_MAX;
            if (thread_create_rval == 0)
            {
                pthread_setname_np("com.app.secondary_thread");
                
                /* int pthread_attr_destroy(pthread_attr_t *); */
                thread_attr_destroy_rval =
                pthread_attr_destroy((pthread_attr_t *)&attr);
                if (thread_attr_destroy_rval)
                {
                    //TDB
                
                }//thread_attr_destroy_rval
            
            }//thread_create_rval
            else
            {
                //Report Thread Creation Error
            }
        
        }//thread_detach_state_rval
        
    }//thread_attr_init_rval
    
    
   
    
    return returnStatus;
}

CFDataRef CFMessagePortCallBack_MainThread(
                                           CFMessagePortRef local,
                                           SInt32 msgid,
                                           CFDataRef data,
                                           void *info
                                           )
{
    
#define kCheckinMessage 100
    
    if (msgid == kCheckinMessage)
    {
        CFMessagePortRef messagePort = NULL;
        CFStringRef threadPortName = NULL;
        
        CFIndex bufferLength = INT_MAX;
        bufferLength = CFDataGetLength(data);
        
        UInt8* buffer = NULL;
        buffer =
        CFAllocatorAllocate
        (NULL,bufferLength,0);
        
        CFDataGetBytes(data, CFRangeMake(0, bufferLength), buffer);
        
        threadPortName =
        CFStringCreateWithBytes
        (NULL,
         buffer,
         bufferLength,
         kCFStringEncodingASCII,
         false);
        
        //get remote port with its name
        messagePort =
        CFMessagePortCreateRemote(NULL, (CFStringRef)threadPortName);
        
        if (messagePort)
        {
            /*
             // Retain and save the thread’s comm port for future reference.
             AddPortToListOfActiveThreads(messagePort);
             // Since the port is retained by the previous function, release
             // it here.
             CFRelease(messagePort);
             */
        }
        
        //Clean Up
        CFRelease(threadPortName);
        CFAllocatorDeallocate(NULL, (void*)buffer);

    }
    
    else
    {
        //PRocess Other Messages
    }
    
    return NULL;
}

void PosixThreadMainRoutine(void* data)
{
    //Create the remote port to the main thread.
    
    CFStringRef portName = NULL;
    portName = (CFStringRef)data;
    
    /* 
     Returns a CFMessagePort object connected to a remote port.
     This method is not available on iOS 7 and later—it will return NULL 
     and log a sandbox violation in syslog. 
     See Concurrency Programming Guide for possible replacement technologies.
     Parameters
 */
    CFMessagePortRef mainThreadRemotePort = NULL;
    mainThreadRemotePort =
    CFMessagePortCreateRemote(NULL, portName);
    
    //free the string that was passed
    CFRelease(portName);
    
    //Create a port for the worker thread
    CFStringRef localPortName = NULL;
    localPortName =
    CFStringCreateWithFormat(NULL, NULL, CFSTR("com.thisApp.Thread-%d"),INT_MAX);
    
    //Store the remote port object  in this thraed's context info for later reference
    /*
     typedef struct {
     CFIndex	version;
     void *	info;
     const void *(*retain)(const void *info);
     void	(*release)(const void *info);
     CFStringRef	(*copyDescription)(const void *info);
     } CFMessagePortContext;
     */
    CFMessagePortContext messagePortContext;
    messagePortContext.version          = 0;
    messagePortContext.info             = (void*)mainThreadRemotePort;
    messagePortContext.retain           = NULL;
    messagePortContext.release          = NULL;
    messagePortContext.copyDescription  = NULL;
    
    Boolean shouldFreeInfo  = false;
    Boolean shouldAbort     = true;
    
    CFMessagePortRef myLocalPort = NULL;
    myLocalPort =
    CFMessagePortCreateLocal
    (
        NULL,
        localPortName,
        (CFMessagePortCallBack) &CFMessagePortCallBack_RemoteThread_LocalPort,
        (CFMessagePortContext *)&messagePortContext,
        (Boolean *)&shouldFreeInfo
     );
    
    if (shouldFreeInfo)
    {
        //Couldn't create the local Port So exit the thread
        pthread_exit(NULL);
        
    }
    
    CFRunLoopSourceRef rlSource = NULL;
    rlSource =
    CFMessagePortCreateRunLoopSource
    (NULL, myLocalPort, 0);
    
    if (!rlSource)
    {
        //Couldn't create the local Port So exit the thread
        pthread_exit(NULL);
    }
    
    //add the source to current run loop
    CFRunLoopAddSource
    (CFRunLoopGetCurrent(), rlSource, kCFRunLoopDefaultMode);
    
    /*Once installed ,these can be freed */
    CFRelease(myLocalPort);
    CFRelease(rlSource);
    
    //Package up the port name and send the check-in message
    CFDataRef returnData = NULL;
    CFDataRef outData = NULL;
    
    CFIndex stringLength = INT_MAX;
    stringLength = CFStringGetLength(localPortName);
    
    UInt8* buffer = NULL;
    buffer = CFAllocatorAllocate(NULL, stringLength, 0);
    
    CFStringGetBytes
    (localPortName,
     CFRangeMake(0, stringLength),
     (CFStringEncoding) kCFStringEncodingASCII,
     0,
     false,
     buffer,
     stringLength,
     NULL);
    
    outData = CFDataCreate(NULL,(const UInt8*)buffer, stringLength);
#define kCheckinMessage 100
    /*
     SInt32 CFMessagePortSendRequest 
     (
     CFMessagePortRef remote,
     SInt32 msgid,
     CFDataRef data,
     CFTimeInterval sendTimeout,
     CFTimeInterval rcvTimeout,
     CFStringRef replyMode,
     CFDataRef *returnData
     );
     Description	

     */
    SInt32 CFMessagePortSendRequestRval = INT_MAX;
    CFMessagePortSendRequestRval =
    CFMessagePortSendRequest
    (mainThreadRemotePort,
                             kCheckinMessage,
     outData,
     0.1,
     0.0,
     NULL,
     NULL);
    
    switch (CFMessagePortSendRequestRval)
    {
        case kCFMessagePortSuccess:
            printf("kCFMessagePortSuccess");
            break;
        
        case kCFMessagePortSendTimeout:
            printf("kCFMessagePortSendTimeout");
            break;
        
        case kCFMessagePortReceiveTimeout:
            printf("kCFMessagePortReceiveTimeout");
            break;
        
        case kCFMessagePortIsInvalid:
            printf("kCFMessagePortIsInvalid");
            break;
        
        case kCFMessagePortTransportError:
            printf("kCFMessagePortTransportError");
            break;
        
        case kCFMessagePortBecameInvalidError:
            printf("kCFMessagePortBecameInvalidError");
            break;
            
        default:
            printf("CFMessagePortSendRequestRval %d", CFMessagePortSendRequestRval);
            break;
    }
    
    //Thread Cleanup
    CFRelease(outData);
    CFAllocatorDeallocate(NULL, (void*)buffer);
    
    //Enter the runLoop
    CFRunLoopRun();
    return;
}

//typedef CFDataRef (*CFMessagePortCallBack)(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info);


CFDataRef CFMessagePortCallBack_RemoteThread_LocalPort
(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info)
{
    return NULL;
}


@end
