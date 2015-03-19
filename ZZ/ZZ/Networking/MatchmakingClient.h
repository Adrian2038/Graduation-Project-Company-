//
//  MatchmakingClient.h
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/18.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


@class MatchmakingClient;

@protocol MatchmakingClientDelegate <NSObject>

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameAvailable:(NSString *)peerID;
- (void)matchmakingClient:(MatchmakingClient *)client serverBecameUnavailable:(NSString *)peerID;
- (void)matchmakingClient:(MatchmakingClient *)client didDisconnectFromServer:(NSString *)peerID;

@end


@interface MatchmakingClient : NSObject <GKSessionDelegate>

@property (nonatomic, weak) id <MatchmakingClientDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray *availableServers;
@property (nonatomic, strong, readonly) GKSession *session;

- (void)startSearchingForServerWithSessionID:(NSString *)sessionID;
- (NSUInteger)availableServerCount;
- (NSString *)peerIDForAvailableServerAtIndex:(NSInteger)index;
- (NSString *)displayNameForPeerID:(NSString *)peerID;
- (void)connectToServerWithPeerID:(NSString *)peerID;
- (void)disconnectFromServer;

@end
