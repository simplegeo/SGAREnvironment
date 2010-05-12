//
//  SGMovableStack.m
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
#import "SGMovableStack.h"

#import <QuartzCore/QuartzCore.h>

#import "SGARView.h"
#import "SGTexture.h"

#define SGMovableStack_Inset               4.0

@implementation SGMovableStack

@synthesize arView, maxStackAmount;

- (id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        movableStack = [[NSMutableArray alloc] init];
        arView = nil;
        maxStackAmount = 100;
    }
    
    return self;
}

#pragma mark -
#pragma mark Stack manipulators 

- (void) addAnnotationView:(SGAnnotationView*)view
{
    if(view && [movableStack count] < maxStackAmount) {
        view.isCaptured = YES;
        [movableStack addObject:view];
        
        [self addSubview:view];
    
        if(!self.superview)
            [arView addSubview:self];
        
        if([self isKindOfClass:[SGMovableStack class]]) {
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    ((UIView*)[movableStack objectAtIndex:0]).frame.size.width + SGMovableStack_Inset * ([movableStack count] - 1),
                                    ((UIView*)[movableStack objectAtIndex:0]).frame.size.height + SGMovableStack_Inset * ([movableStack count] - 1));
    
            SGAnnotationView* annotationView = nil;
            NSInteger size = [movableStack count];
            for(int i = size - 1; i >= 0 ; i--) {
                annotationView = [movableStack objectAtIndex:i];
                annotationView.frame = CGRectMake(self.frame.size.width - annotationView.frame.size.width - SGMovableStack_Inset * (size - i),
                                                  self.frame.size.height - annotationView.frame.size.height - SGMovableStack_Inset * (size - i),
                                                  annotationView.frame.size.width,
                                                  annotationView.frame.size.height);
            
                [self bringSubviewToFront:annotationView];
            }
        }
    }
}

- (void) emptyStack:(BOOL)stillCaptured
{
    for(SGAnnotationView* view in movableStack) {
        [view removeFromSuperview];
        view.isCaptured = stillCaptured;
    }
    
    [movableStack removeAllObjects];
    [self removeFromSuperview];
}

- (NSArray*) stack
{
    return movableStack;
}

- (void) drawStackAtPoint:(CGPoint)point roll:(double)roll
{
    self.frame = CGRectMake(point.x - self.frame.size.width / 2.0,
                            point.y - self.frame.size.height,
                            self.frame.size.width,
                            self.frame.size.height);    
}


- (void) dealloc
{
    [movableStack release];
    [arView release];
    
    [super dealloc];
}

@end
