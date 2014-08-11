//
//  ThreadSynchorniZations.m
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/27/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import "ThreadSynchorniZations.h"
#include <libkern/OSAtomic.h>
#include <pthread/pthread.h>

/**
    Synchronization Tools Available
    --------------------------------
 1. Atomic Operations
 ---------------------
 /usr/include/libkern/OSAtomic.h
 
 2. Memory Barriers and voltile variables
 ----------------------------------------
 OSMemory Barrier
 -- a. Compiler may reorder assembly level instructions 
       that access mainmemoryto
 
 In order to achieve optimal performance, compilers often reorder assembly-level instructions to keep the instruction pipeline for the processor as full as possible. As part of this optimization, the compiler may reorder instructions that access main memory when it thinks doing so would not generate incorrect data. Unfortunately, it is not always possible for the compiler to detect all memory-dependent operations. If seemingly separate variables actually influence each other, the compiler optimizations could update those variables in the wrong order, generating potentially incorrect results.
 A memory barrier is a type of nonblocking synchronization tool used to ensure that memory operations occur in the correct order. A memory barrier acts like a fence, forcing the processor to complete any load and store operations positioned in front of the barrier before it is allowed to perform load and store operations positioned after the barrier. Memory barriers are typically used to ensure that memory operations by one thread (but visible to another) always occur in an expected order. The lack of a memory barrier in such a situation might allow other threads to see seemingly impossible results. (For an example, see the Wikipedia entry for memory barriers.) To employ a memory barrier, you simply call the OSMemoryBarrier function at the appropriate point in your code.
 
 Volatile variables apply another type of memory constraint to individual variables. The compiler often optimizes code by loading the values for variables into registers. For local variables, this is usually not a problem. If the variable is visible from another thread however, such an optimization might prevent the other thread from noticing any changes to it. Applying the volatile keyword to a variable forces the compiler to load that variable from memory each time it is used. You might declare a variable as volatile if its value could be changed at any time by an external source that the compiler may not be able to detect.

 
 3.Locks
 -------
 
 
 */



static NSRecursiveLock* recursiveLock = nil;
static NSMutableDictionary* dataHolderDict = nil;

@implementation ThreadSynchorniZations

void atomicOPS(void)
{
    int32_t theValue = 0;
    
    /*
     Tests a bit in the specified variable, sets that bit to 1, and returns the value of the old bit as a Boolean value. Bits are tested according to the formula 
     (0x80>>(n&7))of byte ((char*)address + (n >> 3))
     where n is the bit number and address is a pointer to the variable. This formula effectively breaks up the variable into 8-bit sized chunks and orders the bits in each chunk in reverse. For example, to test the lowest-order bit (bit 0) of a 32-bit integer, you would actually specify 7 for the bit number; similarly, to test the highest order bit (bit 32), you would specify 24 for the bit number.
     */
    bool oldValue = 'q';
    oldValue =
    OSAtomicTestAndSet(0, (void *) &theValue);
    //value set to 128
    
    theValue = 0;
    OSAtomicTestAndSet(7, (void *) &theValue);
    //theValue is now 1
    
    theValue = 0;
    OSAtomicTestAndSet(15, (void *) &theValue);
    //the Value is now 256
   
    
    OSAtomicCompareAndSwap32(256, 512, (int32_t *)&theValue);
    //theValue is now 512
    
    OSAtomicCompareAndSwap32(256, 1024, (int32_t *)&theValue);
    //theValue is now 512
    
    
}

void lock_pthread (void)
{
    pthread_mutex_t mutex ;
    const pthread_mutexattr_t mutexAttr;
    
    int mutex_init_rVal_int = INT_MAX;
    mutex_init_rVal_int =
    pthread_mutex_init(
                       (pthread_mutex_t *)&mutex,
                       (const pthread_mutexattr_t *)&mutexAttr);
    
    
    int mutex_try_lock_rVal_int = INT_MAX;
    mutex_try_lock_rVal_int =
    pthread_mutex_trylock((pthread_mutex_t *)&mutex);
    
    if (mutex_try_lock_rVal_int != 0)
    {
        //Work
        
        int mutex_unlock_rVal_int = INT_MAX;
        mutex_unlock_rVal_int =
        pthread_mutex_unlock((pthread_mutex_t *)&mutex);
        
        
        int mutex_destroy_rVal_int = INT_MAX;
        mutex_destroy_rVal_int =
        pthread_mutex_destroy((pthread_mutex_t *)&mutex);
    }
    
    
    
}

void lock_NSLock(void)
{
    BOOL moreToDo = YES;
    
    NSLock* theLock = nil;
    theLock = [NSLock new];
    
    [theLock setName:@"trialLock"];
    
    while (moreToDo)
    {
        /* Do another increment of calculation */
        /* until there’s no more to do. */
        
        if ([theLock tryLock])
        {
            /* Update display used by all threads. */
            [theLock unlock];
        }
    }
}

void synchonizeAt(void)
{
    /// Also Adds an exception handler
    @synchronized(/*Unique ID*/[ThreadSynchorniZations class])
    {
        //Work
    }
}

void recursiveLockFunc (int value)
{
    
    if (recursiveLock != nil)
    {
        recursiveLock = [NSRecursiveLock new];
    }
    
    [recursiveLock setName:@"trial_recursive_lock"];
    
    [recursiveLock lock];
    
    if (value != 0)
    {
        --value;
        
        recursiveLockFunc(value);
    }
    
    [recursiveLock unlock];
    
    recursiveLock = nil;
    
}

/*
 Calling
 */
void recursiveCalling (void)
{
    recursiveLockFunc(110);
}

NSMutableDictionary* dispatchDataDictionary (void)
{
    static dispatch_once_t onceToken;
    dispatch_once
    (
     &onceToken,
     ^{
         dataHolderDict = [NSMutableDictionary dictionary];
     });
    
    return dataHolderDict;
}
void ConditionLock (void)
{
#define NO_DATA  0
#define HAS_DATA 1
    NSConditionLock* condLock = nil;
    condLock =
    [[NSConditionLock alloc] initWithCondition:(NSInteger)NO_DATA];
    
    /* This is a bad Iplmentation as there is an infinite loop 
     * keeping the thread alive, consuming alot of mmemory
     * This must be implemented with  an NSRunLoop
     */
    while (true)
    {
        /* Sleep As to simulate PeRiodic Data Update */
        [NSThread sleepForTimeInterval:(NSTimeInterval)10];
        
        if ([condLock tryLockWhenCondition:(NSInteger)NO_DATA])
        {
            /* Add Data To Queue */
            [condLock unlockWithCondition:(NSInteger)HAS_DATA];
        }
       
    }
}

void demoSYNC (void)
{
    dispatch_queue_t newQ = 0;
    newQ =
    dispatch_queue_create("com.demoSync.Q", DISPATCH_QUEUE_CONCURRENT);
    
#define NO_DATA  0
#define HAS_DATA 1
    NSConditionLock* condLock = nil;
    condLock =
    [[NSConditionLock alloc] initWithCondition:(NSInteger)NO_DATA];

    /* Thread that Adds to dictionary */
    dispatch_async
    (
     newQ,
     ^{
         [[NSThread currentThread] setName:@"Producer.Thread"];
         
         unsigned int countForThread = 0;
         while (true) /* Infinite loop */
         {
             if ([condLock tryLockWhenCondition:(NSInteger)NO_DATA])
             {
                 /* Add Data To Queue */
                 countForThread++;
                
                 NSNumber* number = nil;
                 number =  [NSNumber numberWithInt:countForThread];
                 
                 NSDate* Tdate = nil;
                 Tdate =  [NSDate date];
                 
                 NSString* numbString = nil;
                 numbString = [number stringValue];
                 
                 NSDictionary* tmp = nil;
                 tmp = [NSDictionary dictionaryWithObject:Tdate
                                                   forKey:numbString];
                 
                 dispatchDataDictionary();
                 
                 [dataHolderDict addEntriesFromDictionary:tmp];
                 
                 [condLock unlockWithCondition:(NSInteger)HAS_DATA];
             }
         }
     }
     );
    
    /* Thread that Reads from dictionary */
    dispatch_async
    (
     newQ,
     ^{
         
         unsigned int countForSThread = 0;
         [[NSThread currentThread] setName:@"Consumer.Thread"];
         
         while (true) /* Infinite loop */
         {
         
         [condLock lockWhenCondition:(NSInteger)HAS_DATA];
         
         /*removeData from Q*/
         countForSThread++;
         [dataHolderDict removeObjectForKey:
          [[NSNumber numberWithInt:countForSThread]stringValue]];
         
         [condLock unlockWithCondition:(NSInteger)NO_DATA];
         
         }
     }
     );
}


@end
