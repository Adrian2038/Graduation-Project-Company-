//
//  HostViewController.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/13.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "HostViewController.h"
#import "UIButton+SnapAdditions.h"
#import "UIFont+SnapAdditions.h"
#import "MatchmakingServer.h"
#import "PeerCell.h"

@interface HostViewController ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingServerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, strong) MatchmakingServer *matchmakingServer;

@end

@implementation HostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headingLabel.font = [UIFont rw_snapFontWithSize:24.0f];
    self.nameLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.statusLabel.font = [UIFont rw_snapFontWithSize:16.0f];
    self.nameTextField.font = [UIFont rw_snapFontWithSize:20.0f];
 
    [self.startButton rw_applySnapStyle];
 
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self.nameTextField
                                                 action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.nameTextField.delegate = self;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_matchmakingServer) {
        _matchmakingServer = [[MatchmakingServer alloc] init];
        _matchmakingServer.delegate = self;
        _matchmakingServer.maxClients = 7;
        [_matchmakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
        NSLog(@"server.... view did appear");
        
        self.nameTextField.placeholder = _matchmakingServer.session.displayName;
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}

#pragma mark - Action

- (IBAction)startAction:(UIButton *)sender
{
}

- (IBAction)exitAction:(id)sender
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
    if (_matchmakingServer) {
        return [_matchmakingServer connectedClientCount];
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
    NSString *peerID = [_matchmakingServer peerIDForConnectedClientAtIndex:indexPath.row];
    cell.textLabel.text = [_matchmakingServer displayNameForPeerID:peerID];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma mark - MatchmakingServerDelegate

- (void)matchmakingServer:(MatchmakingServer *)server clientDidConnect:(NSString *)peerID
{
    [self.tableView reloadData];
}

- (void)matchmakingServer:(MatchmakingServer *)server clientDidDisconnect:(NSString *)peerID
{
    [self.tableView reloadData];
}


@end
