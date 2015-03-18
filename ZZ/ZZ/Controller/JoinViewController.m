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

@interface JoinViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingClientDelegate>

{
    MatchmakingClient *_matchmakingClient;
}

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
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.nameTextField action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.nameTextField.delegate = self;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_matchmakingClient) {
        return [_matchmakingClient availableServerCount];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[PeerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor grayColor];

    NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
    cell.textLabel.text = [_matchmakingClient displayNameForPeerID:peerID];
    
    return cell;
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
