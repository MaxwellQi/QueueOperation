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

ProcessingQueue::ProcessingQueue()
{
    m_messageFreeQueue = (MessageFreeQueue *)malloc(sizeof(struct MessageFreeQueue));
    m_messageWorkQueue = (MessageWorkQueue *)malloc(sizeof(struct MessageWorkQueue));
    InitQueue(m_messageFreeQueue, m_messageWorkQueue);
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

void ProcessingQueue::EnQueue(MessageFreeQueue *freeQueue,MessageWorkQueue *workQueue,const char* data,int len)
{
    MessageNode* node = (MessageNode *)malloc(sizeof(MessageNode));
    node->data = (char *)malloc(len+1);
    memcpy(node->data, data, len);
    node->data[len] = 0;
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

- (void)initMessage
{
    const char* message01 = [@"Hello world 111" UTF8String];
    ;
    const char* message02 = [@"Hello world 222"  UTF8String];
    const char* message03 = [@"Hello world 333"  UTF8String];
    const char* message04 = [@"Hello world 444"  UTF8String];
    const char* message05 = [@"Hello world 555"  UTF8String];
    _processingQueue->EnQueue(_processingQueue->m_messageFreeQueue, NULL, message01, (int)strlen(message01));
     _processingQueue->EnQueue(_processingQueue->m_messageFreeQueue, NULL, message02, (int)strlen(message02));
     _processingQueue->EnQueue(_processingQueue->m_messageFreeQueue, NULL, message03, (int)strlen(message03));
     _processingQueue->EnQueue(_processingQueue->m_messageFreeQueue, NULL, message04, (int)strlen(message04));
     _processingQueue->EnQueue(_processingQueue->m_messageFreeQueue, NULL, message05, (int)strlen(message05));
}

- (void)readMessage
{
    while (true) {
        if (_processingQueue->GetQueueSize(_processingQueue->m_messageFreeQueue, NULL) == 0) {
            return;
        }
        MessageNode *messageNode = _processingQueue->DeQueue(_processingQueue->m_messageFreeQueue, NULL);
        if (messageNode->data != NULL) {
            NSLog(@"%@",[NSString stringWithUTF8String:messageNode->data]);
        }
        
    }

}

@end
