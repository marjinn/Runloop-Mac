//
//  PosixThreadandCFPorts.m
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/20/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//


/*
 1. Includes convenience methods to launch preconfigured POSIX threaeds
        All for demonstration purposes
 */

#import "PosixThreadandCFPorts.h"
#include <pthread/pthread.h>

@implementation PosixThreadandCFPorts

pthread_t* LaunchAPosixThread(void* threadName)
{

    pthread_t* threadID = NULL;

    //-- init attributes dict
    /* 0 - Success */
    pthread_attr_t attr;
    int thread_attr_init_rval = INT_MAX;
    thread_attr_init_rval = pthread_attr_init((pthread_attr_t *)&attr);
    
    int thread_detach_state_rval = INT_MAX;
    if (thread_attr_init_rval == 0)
    {
        //-- thread set detached state
        thread_detach_state_rval =
        pthread_attr_setdetachstate(
                                    (pthread_attr_t *)&attr,
                                    PTHREAD_CREATE_DETACHED
                                    );
        
        int thread_create_rval = INT_MAX;
        pthread_t posix_thread_ID;
        if (thread_detach_state_rval == 0)
        {
            //-- thread create
            thread_create_rval =
            pthread_create(
                           (pthread_t *)&posix_thread_ID,
                           (const pthread_attr_t *)&attr,
                           (void *(*)(void *))&PosixThreadMainRoutine,
                           (void*)"myPortName");
            
            int thread_attr_destroy_rval = INT_MAX;
            if (thread_create_rval == 0)
            {
                //-- thread set name
                void *name = NULL;
                if (!threadName)
                {
                    name = "com.app.secondary_thread";
                }
                else
                {
                    name = threadName;
                }
                
                pthread_setname_np(name);
                
                threadID = (pthread_t *)&posix_thread_ID;
                
                //-- thread destroy attributes dict
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

    return threadID;
}

void PosixThreadMainRoutine(void* data)
{
    return ;
}
@end
