//
//  SG3DOverlayView.m
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

#import "SG3DOverlayView.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "SGEnvironmentConstants.h"
#import "SGMath.h"

#define kMinimumGestureLength               1000.0f
#define kMaximumVariance                    20.0f

@interface SG3DOverlayView (Private)

- (id) initGLES;
- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

- (void) clearTouches;

@end

@implementation SG3DOverlayView

@synthesize animationInterval;

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

-(id) initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame]) {
        
		self = [self initGLES];
	}
    
	return self;
}

-(id) initGLES
{
    self.multipleTouchEnabled = YES;
    self.exclusiveTouch = YES;

	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
	
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];

	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
        
		[self release];
		return nil;
        
	}
	
    self.backgroundColor = [UIColor clearColor];
    
    mainSubview = [[UIView alloc] initWithFrame:self.frame];
    mainSubview.backgroundColor = [UIColor clearColor];
                   
	animationInterval = 1.0;
    pinchTimer = nil;
    dragging = NO;
    currentSphereRadius = 0.0;
    
    [self clearTouches];
    
	return self;
}

- (id<SG3DOverlayViewDelegate>) delegate
{
	return delegate;
}

- (void) setDelegate:(id<SG3DOverlayViewDelegate>)d
{
	delegate = d;
	delegateSetup = ![delegate respondsToSelector:@selector(setupView:)];
}

- (void) layoutSubviews
{    
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self drawView];
}

- (BOOL) createFramebuffer
{
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        
		SGLog(@"SG3DOverlayView - failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void) destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (void) startAnimation
{
    
    if(!displayLink)  {
        [delegate initiate];

        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
        [displayLink setFrameInterval:animationInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void) stopAnimation
{
    if(displayLink) {    
        [displayLink invalidate];
        displayLink = nil;
        
        [delegate cleanUp];
    }
}

- (void) setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval = interval;
	
	if(displayLink) {
		[self stopAnimation];
		[self startAnimation];
	}
}

- (void) drawView
{
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
	
	// If our drawing delegate needs to have the view setup, then call -setupView: and flag that it won't need to be called again.
	if(!delegateSetup || currentSphereRadius != kSGSphere_Radius) {
		[delegate setupView:self];
        
		delegateSetup = YES;
        currentSphereRadius = kSGSphere_Radius;   
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
	[delegate drawView:self];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	GLenum err = glGetError();
	if(err)
		SGLog(@"SG3DOverlayView - %x error", err);
}

#pragma mark -
#pragma mark UIResponder methods  

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSSet* allTouches = [event allTouches];
    NSInteger numberOfTouches = [allTouches count];
    NSInteger tapCount = 0;
    
    if(numberOfTouches == 1) {
        
        UITouch* touchOne = [[allTouches allObjects] objectAtIndex:0];
        tapCount = [touchOne tapCount];
        
        // Save the point for possible swipe
        singleGestureStartPoint = [touchOne locationInView:self];
        
        if(tapCount == 1) {
        
            pinchTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(ARSingleTapDetected:) 
                                                         userInfo:touchOne
                                                          repeats:NO] retain];
        } else {
            
            if(pinchTimer) {
                
                [pinchTimer invalidate];
                [pinchTimer release];
                pinchTimer = nil;
                
            }
                
            if(delegate && [delegate respondsToSelector:@selector(view:ARDoubleTap:)])
                [delegate view:self ARDoubleTap:singleGestureStartPoint];
            
        }
        
    } else if(numberOfTouches == 2) {
        
        if(pinchTimer) {
            
            [pinchTimer invalidate];
            [pinchTimer release];
            pinchTimer = nil;
            
        }        
        
        UITouch* touchOne = [[allTouches allObjects] objectAtIndex:0];
        tapCount = [touchOne tapCount];
        
        if(tapCount == 1) {
            
            UITouch* touchTwo = [[allTouches allObjects] objectAtIndex:1];
            
            CGPoint toPoint = [touchTwo locationInView:self];
            CGPoint fromPoint = [touchOne locationInView:self];
            initialTouchDistance = DistanceBetweenTwoPoints(fromPoint.x, fromPoint.y,
                                                            toPoint.x, toPoint.y);                                                            
            
        }
    }
            
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    
    if([pinchTimer isValid]) {
        [pinchTimer invalidate];
        pinchTimer = nil;
    }
    
    NSSet* allTouches = [event allTouches];
    
    NSInteger touchCount = [allTouches count];
    if(touchCount == 1) {
        
        UITouch* touch = [touches anyObject];
        CGPoint singleGestureCurrentPoint = [touch locationInView:self];
        
        CGFloat deltaX = fabsf(singleGestureStartPoint.x - singleGestureCurrentPoint.x);
        CGFloat deltaY = fabsf(singleGestureStartPoint.y - singleGestureCurrentPoint.y);
        
        if(!swipeOccurred && deltaX >= kMinimumGestureLength && deltaY <= kMaximumVariance) {
            
            // Horizontal swipe
            if(delegate && [delegate respondsToSelector:@selector(view:ARHorizontalSwipeAtPoint:toPoint:)])
                [delegate view:self ARHorizontalSwipeAtPoint:singleGestureStartPoint toPoint:singleGestureCurrentPoint];
            
            swipeOccurred = YES;
            
        } else if(!swipeOccurred && deltaY >= kMinimumGestureLength && deltaX <= kMaximumVariance) {
            
            // Vertical swipe
            if(delegate && [delegate respondsToSelector:@selector(view:ARVerticalSwipeAtPoint:toPoint:)])
                [delegate view:self ARVerticalSwipeAtPoint:singleGestureStartPoint toPoint:singleGestureCurrentPoint];

            swipeOccurred = YES;
            
        } else {
            
            dragging = YES;
            
            // Normal movement
            if(delegate && [delegate respondsToSelector:@selector(view:ARMoveFromPoint:toPoint:)])
                [delegate view:self ARMoveFromPoint:singleGestureStartPoint toPoint:singleGestureCurrentPoint];
            
        }
        
    } else if(touchCount == 2) {
        
        UITouch* touchOne = [[allTouches allObjects] objectAtIndex:0];
        UITouch* touchTwo = [[allTouches allObjects] objectAtIndex:1];
        
        CGPoint pointOne = [touchOne locationInView:self];
        CGPoint pointTwo = [touchTwo locationInView:self];
        
        //Calculate the distance between the two fingers
        CGFloat finalDistance = DistanceBetweenTwoPoints(pointOne.x, pointOne.y, pointTwo.x, pointTwo.y);
        
        BOOL validDelta = abs(finalDistance - initialTouchDistance) > 5.0f;
        
        if(validDelta && initialTouchDistance > finalDistance) {
            
            zoomOccurred = YES;
            // Zoom out
            if(delegate && [delegate respondsToSelector:@selector(view:ARPinchAtPoint:andPoint:withDistance:)])
                [delegate view:self ARPinchAtPoint:pointOne andPoint:pointTwo withDistance:finalDistance];

        } else if(validDelta && initialTouchDistance < finalDistance) {
            
            zoomOccurred = YES;
            // Zoom in
            if(delegate && [delegate respondsToSelector:@selector(view:ARPullAtPoint:andPoint:withDistance:)])
                [delegate view:self ARPullAtPoint:pointOne andPoint:pointTwo withDistance:finalDistance];
            
        }
    }
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSSet* allTouches = [event allTouches];
    
    NSInteger touchCount = [allTouches count];
    if(touchCount == 2) {
        
        if(!zoomOccurred) {
            
            if(delegate && [delegate respondsToSelector:@selector(view:ARSingleTapAtPoint:andPoint:)]) {
             
                CGPoint pointOne = [[[allTouches allObjects] objectAtIndex:0] locationInView:self];
                CGPoint pointTwo = [[[allTouches allObjects] objectAtIndex:1] locationInView:self];
                
                [delegate view:self ARSingleTapAtPoint:pointOne andPoint:pointTwo];
                
            }
        }
        
    }
    
    if(dragging) {
     
        if(delegate && [delegate respondsToSelector:@selector(view:ARMoveEndedAtPoint:)])
            [delegate view:self ARMoveEndedAtPoint:[[allTouches anyObject] locationInView:self]];
        
    }
    
    if(delegate && [delegate respondsToSelector:@selector(view:tapReleased:)])
        [delegate view:self tapReleased:[[[allTouches allObjects] objectAtIndex:0] locationInView:self]];
    
    [self clearTouches];
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self clearTouches];
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent*)event
{
    if(motion == UIEventSubtypeMotionShake) {
        if(delegate && [delegate respondsToSelector:@selector(ARViewDidShake:)])
            [delegate ARViewDidShake:self];
    }
}


- (void) ARSingleTapDetected:(NSTimer*)timer
{
    if([delegate respondsToSelector:@selector(view:ARSingleTap:)])
        [delegate view:self ARSingleTap:singleGestureStartPoint];
}

#pragma mark -
#pragma mark UIView overrides 

- (void) addSubview:(UIView*)view
{
    [self.superview addSubview:mainSubview];
    [mainSubview addSubview:view];
}

#pragma mark -
#pragma mark Helper methods 
 
- (void) clearTouches
{
    initialTouchDistance = -1.0f;
    
    zoomOccurred = NO;
    swipeOccurred = NO;
}

- (void) dealloc
{
	[self stopAnimation];
	
	if([EAGLContext currentContext] == context)
		[EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
    
    [mainSubview release];
    
    if(pinchTimer)
        [pinchTimer release];
	
	[super dealloc];
}

@end
