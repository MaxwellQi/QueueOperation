//
//  ViewController.m
//  ResearchQueue
//
//  Created by zhangqi on 2/3/2017.
//  Copyright © 2017 MaxwellQi. All rights reserved.
//

#import "ViewController.h"
#import "MessageProcess.h"

@interface ViewController ()
{
    MessageProcess *m_messageProcess;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    m_messageProcess = [[MessageProcess alloc] init];
    [m_messageProcess initTimer];

}
@end
