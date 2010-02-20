/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiBase.h"
#import "TiUIImageView.h"
#import "TiUtils.h"
#import "ImageLoader.h"
#import "OperationQueue.h"
#import "TiViewProxy.h"
#import "TiProxy.h"
#import "TiBlob.h"
#import "TiFile.h"
#import "UIImage+Resize.h"

#define IMAGEVIEW_DEBUG 0

@implementation TiUIImageView

#pragma mark Internal

DEFINE_EXCEPTIONS

-(void)dealloc
{
	if (timer!=nil)
	{
		[timer invalidate];
	}
	RELEASE_TO_NIL(timer);
	RELEASE_TO_NIL(images);
	RELEASE_TO_NIL(container);
	[super dealloc];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
	for (UIView *child in [self subviews])
	{
		[TiUtils setView:child positionRect:bounds];
	}
	if (container!=nil)
	{
		for (UIView *child in [container subviews])
		{
			[TiUtils setView:child positionRect:bounds];
		}
	}
}

-(void)timerFired:(id)arg
{
	// if paused, just ignore this timer loop until restared/stoped
	if (paused)
	{
		return;
	}
	
	// don't let the placeholder stomp on our new images
	placeholderLoading = NO;
	
	NSInteger position = index % loadTotal;
	NSInteger nextIndex = (reverse) ? --index : ++index;
	
	if (position<0)
	{
		position=loadTotal-1;
		index=position-1;
	}
	UIView *view = [[container subviews] objectAtIndex:position];

	// see if we have an activity indicator... if we do, that means the image hasn't yet loaded
	// and we want to start the spinner to let the user know that we're still loading. we 
	// don't initially start the spinner when added since we don't want to prematurely show
	// the spinner (usually for the first image) and then immediately remove it with a flash
	UIView *spinner = [[view subviews] count] > 0 ? [[view subviews] objectAtIndex:0] : nil;
	if (spinner!=nil && [spinner isKindOfClass:[UIActivityIndicatorView class]])
	{
		[(UIActivityIndicatorView*)spinner startAnimating];
		[view bringSubviewToFront:spinner];
	}
	
	// the container sits on top of the image in case the first frame (via setUrl) is first
	[self bringSubviewToFront:container];
	
	view.hidden = NO;

	if (previous!=nil)
	{
		previous.hidden = YES;
	}
	
	previous = view;

	if ([self.proxy _hasListeners:@"change"])
	{
		NSDictionary *evt = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:position] forKey:@"index"];
		[self.proxy fireEvent:@"change" withObject:evt];
	}
	
	if (repeatCount > 0 && ((reverse==NO && nextIndex == loadTotal) || (reverse && nextIndex==0)))
	{
		iterations++;
		if (iterations == repeatCount)
		{
			[timer invalidate];
			RELEASE_TO_NIL(timer);
			if ([self.proxy _hasListeners:@"stop"])
			{
				[self.proxy fireEvent:@"stop" withObject:nil];
			}
		}
	}
}

-(void)queueImage:(id)img index:(int)index_
{
	UIView *view = [[UIView alloc] initWithFrame:self.bounds];
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	spinner.center = view.center;
	spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;			
	
	[view addSubview:spinner];
	[container addSubview:view];
	[view release];
	[spinner release];
	
	[images addObject:img];
	[[OperationQueue sharedQueue] queue:@selector(loadImageInBackground:) target:self arg:[NSNumber numberWithInt:index_] after:nil on:nil ui:NO];
}

-(void)queueURLImage:(NSURL*)url
{
	[[OperationQueue sharedQueue] queue:@selector(loadURLImageInBackground:) target:self arg:url after:nil on:nil ui:NO];
}

-(void)startTimer
{
	RELEASE_TO_NIL(timer);
	if (stopped)
	{
		return;
	}
	timer = [[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES] retain]; 
	if ([self.proxy _hasListeners:@"start"])
	{
		[self.proxy fireEvent:@"start" withObject:nil];
	}
}

-(UIImage*)scaleImageIfRequired:(UIImage*)theimage
{
	// attempt to scale the image
	CGFloat width = [TiUtils floatValue:[self.proxy valueForKey:@"width"] def:0];
	CGFloat height = [TiUtils floatValue:[self.proxy valueForKey:@"height"] def:0];
	
	if (width > 0 || height > 0)
	{
		if (width==0)
		{
			width = theimage.size.width;
		}
		if (height==0)
		{
			height = theimage.size.height;
		}
		theimage = [theimage resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationHigh];
	}
	return theimage;
}

-(void)setImageOnUIThread:(NSArray*)args
{
	UIImage *theimage = [self scaleImageIfRequired:[args objectAtIndex:0]];
	NSNumber *pos = [args objectAtIndex:1];
	int position = [TiUtils intValue:pos];
	
	UIView *view = [[container subviews] objectAtIndex:position];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:theimage];
	
	// remove the spinner now that we've loaded our image
	UIView *spinner = [[view subviews] count] > 0 ? [[view subviews] objectAtIndex:0] : nil;
	if (spinner!=nil && [spinner isKindOfClass:[UIActivityIndicatorView class]])
	{
		[spinner removeFromSuperview];
	}
	
	[view addSubview:imageView];
	[imageView release];
	view.hidden = YES;
	
#if IMAGEVIEW_DEBUG	== 1
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 20)];
	label.text = [NSString stringWithFormat:@"%d",position];
	label.font = [UIFont boldSystemFontOfSize:28];
	label.textColor = [UIColor redColor];
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[view bringSubviewToFront:label];
	[label release];
#endif	
	
	loadCount++;
	if (loadCount==loadTotal)
	{
		if ([self.proxy _hasListeners:@"load"])
		{
			NSDictionary *event = [NSDictionary dictionaryWithObject:@"images" forKey:@"state"];
			[self.proxy fireEvent:@"load" withObject:event];
		}
	}
	
	if (ready)
	{
		//NOTE: for now i'm just making sure you have at least one frame loaded before starting the timer
		//but in the future we may want to be more sophisticated
		int min = 1;  
		readyCount++;
		if (readyCount >= min)
		{
			readyCount = 0;
			ready = NO;
			
			[self startTimer];
		}
	}
}

-(void)animationCompleted:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	for (UIView *view in [self subviews])
	{
		// look for our alpha view which is the placeholder layer
		if (view.alpha == 0)
		{
			[view removeFromSuperview];
			break;
		}
	}
}

-(void)setURLImageOnUIThread:(UIImage*)image
{
	// don't stomp on the animations
	if (placeholderLoading)
	{
		UIImageView *iv = [[UIImageView alloc] initWithImage:image];
		
		// do a nice fade in animation to replace the new incoming image
		// with our placeholder
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.8];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationCompleted:finished:context:)];
		
		for (UIView *view in [self subviews])
		{
			if (view!=iv)
			{	
				[view setAlpha:0];
			}
		}
		
		[self addSubview:iv];
		[self sendSubviewToBack:iv];
		[iv release];
		
		[UIView commitAnimations];
	}
	
	placeholderLoading = NO;
}

-(void)loadURLImageInBackground:(NSURL*)url
{
	UIImage *image = [[ImageLoader sharedLoader] loadRemote:url];
	image = [self scaleImageIfRequired:image];
	[self performSelectorOnMainThread:@selector(setURLImageOnUIThread:) withObject:image waitUntilDone:NO];
}

-(void)loadImageInBackground:(NSNumber*)pos
{
	int position = [TiUtils intValue:pos];
	NSURL *theurl = [TiUtils toURL:[images objectAtIndex:position] proxy:self.proxy];
	UIImage *theimage = [[ImageLoader sharedLoader] loadImmediateImage:theurl];
	if (theimage==nil)
	{
		theimage = [[ImageLoader sharedLoader] loadRemote:theurl];
	}
	if (theimage!=nil)
	{
		[self performSelectorOnMainThread:@selector(setImageOnUIThread:) withObject:[NSArray arrayWithObjects:theimage,pos,nil] waitUntilDone:NO];
	}
	else 
	{
		NSLog(@"[ERROR] couldn't load imageview image: %@ at position: %d",theurl,position);
	}
}

#pragma mark Public APIs

-(void)stop
{
	stopped = YES;
	if (timer!=nil)
	{
		[timer invalidate];
		RELEASE_TO_NIL(timer);
		if ([self.proxy _hasListeners:@"stop"])
		{
			[self.proxy fireEvent:@"stop" withObject:nil];
		}
	}
	paused = NO;
	ready = NO;
	index = -1;
	[self.proxy replaceValue:NUMBOOL(NO) forKey:@"animating" notification:NO];
}

-(void)start
{
	stopped = NO;
	
	if (interval <= 0)
	{
		// use a (bad) calculation to determine how fast to rotate assuming 30 frames
		// and then figuring out how many frames they have evenly.  this really just
		// means the developers need to give us the frame rate or we'll do a poor job
		// of guessing
		interval = (1.0/30.0)*(30.0/loadTotal);
	}
	
	paused = NO;
	[self.proxy replaceValue:NUMBOOL(NO) forKey:@"paused" notification:NO];
	
	if (iterations<0)
	{
		iterations = 0;
	}
	
	if (index<0)
	{
		if (reverse)
		{
			index = loadTotal-1;
		}
		else
		{
			index = 0;
		}
	}
	
	
	// refuse to start animation if you don't have any images
	if (loadTotal > 0)
	{
		ready = YES;
		[self.proxy replaceValue:NUMBOOL(YES) forKey:@"animating" notification:NO];
		
		if (timer==nil)
		{
			readyCount = 0;
			ready = NO;
			[self startTimer];
		}
	}
}

-(void)pause
{
	paused = YES;
	[self.proxy replaceValue:NUMBOOL(YES) forKey:@"paused" notification:NO];
	[self.proxy replaceValue:NUMBOOL(NO) forKey:@"animating" notification:NO];
	if ([self.proxy _hasListeners:@"pause"])
	{
		[self.proxy fireEvent:@"pause" withObject:nil];
	}
}

-(void)setImage_:(id)arg
{
	if ([arg isKindOfClass:[TiBlob class]])
	{
		TiBlob *blob = (TiBlob*)arg;
		UIImage *image = [self scaleImageIfRequired:[blob image]];
		UIImageView *view = [[UIImageView alloc] initWithImage:image];
		[self addSubview:view];
		[view release];
		[self.proxy replaceValue:arg forKey:@"image" notification:NO];
	}
	else if ([arg isKindOfClass:[TiFile class]])
	{
		TiFile *file = (TiFile*)arg;
		NSData *data = [NSData dataWithContentsOfFile:[file path]];
		UIImage *image = [[[UIImage alloc] initWithData:data] autorelease];
		image = [self scaleImageIfRequired:image];
		UIImageView *view = [[UIImageView alloc] initWithImage:image];
		[self addSubview:view];
		[view release];
		[self.proxy replaceValue:arg forKey:@"image" notification:NO];
	}
	else
	{
		[self throwException:@"invalid image type" subreason:[NSString stringWithFormat:@"expected either TiBlob or TiFile, was: %@",[arg class]] location:CODELOCATION];
	}
}

-(void)setImages_:(id)args
{
	BOOL running = (timer!=nil);
	
	[self stop];
	
	// remove any existing images
	if (container!=nil)
	{
		for (UIView *view in [container subviews])
		{
			[view removeFromSuperview];
		}
	}
	
	RELEASE_TO_NIL(images);
	ENSURE_TYPE_OR_NIL(args,NSArray);

	if (args!=nil)
	{
		if (container==nil)
		{
			// we use a separate container view so we can both have an image
			// and a set of images
			container = [[UIView alloc] initWithFrame:self.bounds];
			[self addSubview:container];
		}
		images = [[NSMutableArray alloc] initWithCapacity:[args count]];
		loadTotal = [args count];
		for (size_t c = 0; c < [args count]; c++)
		{
			[self queueImage:[args objectAtIndex:c] index:c];
		}
	}
	else
	{
		RELEASE_TO_NIL(container);
	}
	
	// if we were running, re-start it
	if (running)
	{
		[self start];
	}
}

-(void)setUrl_:(id)img
{
	if (img!=nil)
	{
		// remove current subview
		for (UIView *view in [self subviews])
		{
			if ([view isKindOfClass:[UIImageView class]])
			{
				[view removeFromSuperview];
			}
		}
		
		NSURL *url_ = [TiUtils toURL:img proxy:self.proxy];
		UIImage *image = [[ImageLoader sharedLoader] loadImmediateImage:url_];
		if (image==nil)
		{
			// use a placeholder image - which the dev can specify with the
			// defaultImage property or we'll provide the Titanium stock one
			// if not specified
			UIImage *defImage = nil;
			id defaultImage = [self.proxy valueForKey:@"defaultImage"];
			if (defaultImage!=nil)
			{
				NSURL *defURL = [TiUtils toURL:defaultImage proxy:self.proxy];
				defImage = [[ImageLoader sharedLoader] loadImmediateImage:defURL];
			}
			else
			{
				id prev = [self.proxy valueForKey:@"preventDefaultImage"];
				if ([TiUtils boolValue:prev def:NO]==NO)
				{
					defImage = [UIImage imageNamed:@"modules/ui/images/photoDefault.png"];
				}
			}
			if (defImage!=nil)
			{
				UIImageView *iv = [[UIImageView alloc] initWithImage:[self scaleImageIfRequired:defImage]];
				[self addSubview:iv];
				[iv release];
			}
			placeholderLoading = YES;
			[self queueURLImage:url_];
			return;
		}
		if (image!=nil)
		{
			image = [self scaleImageIfRequired:image];
			UIImageView *view = [[UIImageView alloc] initWithImage:image];
			[self addSubview:view];
			[view release];
			if ([self.proxy _hasListeners:@"load"])
			{
				NSDictionary *event = [NSDictionary dictionaryWithObject:@"url" forKey:@"state"];
				[self.proxy fireEvent:@"load" withObject:event];
			}
		}
		else 
		{
			NSLog(@"[ERROR] couldn't find image for ImageView at: %@",img);
		}
	}
}

-(void)setDuration_:(id)duration
{
	interval = [TiUtils floatValue:duration]/1000;
}

-(void)setRepeatCount_:(id)count
{
	repeatCount = [TiUtils intValue:count];
}

-(void)setReverse_:(id)value
{
	reverse = [TiUtils boolValue:value];
}

@end
