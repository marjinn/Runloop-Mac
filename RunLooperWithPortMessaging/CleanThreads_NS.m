//
//  CleanThreads_NS.m
//  RunLooperWithPortMessaging
//
//  Created by mar Jinn on 7/31/14.
//  Copyright (c) 2014 mar Jinn. All rights reserved.
//

#import "CleanThreads_NS.h"

/**
 * Attempt to create a clean implementtaion of 
 * NSThreads with NSPort based Messaging
 *
 * Main Thread Class - NSPort
 * ===========================
 * Keeps track oF -
 * a. local port
 * b. remote port
 * c. remote threads class
 * d. remote thread
 * e. current thread
 * f. Current RunLoop
 * g. All implemmted message types and IDs (Dictionary)
 *
 *
 * Main Thread Class - NSMessagePort
 * =================================
 * Keeps track oF -
 * a. local port name   -   registered to NSMessagePortNameServer
 * b. remote port name  -   registered to NSMessagePortNameServer
 * c. remote threads class
 * d. remote thread
 * e. current thread
 * f. Current RunLoop
 * f. All implemmted message types and IDs (Dictionary)

*/

@implementation CleanThreads_NS

@end
