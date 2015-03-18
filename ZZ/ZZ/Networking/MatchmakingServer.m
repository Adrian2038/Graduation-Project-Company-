//
//  MatchmakingServer.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/18.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "MatchmakingServer.h"

@interface MatchmakingServer ()

@property (nonatomic, strong) NSMutableArray *connectedClients;

@end

@implementation MatchmakingServer

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
 
    _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
    _session.delegate = self;
    _session.available = YES;
}


#pragma mark - Properties

- (NSArray *)connectedClients
{
  
    if (_connectedClients) {
        _connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
    }
    return _connectedClients;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"MatchmakingServer : peer : %@ ,change state : %d", peerID, state);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"MatchmakingServer : connction request from peer : %@", peerID);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"MatchmakingServer : connction with peer : %@, failed : %@", peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"MatchmakingServer : session failed : %@ ", error);
}

@end
