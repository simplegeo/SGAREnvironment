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

/*!
* @class 
* @abstract This view is in charge of allocating and maintaining the CAEAGLLayer that 
* is to draw the AR environment.
* @discussion All touch events are sent through this view and they are handled by 
* the @link SG3DOverlayViewDelegate SG3DOverlayViewDelegate @/link. Although this view
* maintains the OpenGL layer, it is not in charge of setting it up or manipulating
* matrices. Once again, that job is delegated to @link SG3DOverlayViewDelegate SG3DOverlayViewDelegate @/link.
*/
@interface SG3DOverlayView : UIView
{
    @private
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext* context;
	
	GLuint viewRenderbuffer, viewFramebuffer;
	GLuint depthRenderbuffer;
	
	CADisplayLink* displayLink;
	NSTimeInterval animationInterval;
	
	id<SG3DOverlayViewDelegate> delegate;
	
	BOOL delegateSetup;
    
    UIView* mainSubview;

    CGFloat initialTouchDistance;
    NSTimer* pinchTimer;
    
    CGPoint singleGestureStartPoint;
    
    BOOL swipeOccurred;
    BOOL zoomOccurred;
    BOOL dragging;
    
    double currentSphereRadius;
}

/*!
* @property
* @abstract The delegate that is in charge of handling touch
* events and drawing the OpenGL environment.
*/
@property(nonatomic, assign) id<SG3DOverlayViewDelegate> delegate;

/*!
* @method startAnimation
* @abstract Adds a CADisplayLink to the current run loop which will
* call the drawView method for a given interval.
*/
- (void) startAnimation;

/*!
* @method stopAnimation
* @abstract ￼Removes the CADisplayLink from the current run loop
* and clears the OpenGL scene.
*/
- (void) stopAnimation;

@end

/*!
* @protocol SG3DOverlayViewDelegate
* @abstract 
* @discussion 
*/
@protocol SG3DOverlayViewDelegate <NSObject>

@required

/*!
* @method initiate
* @abstract ￼This method gets called before @link startAnimation startAnimation @/link
* is called.
* @discussion This gives the delegate the opportunity to hook anything into the environment
* before it is asked to be drawn.
*/
- (void) initiate;

/*!
* @method cleanUp
* @abstract ￼This method gets called after @link stopAnimation stopAnimation @/link
* is executed.
* @discussion This gives the delegate the opportunity to cleanup any lingering
* artifacts.
*/
- (void) cleanUp;

/*!
* @method drawView:
* @abstract ￼The implementation of this method should render the entire OpenGL scene.
* @param view ￼The "subclass" of CAEAGLLayer that wants to be drawn. 
*/
- (void) drawView:(SG3DOverlayView*)view;

@optional

/*!
* @method setupView:
* @abstract The implemenation of this mehtod should setup the OpenGL environment.
* @discussion This method is called only once for the entire lifetime of an
* animation sequence. The resposibilities of this method are to initialize the
* projection matrix and to setup the OpenGL state machine.
* @param view ￼The "subclass" of CAEAGLLayer that wants to be drawn. 
*/
- (void) setupView:(SG3DOverlayView*)view;

/*!
* @method view:ARSingleTap:
* @abstract This method is called when a single touch event is generated
* ￼in the view.
* @param view ￼The view that received the touch event.
* @param point ￼The point in the view where the touch event occurred.
*/
- (void) view:(SG3DOverlayView*)view ARSingleTap:(CGPoint)point;

/*!
* @method view:ARDoubleTap:
* @abstract ￼This method is called when a double touch event is generated
* in the view.
* @param view ￼The view that received the touch event.
* @param point The point in the view where the touch event occurred. ￼
*/
- (void) view:(SG3DOverlayView*)view ARDoubleTap:(CGPoint)point;

/*!
* @method view:tapReleased:
* @abstract ￼This method is called when a touch event is released.
* @param view ￼The view that received the touch event.
* @param point ￼The point in the view where the touch event was released.
*/
- (void) view:(SG3DOverlayView*)view tapReleased:(CGPoint)point;

/*!
* @method view:ARSingleTapAtPoint:andPoint:
* @abstract ￼This method is called when a multi-touch event is detected.
* @param view ￼The view that received the touch event.
* @param pointOne ￼The first point in the view where the touch event occurred.
* @param pointTwo ￼The second point in the view where the touch event occurred.
*/
- (void) view:(SG3DOverlayView*)view ARSingleTapAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo;

/*!
* @method view:ARPinchAtPoint:andPoint:withDistance:
* @abstract ￼This method is called when a pinch event is detected.
* @param view ￼The view that received the touch event.
* @param pointOne ￼The first point in the view where the pinch event occurred.
* @param pointTwo ￼The second point in the view where the pinch event occurred.
* @param distance ￼The distance between the two points.
*/
- (void) view:(SG3DOverlayView*)view ARPinchAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo withDistance:(CGFloat)distance;

/*!
* @method view:ARPullAtPoint:andPoint:withDistance:
* @abstract ￼This method is called when a pull event is detected.
* @param view ￼The view that received the touch event.
* @param pointOne ￼The first point in the view where the pull event occurred.
* @param pointTwo ￼The second point in the view where the pull event occurred.
* @param distance ￼The distance between the two points.
*/
- (void) view:(SG3DOverlayView*)view ARPullAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo withDistance:(CGFloat)distance;

/*!
* @method view:ARMoveFromPoint:toPoint:
* @abstract ￼This method is called when a drag event is detected.
* @param view ￼The view that received the touch event.
* @param fromPoint ￼The starting point in the view where the drag occurred.
* @param toPoint ￼The ending point in the view where the drag occured.
*/
- (void) view:(SG3DOverlayView*)view ARMoveFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

/*!
* @method view:ARMoveEndedAtPoint:
* @abstract ￼This method is called when a drag event finished.
* @param view ￼The view that received the touch event.
* @param point ￼The point where the draging event finished.
*/
- (void) view:(SG3DOverlayView*)view ARMoveEndedAtPoint:(CGPoint)point;

/*!
* @method view:ARHorizontalSwipeAtPoint:toPoint:
* @abstract ￼This method is called when a horizontal swipe is detected.
* @param view ￼The view that received the touch event.
* @param fromPoint ￼The starting point of the swipe.
* @param toPoint ￼The ending point of the swipe.
*/
- (void) view:(SG3DOverlayView*)view ARHorizontalSwipeAtPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

/*!
* @method view:ARVerticalSwipeAtPoint:toPoint:
* @abstract ￼This method is called when a vertical swipe is detected.
* @param view ￼The view that received the touch event.
* @param fromPoint ￼The starting point of the swipe.
* @param toPoint ￼The ending point of the swipe.
*/
- (void) view:(SG3DOverlayView*)view ARVerticalSwipeAtPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

/*!
* @method ARViewDidShake:
* @abstract ￼This method is called when the view is shaken.
* @param view ￼The view that received the shake.
*/
- (void) ARViewDidShake:(SG3DOverlayView*)view;

@end