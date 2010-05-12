//
//  SG3DOverlayView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@protocol SG3DOverlayViewDelegate;

@interface SG3DOverlayView : UIView
{
    @private
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	GLuint viewRenderbuffer, viewFramebuffer;
	GLuint depthRenderbuffer;
	
	CADisplayLink* displayLink;
	NSTimeInterval animationInterval;
	
	
	id<SG3DOverlayViewDelegate> delegate;
	
	// Flag to denote that the -setupView method of a delegate has been called.
	// Resets to NO whenever the delegate changes.
	BOOL delegateSetup;
    
    UIView* mainSubview;
    
    // Gesture detection
    CGFloat initialTouchDistance;
    NSTimer* pinchTimer;
    
    CGPoint singleGestureStartPoint;
    
    BOOL swipeOccurred;
    BOOL zoomOccurred;
    BOOL dragging;
    
    double currentSphereRadius;
}

@property(nonatomic, assign) id<SG3DOverlayViewDelegate> delegate;

- (void) startAnimation;
- (void) stopAnimation;
- (void) drawView;

@property NSTimeInterval animationInterval;

@end

@protocol SG3DOverlayViewDelegate <NSObject>

@required

- (void) initiate;
- (void) cleanUp;
- (void) drawView:(SG3DOverlayView*)view;

@optional

- (void) setupView:(SG3DOverlayView*)view;

// UIResponder call backs
- (void) view:(SG3DOverlayView*)view ARSingleTap:(CGPoint)point;
- (void) view:(SG3DOverlayView*)view ARDoubleTap:(CGPoint)point;
- (void) view:(SG3DOverlayView*)view tapReleased:(CGPoint)point;

- (void) view:(SG3DOverlayView*)view ARSingleTapAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo;

- (void) view:(SG3DOverlayView*)view ARPinchAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo withDistance:(CGFloat)distance;
- (void) view:(SG3DOverlayView*)view ARPullAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo withDistance:(CGFloat)distance;

- (void) view:(SG3DOverlayView*)view ARMoveFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
- (void) view:(SG3DOverlayView*)view ARMoveEndedAtPoint:(CGPoint)point;

- (void) view:(SG3DOverlayView*)view ARHorizontalSwipeAtPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
- (void) view:(SG3DOverlayView*)view ARVerticalSwipeAtPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

- (void) ARViewDidShake:(SG3DOverlayView*)view;


@end