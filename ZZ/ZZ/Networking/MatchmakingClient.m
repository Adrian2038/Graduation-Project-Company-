//
//  MatchmakingClient.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/18.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "MatchmakingClient.h"

@interface MatchmakingClient ()

@property (nonatomic, strong) NSMutableArray *availableServers;
@end

@implementation MatchmakingClient

- (void)startSearchingForServerWithSessionID:(NSString *)sessionID
{
    _availableServers = [NSMutableArray arrayWithCapacity:10];
    
    _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeClient];
    _session.delegate = self;
    _session.available = YES;
}

- (NSArray *)availableServers
{
    return _availableServers;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"MatchmakingClient : peer : %@ ,change state : %d", peerID, state);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"MatchmakingClient : connction request from peer : %@", peerID);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"MatchmakingClient : connction with peer : %@, failed : %@", peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"MatchmakingClient : session failed : %@ ", error);
}

@end
