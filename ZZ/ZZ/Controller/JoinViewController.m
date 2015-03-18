//
//  JoinViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "JoinViewController.h"
#import "UIFont+SnapAdditions.h"
#import "MatchmakingClient.h"
#import "PeerCell.h"

@interface JoinViewController ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingClientDelegate>

{
    MatchmakingClient *_matchmakingClient;
}

@property (nonatomic, strong) UIView *connectionView;
@property (nonatomic, strong) UILabel *connectionViewLabel;
@property (nonatomic, strong) UIButton *connectionViewExitButton;

@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JoinViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_matchmakingClient) {
        _matchmakingClient = [[MatchmakingClient alloc] init];
        _matchmakingClient.delegate = self;
        [_matchmakingClient startSearchingForServerWithSessionID:SESSION_ID];
        
        self.nameTextField.placeholder = _matchmakingClient.session.displayName;
        [self.tableView reloadData];
    }
    
    self.headingLabel.font = [UIFont rw_snapFontWithSize:24.0f];
    self.nameLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.statusLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.nameTextField.font = [UIFont rw_snapFontWithSize:20.0f];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self.nameTextField
                                                 action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.nameTextField.delegate = self;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Init all the contents of connection view.
    self.connectionView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.connectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Felt"]];
    
    CGRect labelFrame = CGRectMake(self.view.center.x, self.view.center.y, 100, 20);
    self.connectionViewLabel = [[UILabel alloc] initWithFrame:labelFrame];
    self.connectionViewLabel.text = @"Connecting";
    self.connectionViewLabel.textAlignment = NSTextAlignmentCenter;
    self.connectionViewLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    [self.connectionView addSubview:self.connectionViewLabel];
    
    CGRect buttonFrame = CGRectMake(16, self.view.self.bounds.size.height - 8, 28, 28);
    self.connectionViewExitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.connectionViewExitButton setFrame:buttonFrame];
    [self.connectionViewExitButton setBackgroundImage:[UIImage imageNamed:@"ExitButton"]
                                             forState:UIControlStateNormal];
    [self.connectionView addSubview:self.connectionViewExitButton];
}


#pragma mark - Action

- (IBAction)exitAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_matchmakingClient) {
        return [_matchmakingClient availableServerCount];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[PeerCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:cellID];
    }
    NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
    cell.textLabel.text = [_matchmakingClient displayNameForPeerID:peerID];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select......");
    // Because I don't want any selection anymore .
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_matchmakingClient) {
        [self.view addSubview:self.connectionView];
        
        NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        [_matchmakingClient connectToServerWithPeerID:peerID];
    }
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

@end
