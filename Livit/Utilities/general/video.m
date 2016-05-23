//
//  video.m
//  Livit
//
//  Created by Nathan on 11/2/15.
//  Copyright © 2015 Nathan. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "video.h"

UIImage* VideoThumbnail(NSURL *video)
{
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:video options:nil];
	AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	generator.appliesPreferredTrackTransform = YES;
	CMTime time = [asset duration]; time.value = 0;
	NSError *error = nil;
	CMTime actualTime;
	CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
	UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
	CGImageRelease(image);
	return thumbnail;
}

NSNumber* VideoDuration(NSURL *video)
{
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:video options:nil];
	int duration = (int) round(CMTimeGetSeconds(asset.duration));
	return [NSNumber numberWithInt:duration];
}
