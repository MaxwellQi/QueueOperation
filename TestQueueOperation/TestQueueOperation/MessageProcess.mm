//
//  MessageProcess.m
//  TestQueueOperation
//
//  Created by zhangqi on 1/3/2017.
//  Copyright © 2017 MaxwellQi. All rights reserved.
//

#import "MessageProcess.h"
#include <iostream>
#include <string.h>
const int defaultFreeQueueSize = 20;

ProcessingQueue::ProcessingQueue()
{
    m_messageFreeQueue = (MessageFreeQueue *)malloc(sizeof(struct MessageFreeQueue));
    m_messageWorkQueue = (MessageWorkQueue *)malloc(sizeof(struct MessageWorkQueue));
    InitQueue(m_messageFreeQueue, m_messageWorkQueue);
    
    for (int i = 0; i < defaultFreeQueueSize; i++) {
        MessageNode* node = (MessageNode *)malloc(sizeof(MessageNode));
        this->EnQueue(m_messageFreeQueue, NULL,node);
    }
    
    pthread_mutex_init(&queue_mutex,NULL);
}

ProcessingQueue::~ProcessingQueue(){}

void ProcessingQueue::InitQueue(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue)
{
    freeQueue->size = 0;
    freeQueue->front = NULL;
    freeQueue->rear = NULL;
    
    workQueue->size = 0;
    workQueue->front = NULL;
    workQueue->rear = NULL;
}

void ProcessingQueue::EnQueue(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue,MessageNode *node)
{
    node->next = NULL;
     pthread_mutex_lock(&queue_mutex);
    if (freeQueue != NULL) {
       
        
        if (freeQueue->front == NULL)
        {
            freeQueue->front = node;
            freeQueue->rear = node;
        }
        else
        {
            freeQueue->rear->next = node;
            freeQueue->rear = node;
        }
        freeQueue->size += 1;
        
    }
    
    if (workQueue != NULL) {
        if (workQueue->front == NULL)
        {
            workQueue->front = node;
            workQueue->rear = node;
        }
        else
        {
            workQueue->rear->next = node;
            workQueue->rear = node;
        }
        workQueue->size += 1;
    }
    
    pthread_mutex_unlock(&queue_mutex);
    
    
}

MessageNode* ProcessingQueue::DeQueue(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue)
{
    MessageNode* element = NULL;
    pthread_mutex_lock(&queue_mutex);
    
    if (freeQueue != NULL) {
        element = freeQueue->front;
        if(element == NULL)
        {
            pthread_mutex_unlock(&queue_mutex);
            return NULL;
        }
        
        freeQueue->front = freeQueue->front->next;
        freeQueue->size -= 1;
        pthread_mutex_unlock(&queue_mutex);
        
        return element;
    }else{
        element = workQueue->front;
        if(element == NULL)
        {
            pthread_mutex_unlock(&queue_mutex);
            return NULL;
        }
        
        workQueue->front = workQueue->front->next;
        workQueue->size -= 1;
        pthread_mutex_unlock(&queue_mutex);
        
        return element;
    }
}

MessageNode* ProcessingQueue::GetNode(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue)
{
    return NULL;
}

void ProcessingQueue::FreeNode(MessageNode *node)
{
    if(node != NULL){
        free(node->data);
        free(node);
    }
}

void ProcessingQueue::ClearMessageQueue()
{
    while (m_messageFreeQueue->size) {
        MessageNode *node = this->DeQueue(m_messageFreeQueue,NULL);
        this->FreeNode(node);
        
        MessageNode *workNode = this->DeQueue(NULL, m_messageWorkQueue);
        this->FreeNode(workNode);
    }
}

int ProcessingQueue::GetQueueSize(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue)
{
    if (freeQueue != NULL) {
        return freeQueue->size;
    }else{
        return workQueue->size;
    }
}

@interface MessageProcess()
{
    ProcessingQueue *_processingQueue;
}
@end

@implementation MessageProcess

- (instancetype)init
{
    if (self = [super init]) {
        _processingQueue = new ProcessingQueue();
    }
    return self;
}

- (void)initTimer
{
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(processingMessageFreeQueue) userInfo:nil repeats:YES];
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(processingMessageWorkQueue) userInfo:nil repeats:YES];
    [self processingMessageFreeQueue];
    [self processingMessageWorkQueue];
}

- (void)processingMessageFreeQueue
{
    NSLog(@"%s",__func__);
    
    while (true) {
        int freeQueueSize = _processingQueue->GetQueueSize(_processingQueue->m_messageFreeQueue, NULL);
        if (freeQueueSize == 0) {
            return;
        }
        int randomNum = arc4random() % 100;
        NSString *message = [NSString stringWithFormat:@"Hello workd---%d",randomNum];
        MessageNode *node = _processingQueue->DeQueue(_processingQueue->m_messageFreeQueue, NULL);
        const char* c_message = [message UTF8String];
        int len = (int)strlen(c_message);
        node->data = (char *)malloc(len +1);
        memcpy(node->data, c_message, len);
        node->data[len] = 0;
        NSLog(@"input: %@",message);
        _processingQueue->EnQueue(NULL,_processingQueue->m_messageWorkQueue, node);
    }
}

- (void)processingMessageWorkQueue
{
    NSLog(@"%s",__func__);
    
    while (true) {
        int workQueueSize = _processingQueue->GetQueueSize(NULL,_processingQueue->m_messageWorkQueue);
        if (workQueueSize == 0) {
            return;
        }
        MessageNode *messageNode = _processingQueue->DeQueue(NULL,_processingQueue->m_messageWorkQueue);
        if (messageNode->data != NULL) {
            NSLog(@"%@",[NSString stringWithUTF8String:messageNode->data]);
        }
        _processingQueue->EnQueue(_processingQueue->m_messageFreeQueue, NULL, messageNode);
    }
}

@end
