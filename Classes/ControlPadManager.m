//
//  ControlPadManager.m
//  SNES4iPad
//
//  Created by Yusef Napora on 5/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SNES4iOSAppDelegate.h"
#import "ControlPadManager.h"
#import "ControlPadConnectViewController.h"
#import "RomDetailViewController.h"

#define MAX_CONNECTIONS 4
#define SESSION_ID @"com.snes-hd.controller"

#define INP_BUTTON_UP				(0)
#define INP_BUTTON_LEFT				(2)
#define INP_BUTTON_DOWN				(4)
#define INP_BUTTON_RIGHT			(6)
#define INP_BUTTON_START			(8)
#define INP_BUTTON_SELECT			(9)
#define INP_BUTTON_L				(10)
#define INP_BUTTON_R				(11)
#define INP_BUTTON_HARDLEFT			(12)
#define INP_BUTTON_HARDRIGHT		(13)
#define INP_BUTTON_HARDDOWN			(14)
#define INP_BUTTON_HARDUP			(15)
#define INP_BUTTON_L2				(22)
#define INP_BUTTON_R2				(23)
#define INP_BUTTON_STICK_PUSH		(27)
#define INP_BUTTON_MENU				(31)

extern unsigned long gp2x_pad_status11;
unsigned long padStatusForPadNumber(int which)
{
    return gp2x_pad_status11;
	if (which < MAX_CONTROL_PADS)
		return [AppDelegate().controlPadManager statusForPadNumber:which];

	return 0;
}

@implementation ControlPadManager 
@synthesize padAwaitingConnection, pendingConnectionPeerID;


- (id) init
{
	if (self = [super init])
	{
        gkSession = [[GKSession alloc] initWithSessionID:SESSION_ID 
											 displayName:nil 
											 sessionMode:GKSessionModeServer];
		gkSession.delegate = self;
		[gkSession setDataReceiveHandler:self withContext:NULL];
		controlPadPeerIDs = [[NSMutableArray alloc] initWithObjects:
							 [NSMutableString string],
							 [NSMutableString string],
							 [NSMutableString string],
							 [NSMutableString string],
							 nil];

	}
	return self;
}

- (void) searchForConnectionToPadNumber:(NSUInteger)padNumber
{
	if (padNumber >= MAX_CONTROL_PADS)
		return;
	
	padAwaitingConnection = padNumber;
	gkSession.available = YES;
}

- (void) stopSearchingForConnection
{
    padAwaitingConnection = 0;
	gkSession.available = NO;
}

- (NSString *) deviceNameForPendingConnection
{
	return [gkSession displayNameForPeer:pendingConnectionPeerID];
}

- (NSString *) deviceNameForPadNumber:(NSUInteger)padNumber
{
	if (padNumber >= MAX_CONTROL_PADS)
		return nil;
	
	return [gkSession displayNameForPeer: [controlPadPeerIDs objectAtIndex:padNumber]];
}

- (unsigned long) statusForPadNumber:(NSUInteger)padNumber
{
	if (padNumber < MAX_CONTROL_PADS) {
		return padStatus[padNumber];
	}
	return 0;
}

- (void) disconnectPadNumber:(NSUInteger)padNumber
{
	if (padNumber >= MAX_CONTROL_PADS)
		return;
	
	NSString *peerID = [controlPadPeerIDs objectAtIndex:padNumber];
	[gkSession disconnectPeerFromAllPeers:peerID];
	[[controlPadPeerIDs objectAtIndex:padNumber] setString:@""];
}

- (void) disconnectPeer:(NSString *)peerID
{
	if ([controlPadPeerIDs containsObject:peerID])
	{
		[self disconnectPadNumber:[controlPadPeerIDs indexOfObject:peerID]];
	}
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	if (![controlPadPeerIDs containsObject:peer])
		return;
	
	NSUInteger padNumber = [controlPadPeerIDs indexOfObject:peer];
    [self convertData:data padNumber:padNumber];
    
	//NSLog(@"recieved pad status for player %d: %X", padNumber + 1, padStatus[padNumber]);
}

- (void)convertData:(NSData *)data padNumber:(NSUInteger)padNumber {
    
	[data getBytes:&padStatus[padNumber]];
}

- (void) acceptPendingConnection
{
	[gkSession acceptConnectionFromPeer:self.pendingConnectionPeerID error:nil];
	[[controlPadPeerIDs objectAtIndex:padAwaitingConnection] setString:self.pendingConnectionPeerID];
	self.pendingConnectionPeerID = nil;

	[[AppDelegate() romDetailViewController] updateConnectionButtons];
}

- (void) denyPendingConnection
{
	[gkSession denyConnectionFromPeer:self.pendingConnectionPeerID];
	self.pendingConnectionPeerID = nil;
}

#pragma mark -
#pragma mark GKSession Delegate methods
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	NSLog(@"Session state changed");
	
	switch (state) {
		case GKPeerStateConnected:
			NSLog(@"New Peer connected: %@", peerID);
			[[controlPadPeerIDs objectAtIndex:padAwaitingConnection] setString:peerID];
			self.pendingConnectionPeerID = nil;
			AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateConnected;
			
			break;
		case GKPeerStateAvailable:
		case GKPeerStateConnecting:
			NSLog(@"Peer connecting/available: %@", peerID);
			self.pendingConnectionPeerID = peerID;
			AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateAvailable;
			break;
		case GKPeerStateUnavailable:
			NSLog(@"Peer unavailable: %@", peerID);
			self.pendingConnectionPeerID = nil;
			AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateSearching;
			break;
		case GKPeerStateDisconnected:
			NSLog(@"Peer disconnected: %@", peerID);
			[self disconnectPeer:peerID];
			AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateSearching;
			[AppDelegate().romDetailViewController updateConnectionButtons];
			break;
			
		default:
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSLog(@"Recieved connection request from %@", peerID);
	self.pendingConnectionPeerID = peerID;
	AppDelegate().controlPadConnectViewController.state = ControlPadConnectionStateAvailable;
}
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"Connection with %@ failed", peerID);
}
@end
