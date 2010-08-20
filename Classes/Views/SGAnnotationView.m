//
//  SGAnnotationView.m
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

#import "SGAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

#import "SGMetrics.h"

#define MAX_PHOTO_WIDTH                 224.0
#define MAX_PHOTO_HEIGHT                224.0

@interface SGAnnotationView (Private)

- (void) layoutSubviewsExpanded:(BOOL)expand;

@end

@implementation SGAnnotationView
@synthesize targetImageView, isCaptured, isCapturable, distance, bearing, altitude, reuseIdentifier;
@synthesize point, needNewTexture, delegate, enableOpenGL, containerImage, radarTargetButton;
@dynamic texture, annotation;

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier
{
    if (self = [super initWithFrame:frame]) {
        // Order of creation is important here
        point = (SGPoint3*)malloc(sizeof(SGPoint3));
        
        radarPointTexture = nil;
        texture = nil;
        
        altitude = 0.0;

        needNewTexture = YES;        
        reuseIdentifier = identifier;
            
        self.backgroundColor = [UIColor clearColor];
        
        isCaptured = NO;
        isCapturable = YES;
        
        enableOpenGL = NO;

        targetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 48.0, 48.0)];
        targetImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:targetImageView];        
        
        radarTargetButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        UIImage* targetImage = [UIImage imageNamed:@"SGDefaultRadarTargetImage.png"];
        [radarTargetButton setImage:targetImage forState:UIControlStateNormal];
        radarTargetButton.frame = CGRectMake(0.0, 0.0, targetImage.size.width, targetImage.size.height);
    }

    return self;
}

#pragma mark -
#pragma mark Accessor methods 

- (void) setAnnotation:(id<MKAnnotation>)newAnnotation
{
    annotation = newAnnotation;
    self.needNewTexture = YES;
}

- (id<MKAnnotation>) annotation
{
    return annotation;
}

- (void) prepareForReuse
{
    if(texture) {
        [texture release];
        texture = nil;
    }
    isCaptured = NO;
}

- (SGTexture*) texture
{
    if(needNewTexture) {
        if(texture)
            [texture release];

        CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        
        UIGraphicsBeginImageContext(size);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        texture = [[SGTexture alloc] initWithImage:image];
        
        if(!containerImage)            
            containerImage = [image retain];
        
        needNewTexture = NO;
    }
    
    return texture;
}

- (void) drawAnnotationView
{
    // Does nothing
}

- (void) dealloc 
{
    [reuseIdentifier release];
    [targetImageView release];
    [radarTargetButton release];    
    [containerImage release];
    free(point);    
    [texture release];
    [radarPointTexture release];
    
    [super dealloc];
}

@end
