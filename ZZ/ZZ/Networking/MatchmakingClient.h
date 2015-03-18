//
//  MatchmakingClient.h
//  ZZ
//
//  Created by Zhu Dengquan on 15/3/18.
//  Copyright (c) 2015年 Zhu Dengquan. All rights reserved.
//


@interface MatchmakingClient : NSObject <GKSessionDelegate>

@property (nonatomic, strong, readonly) NSArray *availableServers;
@property (nonatomic, strong, readonly) GKSession *session;

- (void)startSearchingForServerWithSessionID:(NSString *)sessionID;

@end
