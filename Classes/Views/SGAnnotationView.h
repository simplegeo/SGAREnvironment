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

/*!
* @enum Inspector Styles
* @abstract ￼The style of the view when it is being inspected.
* @discussion ￼The default style is kSGAnnotationViewInspectorType_Standard.
* @constant ￼kSGAnnotationViewInspectorType_None When inspected, nothing will show.
* @constant ￼kSGAnnotationViewInspectorType_Standard Displays a title, date, and the target image.
* @constant ￼kSGAnnotationViewInspectorType_Message Displays a title, date, message, and the target image.
* @constant ￼kSGAnnotationViewInspectorType_Photo Displays a title, date, message, photo, and the target image.
* @constant ￼kSGAnnotationViewInspectorType_Custom Displays the current layout of the view.
*/
enum SGAnnotationViewInspectorType {
    
    kSGAnnotationViewInspectorType_None = 0,
    kSGAnnotationViewInspectorType_Standard,
    kSGAnnotationViewInspectorType_Message,
    kSGAnnotationViewInspectorType_Photo,
    kSGAnnotationViewInspectorType_Custom
    
};

typedef NSInteger SGAnnotationViewInspectorType;

/*!
* @enum Target Styles
* @abstract The style of the view when it is loaded in the @link SGARView SGARView @/link.
* @discussion ￼The default style is kSGAnnotationViewTargetType_Pin.
* @constant ￼kSGAnnotationViewTargetType_Pin Displays a pin that resemebles the pin from MKPinAnnotationView.
* @constant ￼kSGAnnotationViewTargetType_Glass Displays the Target image over a glassy, pointed square.
* @constant kSGAnnotationViewTargetType_Custom Displays the current layout of the view.
*/
enum SGAnnotationViewTargetType {
 
    kSGAnnotationViewTargetType_Pin = 0,
    kSGAnnotationViewTargetType_Glass,
    kSGAnnotationViewTargetType_Custom
    
};

typedef NSInteger SGAnnotationViewTargetType;

enum SGPinColor {
 
    kSGPinColor_Red,
    kSGPinColor_Blue
};

typedef NSInteger SGPinColor;

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
    
    SGAnnotationViewInspectorType inspectorType;
    SGAnnotationViewTargetType targetType;
    
    UILabel* detailedLabel;
    UILabel* titleLabel;
    UILabel* messageLabel;
    
    UIImageView* targetImageView;
    UIImageView* photoImageView;
    
    UIButton* closeButton;

    id<SGAnnotationViewDelegate> delegate;
    
    double bearing;
    double distance;
    double altitude;
    
    // This should probably be a bit-mask.
    BOOL enableOpenGL;
    BOOL isBeingInspected;
    BOOL isCapturable;    
    BOOL isCaptured;
    BOOL isSelected;    
    
    SGPinColor pinColor;
    UIButton* radarTargetButton;
    
    UIImage* containerImage;
        
    @private
    UIImageView* backgroundImageView;
    UIImageView* topExpandedBGImageView;
    UIImageView* middleExpandedBGImageView;
    UIImageView* bottomExpandedBGImageView;
    
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
* @abstract The style of the view when it is being inspected.
*/
@property (nonatomic, assign) SGAnnotationViewInspectorType inspectorType;

/*!
* @property
* @abstract The style of the view when it is not being inspected.
*/
@property (nonatomic, assign) SGAnnotationViewTargetType targetType;

/*!
* @property
* @abstract A detailed label that is used when @link inspectorType inspectorType @/link is not
* @link kSGAnnotationViewInspectorType_Custom kSGAnnotationViewInspectoryType_Custom @/link and
* the view is in inspect mode.
*/
@property (nonatomic, retain, readonly) UILabel* detailedLabel;

/*! 
* @property
* @abstract A title label that is used when @link inspectoryType inspectorType @/link is not
* in @link kSGAnnotationViewInspectorType_Custom kSGAnnotationViewInspectorType_Custom @/link and
* the view is in inspect mode.
*/
@property (nonatomic, retain, readonly) UILabel* titleLabel;

/*!
* @property
* @abstract A title label that is used when @link inspectoryType inspectorType @/link is not
* in @link kSGAnnotationViewInspectorType_Custom kSGAnnotationViewInspectorType_Custom @/link and
* the view is in inspect mode.
*/
@property (nonatomic, retain, readonly) UILabel* messageLabel;

/*!
* @property
* @abstract A title label that is used when @link inspectoryType inspectorType @/link is not
* in @link kSGAnnotationViewInspectorType_Custom kSGAnnotationViewInspectorType_Custom @/link and
* the view is in inspect mode.
*/
@property (nonatomic, retain, readonly) UIImageView* photoImageView;

/*!
* @property
* @abstract A close button that is used when @link inspectoryType inspectorType @/link is not
* in @link kSGAnnotationViewInspectorType_Custom kSGAnnotationViewInspectorType_Custom @/link and
* the view is in inspect mode.
* @discussion The default position is in the upper left-hand corner of the view.
*/
@property (nonatomic, retain, readonly) UIButton* closeButton;

/*!
* @property
* @abstract The pin color to use when the view is in target mode and @link targetType targetType @/link is set
* @link kSGAnnotationViewTargetType_Pin kSGAnnotationViewTargetType_Pin @/link. The default is @link kSGPinColor_Red kSGPinColor_Red @/link.
*/
@property (nonatomic, assign) SGPinColor pinColor;

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
* @abstract If YES, the the view is in inspect mode. Otherwise; NO.
*/
@property (nonatomic, readonly) BOOL isBeingInspected;

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
* @abstract If YES, the view is in a selected state which was either set a UITouchEvent or explicity through
* the setter. Otherwise, NO.
*/
@property (nonatomic, assign) BOOL isSelected;

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
* @method initAtPoint:reuseIdentifier:
* @abstract Initialize a new annotation view.
* @param pt The origin of the view when it is not being drawn in the AR enviornment.
* @param identifier ￼The identifier for the view.
* @result A new instance of SGAnnotationView.
*/
- (id) initAtPoint:(CGPoint)pt reuseIdentifier:(NSString*)identifier;

/*!
* @method prepareForReuse
* @abstract Called when the view is removed from the reuse queue.
* @discussion The default implementaiton of this method resets its subviews. You can override it in your custom annotation views
* and use it to put the view in a specific state.
*/
- (void) prepareForReuse;


/*!
* @method inspectView:
* @abstract Changes the inspection type of the view.
* @param inspect ￼YES will put the view in inspect mode. NO wil put the view in target mode.
*/
- (void) inspectView:(BOOL)inspect;

/*!
* @method close
* @abstract Only works in inspector mode. Returns the view back to target mode.
* @discussion ￼If the annotation view is a subview of the AR view, it will @link //apple_ref/ooc/instm/UIView/removeFromSuperview: removeFromSuperview: @/link
* and call @link inspectView: inspectView: @/link with NO. The annotation view should then return back to target mode join back with
* its brothers.
*/
//- (void) close;

/*!
* @method setContainerImage:
* @abstract ￼The UIImage that will be displayed when this view is added to an instance of @link //simplegeo/ooc/cl/SGAnnotationViewContainer SGAnnotationViewContainer @/link.
* The default image is the UIImage representation of the current layout of the annotaiton view.
* @param image ￼
*/
- (void) setContainerImage:(UIImage*)image;

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

/*!
* @method shouldCloseAnnotationView:
* @abstract ￼Asks the delegate whether the annotation view should be removed as a subview of @link //simplegeo/ooc/cl/SGARView SGARView @/link and place
* back in the AR enviornment.
* and enter back into identifier mode.
* @discussion See @link //simplegeo/ooc/instp/SGAnnotationView/closeButton SGAnnotationView @/link
* @param view ￼The view that is in question.
* @result YES if the view should leave return back to the AR enviornment; otherwise NO.
*/
- (BOOL) shouldCloseAnnotationView:(SGAnnotationView*)view;

@end
