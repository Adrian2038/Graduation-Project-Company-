//
//  MatchmakingClient.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/18.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "MatchmakingClient.h"

typedef enum
{
    ClientStateIdel,
    ClientStateSearchingForServers,
    ClientStateConnecting,
    ClientStateConnected,
    
}ClientState;

@interface MatchmakingClient ()

{
    NSMutableArray *_availableServers;
    ClientState _clientState;
    NSString *_serverPeerID;
}

@end

@implementation MatchmakingClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        _clientState = ClientStateIdel;
    }
    return self;
}


#pragma mark - Methods that the other classes can use

- (void)startSearchingForServerWithSessionID:(NSString *)sessionID
{
    if (_clientState == ClientStateIdel) {
        _clientState = ClientStateSearchingForServers;
        
        _availableServers = [NSMutableArray arrayWithCapacity:10];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID
                                            displayName:nil
                                            sessionMode:GKSessionModeClient];
        _session.delegate = self;
        _session.available = YES;
    }
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

- (void)connectToServerWithPeerID:(NSString *)peerID
{
    NSAssert(_clientState == ClientStateSearchingForServers, @"Wrong state");
    
    _clientState = ClientStateConnecting;
    _serverPeerID = peerID;
    [_session connectToPeer:peerID withTimeout:_session.disconnectTimeout];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"MatchmakingClient : peer : %@ ,change state : %d", peerID, state);
    
    switch (state) {
            // The client has discover a server.
        case GKPeerStateAvailable:
            if (_clientState == ClientStateSearchingForServers) {
                if (![_availableServers containsObject:peerID]) {
                    [_availableServers addObject:peerID];
                    [self.delegate matchmakingClient:self serverBecameAvailable:peerID];
                }
            }
            break;
            
            // The client sees a server goes away.
        case GKPeerStateUnavailable:
            if (_clientState == ClientStateSearchingForServers) {
                if ([_availableServers containsObject:peerID]) {
                    [_availableServers removeObject:peerID];
                    [self.delegate matchmakingClient: self serverBecameUnavailable:peerID];
                }
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
