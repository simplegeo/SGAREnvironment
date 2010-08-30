//
//  SGAnnotationViewContainer.m
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

#import "SGAnnotationViewContainer.h"

#import "SGARView.h"
#import "SGAnnotationView.h"

@interface SGAnnotationViewContainer (Private)

- (void) loadDefaultImages;
- (void) setActions;
- (void) changeImageDueToEvent;

- (void) setTopImage;

@end

@implementation SGAnnotationViewContainer
@synthesize highlightedImage, arView;
@dynamic normalImage;

- (id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        views = [[NSMutableArray alloc] init];        
        images = [[NSMutableArray alloc] init];
        
        rotatable = YES;
        
        normalImage = nil;
        highlightedImage = nil;
        
        [self loadDefaultImages];
        [self setActions];
    }
    
    return self;
}

- (void) loadDefaultImages
{
    self.normalImage = [UIImage imageNamed:@"SGDefaultContainer.png"];
    self.highlightedImage = [UIImage imageNamed:@"SGDefaultSelectedContainer.png"];
    [self setBackgroundImage:self.normalImage forState:UIControlStateNormal];
}

- (void) setActions
{
    [self addTarget:self action:@selector(doubleTouch:) forControlEvents:UIControlEventTouchDownRepeat];
    [self addTarget:self action:@selector(dragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(dragLeave:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark Accessor methods 

- (void) setNormalImage:(UIImage *)image
{
    if(normalImage)
        [normalImage release];
    
    normalImage = [image retain];
    
    if(normalImage)
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                normalImage.size.width, normalImage.size.height);
}

- (UIImage*) normalImage
{
    return normalImage;
}

- (BOOL) shouldAddViews:(NSArray*)newViews
{
    return YES;
}

- (void) addRecordAnnotationViews:(NSArray*)newViews
{
    if(newViews && [newViews count] && [self shouldAddViews:newViews]) {
        
        [views addObjectsFromArray:newViews];
        for(SGAnnotationView* view in newViews)
            view.isCaptured = YES;
        
        [self setTopImage];
    }
}

- (BOOL) isEmpty
{
    return views && [views count] == 0;
}

- (NSArray*) getRecordAnnotationViews
{
    return [NSArray arrayWithArray:views];
}

- (NSArray*) getRecordAnnotations
{
    NSMutableArray* objects = [[NSMutableArray alloc] init];
    for(SGAnnotationView* view in views)
        [objects addObject:view.annotation];
    
    return [objects autorelease];
}

- (void) removeAnnotationView:(SGAnnotationView*)view
{
    if(view) {
        view.isCaptured = NO;
        [views removeObject:view];
        
        [self setTopImage];
    }
}

- (void) removeAllAnnotationViews
{
    for(SGAnnotationView* view in views)
        view.isCaptured = NO;
    
    [views removeAllObjects];
    [self setTopImage];
}

#pragma mark -
#pragma mark Event handlers 

- (void) doubleTouch:(id)button
{
    [self removeAllAnnotationViews];
}

- (void) dragEnter:(id)button
{
    if(highlightedImage)
        [self setBackgroundImage:highlightedImage
                        forState:UIControlStateNormal];
}

- (void) dragLeave:(id)button
{
    if(normalImage)
        [self setBackgroundImage:normalImage
                        forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Utilities 
 
- (void) setTopImage
{
    if([views count])
        [self setImage:((SGAnnotationView*)[views objectAtIndex:[views count] - 1]).containerImage 
              forState:UIControlStateNormal];
    else
        [self setImage:nil forState:UIControlStateNormal];
}

- (SGAnnotationView*) popAnnotationView
{
    SGAnnotationView* view = nil;
    if([views count]) {
        view = [[views objectAtIndex:0] retain];
        [views removeObjectAtIndex:0];
        
        [self setTopImage];
        
        [view autorelease];
    }
    
    return view;
}

- (void) dealloc
{
    [views release];
    [images release];
    [normalImage release];
    [highlightedImage release];
    
    [super dealloc];
}

@end
