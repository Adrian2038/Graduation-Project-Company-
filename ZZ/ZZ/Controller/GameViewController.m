//
//  GameViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/26.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "GameViewController.h"
#import "UIFont+SnapAdditions.h"

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *centerLabel;

@end

@implementation GameViewController

#pragma mark - VC Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.centerLabel.font = [UIFont rw_snapFontWithSize:18.0f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark - Action

- (IBAction)exitAction:(UIButton *)sender
{
    [self.game quitGameWithReason:QuitReasonUserQuit];
}

#pragma mark - GameDelegate

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason
{
    [self.delegate gameViewController:self didQuitWithReason:reason];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
