//
//  MatchmakingClient.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/18.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "MatchmakingClient.h"

@interface MatchmakingClient ()

{
    NSMutableArray *_availableServers;
}

@end

@implementation MatchmakingClient


#pragma mark - Methods that the other classes can use

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

- (NSUInteger)availableServerCount
{
    return [_availableServers count];
}

- (NSString *)peerIDForAvailableServerAtIndex:(NSInteger)index
{
    return [_availableServers objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
    return [_session displayNameForPeer:peerID];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"MatchmakingClient : peer : %@ ,change state : %d", peerID, state);
    
    switch (state) {
        case GKPeerStateAvailable:
            if (![_availableServers containsObject:peerID]) {
                [_availableServers addObject:peerID];
                [self.delegate matchmakingClient:self serverBecameAvailable:peerID];
            }
            break;
        case GKPeerStateUnavailable:
            if ([_availableServers containsObject:peerID]) {
                [_availableServers removeObject:peerID];
                [self.delegate matchmakingClient: self serverBecameUnavailable:peerID];
            }
            
            break;
        case GKPeerStateConnected:
            
            break;
        case GKPeerStateDisconnected:
            
            break;
        case GKPeerStateConnecting:
            
            break;
            
        default:
            break;
    }
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
