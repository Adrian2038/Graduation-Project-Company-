//
//  MainViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


#import "MainViewController.h"
#import "HostViewController.h"
#import "JoinViewController.h"

#import "UIButton+SnapAdditions.h"

@interface MainViewController () <HostViewControllerDelegate, JoinViewControllerDelegate>

{
    BOOL _buttonsEnabled;
    BOOL _performAnimations;
}

@property (nonatomic, weak) IBOutlet UIButton *hostGameButton;
@property (nonatomic, weak) IBOutlet UIButton *joinGameButton;
@property (nonatomic, weak) IBOutlet UIButton *singlePlayerGameButton;

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _performAnimations = YES;
    }
    
    return self;
}

#pragma mark - LifeCycle of vc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // I don't want the naviBar.
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    
    [self.hostGameButton rw_applySnapStyle];
    [self.joinGameButton rw_applySnapStyle];
    [self.singlePlayerGameButton rw_applySnapStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_performAnimations) {
        [self prepareForIntroAnimation];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_performAnimations) {
        [self performIntroAnimation];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([segue.identifier isEqualToString:@"Host Game"]) {
        if ([segue.destinationViewController isKindOfClass:[HostViewController class]]) {
            HostViewController *hostViewController = (HostViewController *)segue.destinationViewController;
            hostViewController.delegate = self;
        }
    } else if ([segue.identifier isEqualToString:@"Join Game"]) {
        if ([segue.destinationViewController isKindOfClass:[JoinViewController class]]) {
            JoinViewController *joinViewController = (JoinViewController *)segue.destinationViewController;
            joinViewController.delegate = self;
        }
    }
}

#pragma mark - Actions , that I may use segue replace it.

- (IBAction)hostGameAction:(id)sender
{
    if (_buttonsEnabled)
    {
        [self performExitAnimationWithCompletionBlock:^(BOOL finished)
         {
             HostViewController *controller = [[HostViewController alloc] initWithNibName:@"HostViewController"
                                                                                   bundle:nil];
             controller.delegate = self;
             
             [self presentViewController:controller animated:NO completion:nil];
         }];
    }
}

- (IBAction)joinGameAction:(id)sender
{
    if (_buttonsEnabled)
    {
        [self performExitAnimationWithCompletionBlock:^(BOOL finished)
         {
             JoinViewController *controller = [[JoinViewController alloc] initWithNibName:@"JoinViewController"
                                                                                   bundle:nil];
             controller.delegate = self;
             
             [self presentViewController:controller animated:NO completion:nil];
         }];
    }
}

- (IBAction)singlePlayerGameAction:(id)sender
{
}

#pragma mark - Animation

- (void)prepareForIntroAnimation
{
    self.hostGameButton.alpha = 0.0f;
    self.joinGameButton.alpha = 0.0f;
    self.singlePlayerGameButton.alpha = 0.0f;
    
    _buttonsEnabled = NO;
}

- (void)performIntroAnimation
{
    [UIView animateWithDuration:0.5f
                          delay:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.hostGameButton.alpha = 1.0f;
         self.joinGameButton.alpha = 1.0f;
         self.singlePlayerGameButton.alpha = 1.0f;
     }
                     completion:^(BOOL finished)
     {
         _buttonsEnabled = YES;
     }];
    
}

- (void)performExitAnimationWithCompletionBlock:(void (^)(BOOL))block
{
    _buttonsEnabled = NO;
    
    [UIView animateWithDuration:0.3f
                          delay:0.3f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.hostGameButton.alpha = 0.0f;
         self.joinGameButton.alpha = 0.0f;
         self.singlePlayerGameButton.alpha = 0.0f;
     }
                     completion:nil];

}

#pragma mark - AlertView

- (void)showNoNetworkAlert
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"No Network", @"No network alert title")
                              message:NSLocalizedString(@"To use multiplayer, please enable Bluetooth or Wi-Fi in your device's Settings.", @"No network alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)showDisconnectedAlert
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Disconnected", @"Client disconnected alert title")
                              message:NSLocalizedString(@"You were disconnected from the game.", @"Client disconnected alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
    [alertView show];
}

#pragma mark - HostViewControllerDelegate

- (void)hostViewControllerDidCancel:(HostViewController *)controller
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void)hostViewController:(HostViewController *)controller didEndSessionWithReason:(QuitReason)reason
{
    if (reason == QuitReasonNoNetwork)
    {
        [self showNoNetworkAlert];
    }
}

#pragma mark - JoinViewControllerDelegate

- (void)joinViewControllerDidCancel:(JoinViewController *)controller
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void)joinViewController:(JoinViewController *)controller didDisconnectWithReason:(QuitReason)reason
{
    if (reason == QuitReasonNoNetwork)
    {
        [self showNoNetworkAlert];
    }
    else if (reason == QuitReasonConnectionDropped)
    {
        [self.navigationController popToViewController:self animated:YES];
        [self showDisconnectedAlert];
    }
}

- (void)joinViewController:(JoinViewController *)controller
      startGameWithSession:(GKSession *)session
                playerName:(NSString *)name
                    server:(NSString *)peerID
{
    _performAnimations = NO;
    
    [self.navigationController popToViewController:self animated:NO];
    
    // The logic of the Game Model...
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);

}

@end
