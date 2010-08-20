//
//  SGAnnotationView.h
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

#import "SGTexture.h"
#import "SGMath.h"

@protocol SGAnnotationViewDelegate;

/*!
* @class SGAnnotationView
* @abstract Used to display information about @link //simplegeo/ooc/intf/SGRecordAnnotation/SGAnnotation SGAnnotation @/link in an AR enviornment.
* @discussion SGAnnotationViews are the only views that can be rendered in the @link //simplegeo/ooc/cl/SGARView SGARView @/link.
* The annotation view has two different modes, when it is being inspected and when it is not being inspected. You can toggle through
* inspection modes by calling @link inspectView: inspectView: @/link. When an annotation view is created it calls @link inspectView: inspectView: @/link
* on itself with the value NO. When NO is specifed the view enters into target mode. If YES is passed into @link inspectView: inspectView: @/link, the view switches
* to inspect mode.
* Target mode is intended to be just a target in in the AR enviornment; something that allows the user to inspect further by generating a touch event. When
* a touch event occurs on an annotation view, @link shouldInspectAnnotationView: shouldInspectAnntationView: @/link is called. Anytime throughout the life-cycle of
* the view, you can call @link inspectView: inspectView: @/link and it will change its subviews properly, independent of its enviornment.
* A SGAnnotationView has two display enviornments. The first is within the augmented reality view. The second is as a UIView was intended, using CoreAnimation. When the view is within
* the AR enviornment, the orign within the @link frame frame @/link is ignored. The AR enviornment must place the view based on its relative position of the device and
* the coordinate obtained from @link annotation annotation @/link. When the annotation view is rendered as a UIView, in most cases,
* it will be a subview of @link SGARView SGARView @/link.
*/
@interface SGAnnotationView : UIView {

    id<MKAnnotation> annotation;
    
    NSString* reuseIdentifier;
    
    UIImageView* targetImageView;
    id<SGAnnotationViewDelegate> delegate;
    
    double bearing;
    double distance;
    double altitude;
    
    // This should probably be a bit-mask.
    BOOL enableOpenGL;
    BOOL isCapturable;    
    BOOL isCaptured;
    BOOL isSelected;    
    
    UIButton* radarTargetButton;
    UIImage* containerImage;
        
    @private    
    SGPoint3* point;
    SGTexture* texture;
    SGTexture* radarPointTexture;
    
    BOOL needNewTexture;
}

/*!
* @property
* @abstract The source of the view's location in the AR enviornment.
*/
@property (nonatomic, assign) id<MKAnnotation> annotation;

/*!
* @property
* @abstract Use this identifier to dequeue unused annotation views from @link //simplegeo/ooc/cl/SGARView SGARView @/link.
*/
@property (nonatomic, readonly) NSString* reuseIdentifier;

/*!
* @property
* @abstract The image that is shown when the @link targetType targetType @/link is set to
* @link kSGAnnotationViewTargetType_Glass kSGAnnotationViewTargetType_Glass @/link.
*/
@property (nonatomic, retain, readonly) UIImageView* targetImageView;

/*!
* @property
* @abstract The delegate that recieves inspection and close notifications.
*/
@property (nonatomic, assign) id<SGAnnotationViewDelegate> delegate;

/*!
* @property
* @abstract Ignores the UIView components of the view, and calls @link drawAnnotationView drawAnnotationView @/link
* when it needs to be rendered in the AR enviornment.
*/
@property (nonatomic, assign) BOOL enableOpenGL;

/*!
* @property
* @abstract The bearing of the view calculated from the @link //simplegeo/ooc/instn/SGAnnotation annotation @/link
* and the device's current location. Bearing is expressed in radians.
*/
@property (nonatomic, assign) double bearing;

/*!
* @property
* @abstract The distance of the view calculated from the @link //simplegeo/ooc/instn/SGAnnotation annotation @/link
* and the device's current location. Distance is expressed in meters.
*/
@property (nonatomic, assign) double distance;

/*!
* @property
* @abstract The altitude of the view. The default is 0. Altitude is expressed in meters.
*/
@property (nonatomic, assign) double altitude;

/*!
* @property
* @abstract The UIButton that is displayed in the @link //simplegeo/ooc/cl/SGRadar SGRadar @/link.
*/
@property (nonatomic, readonly) UIButton* radarTargetButton;

/*!
* @property
* @abstract If YES, the view can be added to the @link //simplegeo/ooc/cl/SGMovableStack SGMovableStack @/link. Otherwise, NO.
*/
@property (nonatomic, assign) BOOL isCapturable;

/*!
* @property
* @abstract If YES, the view is either added to a @link //simplegeo/ooc/cl/SGMovableStack SGMovableStack @/link or
* a @link //simplegeo/ooc/cl/SGAnnotationViewContainer SGAnnotationViewContainer @/link. Otherwise, NO.
*/
@property (nonatomic, assign) BOOL isCaptured;

/*!
* @property
* @abstract The point at which the @link texture texture @/link is drawn
* in the OpenGL environment.
* @discussion This property should never be mutated by anything else
* besides @link //simplegeo/ooc/cl/SG3DOverlayEnvironment SG3DOverlayEnvironment @/link. The value
* is set everytime the view is drawn in OpenGL and is only referenced whenever a touch event occurs
* on the @link //simplegeo/ooc/cl/SG3DOverlayView SG3DOverlayView @/link.
*/
@property (nonatomic, assign) SGPoint3* point;

/*!
* @property
* @abstract The texture that represents this view.
*/
@property (nonatomic, readonly) SGTexture* texture;

/*!
* @property
* @abstract Determines whether or not a new texture needs to be
* generated for this view.
*/
@property (nonatomic, assign) BOOL needNewTexture;

/*!
* @property
* @abstract The image used to display in a 
* @link //simplegeo/ooc/cl/SGAnnotationViewContainer SGAnnotationViewContainer @/link when the view
* has reached the top of the stack.
*/
@property (nonatomic, retain) UIImage* containerImage;

/*!
* @method initWithFrame:reuseIdentifier:
* @abstract Initialize a new annotation view.
* @param frame The frame of the view.
* @param identifier ￼The identifier for the view.
* @result A new instance of SGAnnotationView.
*/
- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier;

/*!
* @method prepareForReuse
* @abstract Called when the view is removed from the reuse queue.
* @discussion The default implementaiton of this method resets its subviews. You can override it in your custom annotation views
* and use it to put the view in a specific state.
*/
- (void) prepareForReuse;

/*!
* @method drawAnnotationView
* @abstract ￼The current implementation of this method does nothing. If @link enableOpenGL enableOpenGL @/link is set to YES, then
* this method will be called everytime the AR enviornment needs to render the view. 
*/
- (void) drawAnnotationView;

@end

/*!
* @protocol SGAnnotationViewDelegate
* @abstract Callback methods for @link //simplegeo/ooc/cl/SGAnnotationView SGAnnotationViews @link when
* they recieve touch events.
* @discussion Every annotation view has two modes: target and inspect. Target is the default mode. When the view is clicked,
* @link shouldInspectAnnotationView: shouldInspectAnnotationView: @/link is called.
* If the delegate returns a view, the annotation view will move into inspect mode.
*/
@protocol SGAnnotationViewDelegate <NSObject>

@optional

/*!
* @method shouldInspectAnnotationView:
* @abstract ￼Asks the delegate whether the view should be inspected.
* @discussion Notice how the return value is a UIView. You do not have to return the annotation
* view that is passed in. You can create your own view to display. If you return the same
* annotation view that was passed in, the AR view will call @link //simplegeo/ooc/instm/inspectView: inspectView: @/link.
* If any view is returned, the view will be added to the AR view as a subview and will no longer be rendered in the AR
* enviornment.
*             
* @param view ￼The view that is in question.
* @result Any UIView if the view should enter into inspection mode; otherwise NO.
*/
- (UIView*) shouldInspectAnnotationView:(SGAnnotationView*)view;

@end
