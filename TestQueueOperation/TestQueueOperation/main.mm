//
//  main.m
//  TestQueueOperation
//
//  Created by zhangqi on 1/3/2017.
//  Copyright © 2017 MaxwellQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageProcess.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MessageProcess *messageProcess = [[MessageProcess alloc] init];
        [messageProcess initTimer];
        [messageProcess release];
    }
    return 0;
}
