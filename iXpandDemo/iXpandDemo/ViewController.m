//
//  ViewController.m
//  iXpandDemo
//
//  Created by Artem on 10/29/19.
//  Copyright © 2019 Everappz. All rights reserved.
//

#import "ViewController.h"
#import "iXpandController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[iXpandController sharedController] isAccesoryConnectedAndSessionOpened];
}


@end
