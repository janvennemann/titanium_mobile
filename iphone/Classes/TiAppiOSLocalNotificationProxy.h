/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
@import TitaniumKit;

#ifdef USE_TI_APPIOS

@interface TiAppiOSLocalNotificationProxy : TiProxy {
@private
	UILocalNotification *_notification;

}

@property(nonatomic,retain) UILocalNotification *notification;

-(void)cancel:(id)args;

@end


#endif
