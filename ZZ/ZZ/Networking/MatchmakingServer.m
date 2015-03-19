//
//  MatchmakingServer.m
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/18.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//

#import "MatchmakingServer.h"

typedef enum
{
    ServerStateIdel,
    ServerStateAcceptingConnections,
    ServerStateIgnoringNewConnections,
}ServerState;

@interface MatchmakingServer ()

{
    NSMutableArray *_connectedClients;
    ServerState _serverState;
}

@end

@implementation MatchmakingServer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serverState = ServerStateIdel;
    }
    return self;
}

#pragma mark - Methods that the other classes can use

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
    if (_serverState == ServerStateIdel) {
        _serverState = ServerStateAcceptingConnections;
        
        _connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID
                                            displayName:nil
                                            sessionMode:GKSessionModeServer];
        _session.delegate = self;
        _session.available = YES;
    }
}

- (NSArray *)connectedClients
{
    return _connectedClients;
}

- (NSUInteger)connectedClientCount
{
    return [_connectedClients count];
}

- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index
{
    return [_connectedClients objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
    return [_session displayNameForPeer:peerID];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSLog(@"MatchmakingServer : peer : %@ ,change state : %d", peerID, state);
    
    switch (state) {
        case GKPeerStateAvailable:
            break;
            
        case GKPeerStateUnavailable:
            break;

            // A new client has connected to the server
        case GKPeerStateConnected:
            if (_serverState == ServerStateAcceptingConnections) {
                if (![_connectedClients containsObject:peerID]) {
                    [_connectedClients addObject:peerID];
                    [self.delegate matchmakingServer:self clientDidConnect:peerID];
                }
            }
            break;

            // A clinet has disconnected from the server 
        case GKPeerStateDisconnected:
            if (_serverState != ServerStateIdel) {
                if ([_connectedClients containsObject:peerID]) {
                    [_connectedClients removeObject:peerID];
                    [self.delegate matchmakingServer:self clientDidDisconnect:peerID];
                }
            }
            break;

        case GKPeerStateConnecting:
            
            break;

        default:
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"MatchmakingServer : connction request from peer : %@", peerID);
    
    if (_serverState == ServerStateAcceptingConnections && [self connectedClientCount] < self.maxClients) {
        
        NSError *error;
        if ([session acceptConnectionFromPeer:peerID error:&error]) {
            NSLog(@"MatchmakingClient : connection accepeted from peer : %@", peerID);
        } else {
            NSLog(@"MatchmakingClient : Error accepting connection form peer : %@ ", peerID);
        }
    } else {
        [session denyConnectionFromPeer:peerID];
    }
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
