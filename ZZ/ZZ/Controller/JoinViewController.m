//
//  JoinViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "JoinViewController.h"

#import "MatchmakingClient.h"
#import "UIFont+SnapAdditions.h"
#import "PeerCell.h"

@interface JoinViewController ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingClientDelegate>

{
    MatchmakingClient *_matchmakingClient;
    QuitReason _quitReason;
}

@property (nonatomic, weak) IBOutlet UILabel *headingLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIView *waitView;
@property (nonatomic, strong) UILabel *waitLabel;
@property (nonatomic, strong) UIButton *waitButton;

@end

@implementation JoinViewController

#pragma mark - LifeCycle of vc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // I don't want the naviBar.
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];

    self.headingLabel.font = [UIFont rw_snapFontWithSize:24.0f];
    self.nameLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.statusLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.nameTextField.font = [UIFont rw_snapFontWithSize:20.0f];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self.nameTextField
                                                 action:@selector(resignFirstResponder)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.waitView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_matchmakingClient)
    {
        _quitReason = QuitReasonConnectionDropped;
        
        _matchmakingClient = [[MatchmakingClient alloc] init];
        _matchmakingClient.delegate = self;
        [_matchmakingClient startSearchingForServersWithSessionID:SESSION_ID];
        
        self.nameTextField.placeholder = _matchmakingClient.session.displayName;
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Waiting view

- (void)showWaitingView
{
    CGRect viewFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50);
    self.waitView = [[UIView alloc] initWithFrame:viewFrame];
    self.waitView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Felt"]];
    [self.view addSubview:self.waitView];
    
    CGRect labelframe = CGRectMake(self.waitView.center.x - 100, self.waitView.center.y, 200, 30);
    self.waitLabel = [[UILabel alloc] initWithFrame:labelframe];
    self.waitLabel.textAlignment = NSTextAlignmentCenter;
    self.waitLabel.text = @"游戏连接中...";
    self.waitLabel.font = [UIFont rw_snapFontWithSize:18.0f];
    [self.waitView addSubview:self.waitLabel];
}

#pragma mark - Action

- (IBAction)exitAction:(id)sender
{
    _quitReason = QuitReasonUserQuit;
    [_matchmakingClient disconnectFromServer];
    [self.delegate joinViewControllerDidCancel:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_matchmakingClient != nil)
        return [_matchmakingClient availableServerCount];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[PeerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
    cell.textLabel.text = [_matchmakingClient displayNameForPeerID:peerID];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_matchmakingClient != nil)
    {
        // The wait view may need some other way to present
//        [self showWaitingView];
        
        NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        [_matchmakingClient connectToServerWithPeerID:peerID];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - MatchmakingClientDelegate

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameAvailable:(NSString *)peerID
{
    [self.tableView reloadData];
}

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameUnavailable:(NSString *)peerID
{
    [self.tableView reloadData];
}

- (void)matchmakingClient:(MatchmakingClient *)client didConnectToServer:(NSString *)peerID
{
    NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([name length] == 0) {
        name = _matchmakingClient.session.displayName;
        
        [self.delegate joinViewController:self
                     startGameWithSession:_matchmakingClient.session
                               playerName:name
                                   server:peerID];
    }
}

- (void)matchmakingClient:(MatchmakingClient *)client didDisconnectFromServer:(NSString *)peerID
{
    _matchmakingClient.delegate = nil;
    _matchmakingClient = nil;
    [self.tableView reloadData];
    [self.delegate joinViewController:self didDisconnectWithReason:_quitReason];
}

- (void)matchmakingClientNoNetwork:(MatchmakingClient *)client
{
    _quitReason = QuitReasonNoNetwork;
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}


@end
