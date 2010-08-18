//
//  SGRadar.h
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

#import "SGRadar.h"

#import "SGMath.h"
#import "SGAnnotationView.h"

#import "SGEnvironmentConstants.h"

#import <QuartzCore/QuartzCore.h>

@interface SGRadar (Private)

- (void) createSubviews;

@end

@implementation SGRadar

@synthesize rotatable, shouldShowCardinalDirections, annotationViews, cardinalDirectionOffset, walkingOffset;
@synthesize currentLocationImageView, radarBackgroundImageView, headingImageView, radarBorderColor, radarCircleColor;
@dynamic headingColor;

- (id) initWithFrame:(CGRect)newFrame
{
    if(self = [super initWithFrame:newFrame]) {
        self.backgroundColor = [UIColor clearColor];
        
        rotatable = YES;
        shouldShowCardinalDirections = YES;
        
        roll = 0.0;
        heading = 0.0;
        
        walkingOffset = CGPointZero;
        
        cardinalDirectionOffset = 5.0;
        
        radarBorderColor = [[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.7] retain];
        radarCircleColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7] retain];
        
        annotationViews = [[NSMutableArray alloc] init];
        
        [self createSubviews];
        
        [self setFrame:newFrame];
    } 
    
    return self;
}

- (void) createSubviews
{
    radarBackgroundImageView = [[UIImageView alloc] initWithImage:nil];
    radarBackgroundImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:radarBackgroundImageView];
    
    currentLocationImageView = [[UIImageView alloc] initWithImage:nil];
    [self addSubview:currentLocationImageView];
    
    headingView = [[SGHeadingView alloc] initWithFrame:CGRectZero];
    [self addSubview:headingView];
    
    headingImageView = [[UIImageView alloc] initWithImage:nil];
    [headingView addSubview:headingImageView];
    
    NSArray* directions = [NSArray arrayWithObjects:@"N", @"E", @"S", @"W", nil];
    cardinalLabels = [[NSMutableArray alloc] initWithCapacity:4];
    for(NSString* direction in directions) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = direction;
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.textColor = [UIColor whiteColor];
        [cardinalLabels addObject:label];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];        
    }
    
    [self loadDefaultImages];
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    [radarBorderColor setStroke];
    [radarCircleColor setFill];
        
    CGContextFillEllipseInRect(contextRef, rect);
    CGContextStrokeEllipseInRect(contextRef, CGRectInset(rect, 1.0, 1.0));    
}

#pragma mark -
#pragma mark Accessor methods 
 
- (void) setHeadingColor:(UIColor *)color
{
    headingView.headingViewColor = color;
}

- (UIColor*) headingColor
{
    return headingView.headingViewColor;
}

- (void) loadDefaultImages
{
    UIImage* image = [UIImage imageNamed:@"SGDefaultRadarCurrentLocation.png"];
    currentLocationImageView.image = image;
    currentLocationImageView.frame = CGRectMake(currentLocationImageView.frame.origin.x,
                                                currentLocationImageView.frame.origin.y,
                                                image.size.width,
                                                image.size.height);
}

- (UILabel*) labelForCardinalDirection:(SGCardinalDirection)direction
{
    return [cardinalLabels objectAtIndex:direction];
}

- (void) addAnnotationViews:(NSArray*)views
{
    for(SGAnnotationView* view in annotationViews)
        [view.radarTargetButton removeFromSuperview];
    
    [annotationViews removeAllObjects];
    [annotationViews addObjectsFromArray:views];
    
    for(SGAnnotationView* view in annotationViews)
        [self addSubview:view.radarTargetButton];
}

- (void) setRotatable:(BOOL)rot
{
    rotatable = rot;
    
    if(!rot)
        self.transform = CGAffineTransformIdentity;
}

- (void) setShouldShowCardinalDirections:(BOOL)show
{
    shouldShowCardinalDirections = show;
    for(UILabel* label in cardinalLabels)
        label.hidden = !show;
}

- (void) setFrame:(CGRect)newFrame
{
    CGFloat boundsWidth = newFrame.size.width;
    CGFloat boundsHeight = newFrame.size.height;
    
    // Background
    radarBackgroundImageView.frame = CGRectMake(0.0,
                                                0.0,
                                                boundsWidth,
                                                boundsHeight);
    
    headingView.transform = CGAffineTransformIdentity;
    
    headingImageView.frame = CGRectMake((headingView.frame.size.width - headingImageView.frame.size.width) / 2.0,
                                        0.0,
                                        headingImageView.image.size.width,
                                        headingImageView.image.size.height);    
    
    // Current position
    currentLocationImageView.frame = CGRectMake((boundsWidth - currentLocationImageView.frame.size.width) / 2.0,
                                                (boundsHeight - currentLocationImageView.frame.size.height) / 2.0,
                                                currentLocationImageView.frame.size.width,
                                                currentLocationImageView.frame.size.height);    
    
    [super setFrame:newFrame];
    
    headingView.frame = self.bounds;
}


#pragma mark -
#pragma mark UIView overrides

- (void) layoutSubviews
{    
    [super layoutSubviews];
    
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat boundsHeight = self.bounds.size.height;
        
    CGFloat scale = (self.frame.size.width / 2.0) / kSGSphere_Radius;
    
    CGRect radarBounds = CGRectInset(self.bounds, -5.0, -5.0);
        
    // Annotaiton Views
    CGFloat bearing, distance;
    CGPoint origin = CGPointZero;
    UIButton* targetButton;
    for(SGAnnotationView* view in annotationViews) {
        targetButton = view.radarTargetButton;
        
        if(!view.isCaptured) {
            bearing = view.bearing;
        
            // The distance that we have here is not the distance
            // calculation that we want. We need to scale it down.
            distance = view.distance * scale;
        
            origin.x = distance * sin(DEGREES_TO_RADIANS(bearing)) + (boundsWidth / 2.0);
            origin.y = -distance * cos(DEGREES_TO_RADIANS(bearing)) + (boundsHeight / 2.0);
            
            // Recenter the position
            origin.x += (walkingOffset.x * scale);
            origin.y += (walkingOffset.y * scale);
        
            if(CGRectContainsPoint(radarBounds, origin)) {
                targetButton.hidden = NO;
                targetButton.frame = CGRectMake(origin.x - (targetButton.frame.size.width / 2.0),
                                                origin.y - (targetButton.frame.size.height / 2.0),
                                                targetButton.frame.size.width,
                                                targetButton.frame.size.height);
                [self bringSubviewToFront:targetButton];
            } else
                targetButton.hidden = YES;
            
        } else
            targetButton.hidden = YES;
    }
    
    if(shouldShowCardinalDirections) {
        UILabel* label;
        CGSize size;
        NSString* string;
        for(int direction = 0; direction < 4; direction++) {
            
            label = [cardinalLabels objectAtIndex:direction];
            
            string = label.text;
            if(!string)
                string = @"M";
            
            size = [string sizeWithFont:label.font];
            
            if(direction == kSGCardinalDirection_North)
                label.frame = CGRectMake((boundsWidth - size.width) / 2.0,
                                         -size.height - cardinalDirectionOffset,
                                         size.width, 
                                         size.height);    
            else if(direction == kSGCardinalDirection_East)
                label.frame = CGRectMake(boundsWidth + cardinalDirectionOffset,
                                         (boundsHeight - size.height) / 2.0,
                                         size.width,
                                         size.height);    
            else if(direction == kSGCardinalDirection_South)
                label.frame = CGRectMake((boundsWidth - size.width) / 2.0,
                                         boundsHeight + cardinalDirectionOffset,
                                         size.width, 
                                         size.height);        
            else if(direction == kSGCardinalDirection_West)
                label.frame = CGRectMake(-size.width - cardinalDirectionOffset,
                                         (boundsHeight - size.height) / 2.0,
                                         size.width,
                                         size.height);                
        }
    }
    
    headingView.transform = CGAffineTransformIdentity;
    headingView.transform = CGAffineTransformMakeRotation(M_PI * heading / 180.0f);
    
    if(rotatable) {
        self.transform = CGAffineTransformIdentity;
        self.transform = CGAffineTransformMakeRotation(M_PI * roll * -90.0 / 180.0f);
    }
}

- (void) drawRadarWithHeading:(double)newHeading roll:(double)newRoll
{
    heading = newHeading;
    roll = newRoll;

    [self setNeedsLayout];    
}


- (void) dealloc
{
    [currentLocationImageView release];
    [headingImageView release];
    [radarBackgroundImageView release];
    [radarBorderColor release];
    [radarCircleColor release];
    [headingColor release];
    [annotationViews release];
    [cardinalLabels release];
    [headingView release];
    [super dealloc];
}

@end
