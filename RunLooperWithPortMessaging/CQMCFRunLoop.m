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
     5. ALSO supplu a function that the thread will run
     7. Destroy the pthread_attr_t structure
                pthread_attr_destroy(&attr);
     
     */
    
    /* int pthread_attr_init(pthread_attr_t *); */
    /* 0 - Success */
    pthread_attr_t attr;
    int thread_attr_init_rval = INT_MAX;
    thread_attr_init_rval = pthread_attr_init((pthread_attr_t *)&attr);
    
    int thread_detach_state_rval = INT_MAX;
    if (thread_attr_init_rval != 0)
    {
        /* int pthread_attr_setdetachstate(pthread_attr_t *, int); */
        thread_detach_state_rval =
        pthread_attr_setdetachstate(
                                    (pthread_attr_t *)&attr,
                                    PTHREAD_CREATE_DETACHED
                                    );
        
        int thread_create_rval = INT_MAX;
        pthread_t posix_thread_ID;
        if (thread_detach_state_rval != 0)
        {
            /* 
             int pthread_create(pthread_t * __restrict, const pthread_attr_t * __restrict,
             void *(*)(void *), void * __restrict);
             */
            thread_create_rval =
            pthread_create(
                           (pthread_t *)&posix_thread_ID,
                           (const pthread_attr_t *)&attr,
                           (void *(*)(void *))&PosixThreadMainRoutine,
                           NULL);
        
            int thread_attr_destroy_rval = INT_MAX;
            if (thread_create_rval != 0)
            {
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
    return NULL;
}

void PosixThreadMainRoutine(void* data)
{
    //Create the remote port to the main thread.
    
    CFStringRef portName = NULL;
    portName = (CFStringRef)data;
    
    CFMessagePortRef mainThreadRemotePort = NULL;
    mainThreadRemotePort =
    CFMessagePortCreateRemote(NULL, portName);
    
    //free the string that was passed
    CFRelease(portName);
    return;
}

@end
