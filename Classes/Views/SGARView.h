//
//  SGAREnvironment.h
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

#if __IPHONE_4_0 && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && !TARGET_IPHONE_SIMULATOR

#import <AVFoundation/AVFoundation.h>

#endif

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class SG3DOverlayEnvironment;
@class SG3DOverlayView;

enum SGChromeComponent {
 
 kSGChromeComponent_Gridlines = 1 << 0,
 kSGChromeComponent_Radar = 1 << 1,
 kSGChromeComponent_MovableStack = 1 << 2,
 kSGChromeComponent_Containers = 1 << 3
 
};

typedef NSUInteger SGChromeComponent;

#import "SGControlEvents.h"

@class SGAnnotationView;
@class SGRadar;
@class SGMovableStack;
@class SGAnnotationViewContainer;

@protocol SGARViewDataSource;
@protocol SGAnnotation;
@protocol SGARResponder;

/*!
* @class SGARView
* @abstract Displays @link //simplegeo/ooc/intf/SGAnnotation SGAnnotations @/link in an augmented reality enviornment.
* @discussion The main intention of this class is to be used as the cameraOverlayView for @link UIImagePickerController UIImagePickerController @/link
* when the camera source type is selected. You can easily create this as a subview of another view and still achieve the same effect if 
* you wish.
*
* The SRARView is responsible for rendering the entire augmented reality scene. The view asks the @link SGARViewDataSource data source @/link
* for the annotations and their corresponding views.
*/
@interface SGARView : UIView
{
    id<SGARViewDataSource> dataSource;
 
    CLLocationManager* locationManager;
 
    SGRadar* radar;
 	SGMovableStack* movableStack;
 
 	BOOL enableWalking;
 	BOOL enableGridLines;
 
    UIColor* gridLineColor;

    CGPoint walkingOffset;
 
    @private
    NSMutableDictionary* annotationViews;
    NSMutableArray* overlaySubviews;
 
    SG3DOverlayView* openGLOverlayView;
    SG3DOverlayEnvironment* enviornmentDrawer;
 
    float* gridLines; 
    CGFloat* gridLineColorComponents;
 
    BOOL dragging;
    SGAnnotationViewContainer* previousContainer;
    CGPoint touchPoint;
 
    NSMutableArray* containers;
    
#if __IPHONE_4_0 && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && !TARGET_IPHONE_SIMULATOR
    
    AVCaptureVideoPreviewLayer* cameraBackgroundLayer;
    AVCaptureSession* captureSession;

#endif
}


/*!
* @property
* @abstract See @link SGARViewDataSource data source @/link
*/
@property (nonatomic, assign) id<SGARViewDataSource> dataSource;

/*!
* @property
* @abstract The location manager that is used for obtaining the heading and location of the device.
*/
@property (nonatomic, readonly) CLLocationManager* locationManager;

/*!
* @property
* @abstract The @link //simplegeo/ooc/cl/SGRadar radar @/link that is associated with the AR view.
*/
@property (nonatomic, retain) SGRadar* radar;

/*!
* @property
* @abstract YES if gridlines should be drawn. Otherwize; NO. The default is NO.
*/
@property (nonatomic, assign) BOOL enableGridLines;

/*!
* @property
* @abstract Allows a user to move around in the AR view.
* @discussion The notion of walking just means that the user is able to create touch events that will move them
* in the direction at which they are facing in the AR enviornment. For example, if a user is facing North and they create a pinch
* gesture, they will decrease the distance between their current position in the AR view to the records that
* are displayed directly North of them. The change in position is reflected both in the AR enviornment and also in the @link radar radar @/link.
*
* The following gestures will generate the effect: pinch => forward, pull => backward, double tap => move forward 3 meters, and single tap => move
* backward 3 meters.
*/
@property (nonatomic, assign) BOOL enableWalking;

/*!
* @property
* @abstract The color of the grid lines.
*/
@property (nonatomic, retain) UIColor* gridLineColor;

/*!
* @property
* @abstract The @link //simplegeo/ooc/cl/SGMovableStack movable stack @/link that is present when a drag event
* is produced over a @link //simplegeo/ooc/cl/SGAnnotationView annotation view @/link within the AR enviornment.
* @discussion If a movable to stack is present, it will be added as a subview of @link //simplegeo/ooc/cl/SGARView SGARView @/link. Set
* this property to nil in order to not allow views to be collected.
*/
@property (nonatomic, retain) SGMovableStack* movableStack;

/*!
* @property
* @abstract The offset from the origin to use when placing the annotation views
* within the @link radar radar @/link.
* @discussion This value is set when either the 
* @link @link //simplegeo/ooc/cl/SG3DOverlayEnvironment SG3DOverlayEnvrionment @/link
* generates a pinch, pull or double tap control event. See @link //simplegeo/ooc/intf/SG3DOverlayViewDelegate SG3DOverlayViewDelegate @/link.
* Also, @link enableWalking enableWalking @/link must be set to YES in order
* for the walking offset to be applied to the environment when the proper control signals are generated. 
*/
@property (nonatomic, assign) CGPoint walkingOffset;

/*!
* @method dequeueReuseableAnnotationViewWithIdentifier:
* @abstract ￼Returns an unused, pre-allocate @link SGAnnotationView SGAnnotationView @/link view if one is available.
* @discussion This methods behaves identically to that of UITableView's dequeue method. After a call
* to @link reloadData reloadData @/link, the view will remove all views from the enviornment and
* prepare them all for reuse.
* @param viewId ￼The identifier associated with the desired annotation view.
* @result ￼An unused object view; otherwise nil if there are none.
*/
- (SGAnnotationView*) dequeueReuseableAnnotationViewWithIdentifier:(NSString*)viewId;

/*!
* @method reloadData
* @abstract ￼ Removes all annotation views from the envoirnment and loads in a new data set from @link dataSource dataSource @/link
* using the devices current location.
* @discussion Once reloadData is called, all annotaiton views are sent @link //simplegeo/ooc/instm/SGAnnotationView/prepareForReuse prepareForReuse @/link.
* The views are then awaiting to be dequeue and resused.
*/
- (void) reloadData;

/*!
* @method reloadData
* @abstract ￼ Removes all annotation views from the envoirnment and loads in a new data set from @link dataSource dataSource @/link
* using the location passed in.
* @discussion Once reloadData is called, all annotaiton views are sent @link //simplegeo/ooc/instm/SGAnnotationView/prepareForReuse prepareForReuse @/link.
* The views are then awaiting to be dequeue and resused.
* @param location The location to load data for.
*/
- (void) reloadDataForLocation:(CLLocation*)location;

/*!
* @method startAnimation
* @abstract ￼ Begins rendering the AR enviornment.
* @discussion ￼ See @link stopAnimation stopAnimation @/link
*/
- (void) startAnimation;

/*!
* @method stopAnimation
* @abstract ￼ Stops rendering the augment reality view.
* @discussion ￼ You can use both this method and @link startAnimation startAnimation @/link to create
* a freeze frame wihin the augmented reality or just to stop the rendering process altogether.
* You must call @link clear clear @/link in order to reset the entire view.
*/
- (void) stopAnimation;

/*!
* @method clear
* @abstract ￼ Resets the view sending a release call to all annotation views.
* @discussion This is much different then @link reloadData reloadData @/link. It does not go through the entire
* process of asking the @link dataSource dataSource @/link for new annotations. It assumes that you no longer
* want to display anything in the AR enviornment and that your only desire is to have a blank camera view.
*/
- (void) clear;

/*!
* @method addResponder:
* @abstract ￼Adds a @link //simplegeo/ooc/cl/SGARResponder responder @/link to the responder chain to be notified of incoming
* touch events and gestures.
* @param responder ￼The responder to add.
*/
- (void) addResponder:(id<SGARResponder>)responder;


/*!
* @method removeResponder:
* @abstract ￼Removes the a @link //simplegeo/ooc/cl/SGARResponder responder @/link from the responder chain.
* @param responder ￼The responder to remove.
*/
- (void) removeResponder:(id<SGARResponder>)responder;

/*!
* @method addContainer:
* @abstract ￼Adds a new conatiner as a subview of the @link //simplegeo/ooc/cl/SGARView SGARView @/link.
* @discussion If the container has served its purpose, call @link removeContainer: removeContainer: @/link to remove it from its
* superview. If the view is hidden or transparent in some way, it is still liable for touch events.
* @param container ￼The @//simplegeo/ooc/cl/SGAnnotationViewContainer SGAnnotationViewContainer @/link. 
*/
- (void) addContainer:(SGAnnotationViewContainer*)container;

/*!
* @method removeContainer:
* @abstract Remove the conatiner from its superview and unregister it from touch events.
* @param container ￼The @//simplegeo/ooc/cl/SGAnnotationViewContainer SGAnnotationViewContainer @/link to remove.
*/
- (void) removeContainer:(SGAnnotationViewContainer*)container;

/*!
* @method getContainers
* @abstract ￼ Returns all @link //simplegeo/ooc/cl/SGAnnotationViewContainer SGAnnotationViewContainers @/link that are currently
* registered with the @link //simplegeo/ooc/cl/SGARView SGARView @/link.
* @result ￼ An array of @link //simplegeo/ooc/cl/SGAnnotationViewContainer SGAnnotationViewContainers @/link.
*/
- (NSArray*) getContainers;

- (void) drawComponent:(SGChromeComponent)chromeComponent heading:(double)heading roll:(double)roll;
- (BOOL) hitTestAtPoint:(CGPoint)point withEvent:(SGControlEvent)event;
- (void) empty;

#if __IPHONE_4_0 && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && !TARGET_IPHONE_SIMULATOR

- (void) startCaptureSession;
- (void) stopCaptureSession;
- (void) resizeCameraBackgroundLayer;

#endif

@end

/*!
* @protocol SGARViewDataSource
* @abstract Responsible for providing all the annotations and their views.
*/
@protocol SGARViewDataSource <NSObject>

/*!
* @method arView:annotationsAtLocation:
* @abstract ￼Provides the annotations for the location.
* @param arView The @link SGARView AR view @/link that needs annotations.
* @param location ￼The location.
* @result ￼An array of @link //simplegeo/ooc/cl/SGAnnotation annotations @/link.
*/
- (NSArray*) arView:(SGARView*)arView annotationsAtLocation:(CLLocation*)location;

/*!
* @method arView:viewForAnnotation:
* @abstract ￼Provides the view for the specified @link //simplegeo/ooc/cl/SGAnnotation annotation @/link.
* @discussion This allows the data source to prepare the annotation for display (e.g. changing location, title). You can also
* return a nil value which would not display a view for the specified annotation.
* @param arView ￼The @link SGARView AR view @/link that needs views for its annotaitons.
* @param annotation The annotation that nee￼ds a view.
* @result ￼The view for the annotation.
*/
- (SGAnnotationView*) arView:(SGARView*)arView viewForAnnotation:(id<MKAnnotation>)annotation;

@optional

/*!
* @method arView:didAddAnnotationViews:
* @abstract ￼Notifies the delegate when @link //simplegeo/ooc/cl/SGAnnotationView SGAnnotationViews @/link have
* been added to the arView.
* @param arView ￼The @link SGARView SGARView @/link that added the annotation views.
* @param views ￼The annotation views.
*/
- (void) arView:(SGARView*)arView didAddAnnotationViews:(NSArray*)views;

@end

