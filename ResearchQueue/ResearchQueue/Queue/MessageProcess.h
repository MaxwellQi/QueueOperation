//
//  MessageProcess.h
//  TestQueueOperation
//
//  Created by zhangqi on 1/3/2017.
//  Copyright © 2017 MaxwellQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>

typedef struct MessageNode
{
    char * data;
    struct MessageNode *next;
}MessageNode;

typedef struct MessageFreeQueue
{
    int size;
    MessageNode *front;
    MessageNode *rear;
}MessageFreeQueue;

typedef struct MessageWorkQueue
{
    int size;
    MessageNode *front;
    MessageNode *rear;
}MessageWorkQueue;

class ProcessingQueue
{
public:
    MessageFreeQueue *m_messageFreeQueue;
    MessageWorkQueue *m_messageWorkQueue;
    
    ProcessingQueue();
    ~ProcessingQueue();
    void InitQueue(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue);
    void EnWorkQueue(MessageWorkQueue *workQueue,MessageNode *node);
    void EnQueue(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue,MessageNode *node);
    MessageNode* DeQueue(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue);
    MessageNode* GetNode(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue);
    void FreeNode(MessageNode *node);
    void ClearMessageQueue();
    int GetQueueSize(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue);
private:
    pthread_mutex_t queue_mutex;
};




@interface MessageProcess : NSObject

- (void)initTimer;

@end
