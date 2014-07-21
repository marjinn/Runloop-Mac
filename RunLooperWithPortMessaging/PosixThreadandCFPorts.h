//
//  PosixThreadandCFPorts.h
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/20/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PosixThreadandCFPorts : NSObject


pthread_t* LaunchAPosixThread(void* threadName);


@end
