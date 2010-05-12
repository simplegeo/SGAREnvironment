//
//  UIImageAdditions.m
//  SGAREnvironment
//
//  Copyright (c) 2009-2010, SimpleGeo
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, 
//  this list of conditions and the following disclaimer. Redistributions 
//  in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution.
//  
//  Neither the name of the SimpleGeo nor the names of its contributors may
//  be used to endorse or promote products derived from this software 
//  without specific prior written permission.
//   
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  Created by Derek Smith.
//

#import "UIImageAdditions.h"


@implementation UIImage (SGAREnvironment)

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
	float fw, fh;
	if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
	}
    
	CGContextSaveGState(context);
	CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM (context, ovalWidth, ovalHeight);
	fw = CGRectGetWidth (rect) / ovalWidth;
	fh = CGRectGetHeight (rect) / ovalHeight;
	CGContextMoveToPoint(context, fw, fh/2);
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

+ (UIImage*) imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    
    UIImage* newImage = nil;
    if(image) {
        
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0.0, 0.0, newSize.width, newSize.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    return newImage;
}

+ (UIImage*) roundedImageWithImage:(UIImage*)img cornerWidth:(int)width cornerHeight:(int)height scaleSize:(CGSize)size
{
    img = [[UIImage imageWithImage:img scaledToSize:size] retain];
    
	int w = img.size.width;
	int h = img.size.height;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
	CGRect drawRect = CGRectMake(0.0, 0.0, w, h);
    
	CGContextBeginPath(context);
	addRoundedRectToPath(context, drawRect, width, height);
	CGContextClip(context);
	
	CGContextDrawImage(context, drawRect, img.CGImage);
	
	CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	[img release];
	
	UIImage* image = [UIImage imageWithCGImage:imageMasked];
	
	CGImageRelease(imageMasked);
	
	return image;
}

- (UIImage*) scaleImageToSize:(CGSize)newSize
{
    return [UIImage imageWithImage:self scaledToSize:newSize];
}

- (UIImage*) rotate:(UIImageOrientation)orient
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = self.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
	
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
			// would get you an exact copy of the original
			assert(false);
			return nil;
			
        case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
			
        case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, M_PI);
			break;
			
        case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
        case UIImageOrientationLeft:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationLeftMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationRight:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        case UIImageOrientationRightMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        default:
			// orientation value supplied is invalid
			assert(false);
			return nil;
    }
	
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
	
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
			CGContextScaleCTM(ctxt, -1.0, 1.0);
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
			
        default:
			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
    }
	
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return copy;
}

- (UIImage*) addImageReflection:(CGFloat)reflectionFraction 
{
	int reflectionHeight = self.size.height * reflectionFraction;
	
	CGImageRef gradientMaskImage = NULL;
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, 1, reflectionHeight,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint gradientStartPoint = CGPointMake(0, reflectionHeight);
    CGPoint gradientEndPoint = CGPointZero;
    
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	CGContextSetGrayFillColor(gradientBitmapContext, 0.0, 0.5);
	CGContextFillRect(gradientBitmapContext, CGRectMake(0, 0, 1, reflectionHeight));
    
    gradientMaskImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
	
    CGImageRef reflectionImage = CGImageCreateWithMask(self.CGImage, gradientMaskImage);
    CGImageRelease(gradientMaskImage);
	
	CGSize size = CGSizeMake(self.size.width, self.size.height + reflectionHeight);
	
	UIGraphicsBeginImageContext(size);
	
	[self drawAtPoint:CGPointZero];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, CGRectMake(0, self.size.height, self.size.width, reflectionHeight), reflectionImage);
	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    CGImageRelease(reflectionImage);
	
	return result;
}


@end
