//
//  SGARViewController.h
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

@protocol SGARViewControllerDataSource;

#import "SGARView.h"

/*!
* @class SGARViewController
* @abstract A subclass of UIImagePickerController that assigns an instance of @link //simplegeo/ooc/cl/SGARView SGARView @/link
* to the cameraOverlayView property.
* @discussion ￼ As opposed to creating your own UIImagePickerController and overlaying the AR view, this class creates an
* easier avenue to display @link //simplegeo/ooc/cl/SGRecordAnnotation SGRecordAnnotations @/link. This class implements
* @link //simplegeo/ooc/intf/SGARViewDataSource SGARViewDataSource @/link and provides data in the AR view a little differently.
*
* This subclass of UIImagePickerViewController will verify that the UIImagePickerControllerSourceTypeCamera is available on
* the device once the view has been loaded. If the camera source type is unavailble, then the view controller will revert
* to UIImagePickerControllerSourceTypePhotoLibrary. Using the UIImagePickerControllerSourceTypePhotoLibrary does not stop the
* create of the AR enviornment. You can still access the @link arView arView @/link. This might be advantageous if the desire
* is to display @link arView arView @/link over a selected image. The arView will not be a subview of any view so it would
* have to be added manually.
*
* The methods from @link SGARViewControllerDataSource SGARViewControllerDataSource @/link
* will create a bucket list. The data structure will then be used to feed the AR view through the proper delegate callbacks. To
* control which bucket is being displayed make sure to call @link reloadBucketAtIndex: reloadBucketAtIndex: @/link. Only a single
* bucket is displayed at any given time in the AR view. There is no limitation to the amount of annotations a bucket can have.
*
* There is one minor "gotcha". If you want to access the navigation bar directly, you have to use @link navBar navBar @/link. All other calls to
* the navigation view controller that involve the navigation bar (e.g. setNagivationBarHidden:) will be routed to the proper one. This little tweak
* is needed in order to display a navigation bar properly in the view.
* The overlay view also has its own navigation bar and toolbar. Even though this navigation view controller
* creates its own bars, you can still access them by calling the usual barrage of methods (e.g. setToolbarItems:animated:). The default is
* that both bars have a black, translucent tint color. 
*/

#if __IPHONE_4_0 >= __IPHONE_OS_VERSION_MAX_ALLOWED

@interface SGARViewController : UINavigationController <SGARViewDataSource, UINavigationControllerDelegate> {

#else

@interface SGARViewController : UIImagePickerController <SGARViewDataSource> {
    
#endif
 
    id<SGARViewControllerDataSource> dataSource;
 
    SGARView* arView;

    NSInteger bucketIndex;

    @private
    NSMutableArray* annotations;
 	NSMutableArray* buckets;
 
#if __IPHONE_4_0 < __IPHONE_OS_VERSION_MAX_ALLOWED

    UINavigationBar* myNavigationBar;
    UINavigationItem* myNavigationItem;
    UIToolbar* myToolbar;

#endif

    BOOL isModal;
}

/*!
* @property
* @abstract The @link //simplegeo/ooc/cl/SGARView SGARView @/link that is assigned to the cameraOverlayView property.
* @discussion You can call @link cameraOverlayView cameraOverlayView @/link and still access the the same view.
*/
@property (nonatomic, readonly) SGARView* arView;

/*!
* @property
* @abstract The @link //simplegeo/ooc/cl/SGARViewControllerDataSource data source @/link that populates the @link arView arView @/link.
*/
@property (nonatomic, assign) id<SGARViewControllerDataSource> dataSource;

/*!
* @property
* @abstract The current bucket index that is being used to populate the @link arView arView @/link.
*/
@property (nonatomic, readonly) NSInteger bucketIndex;

/*!
* @method reloadAllBuckets
* @abstract ￼ Runs through the entire process of collecting and displaying @link //simplegeo/ooc/cl/SGRecordAnnotation record annotations @/link
* in the @link arView arView @/link.
* @discussion If any record annotations have been registered with the @link SGARViewController SGARViewController @/link,
* they will be released.
*/
- (void) reloadAllBuckets;

/*!
* @method reloadBucketAtIndex:
* @abstract ￼Reloads a specific bucket.
* @param bucketIndex ￼The index of the bucket to reload.
*/
- (void) reloadBucketAtIndex:(NSInteger)bucketIndex;

/*!
* @method loadNextBucket
* @abstract ￼Loads the next bucket of record annotations that were imported with @link reloadAllBuckets reloadAllBuckets @/link.
* @result ￼YES if there is an available bucket. Otherwise, NO.
*/
- (BOOL) loadNextBucket;

/*!
* @method loadPreviousBucket
* @abstract ￼ Loads the previous bucket of record annotations that were imported with @link reloadAllBuckets reloadAllBuckets @/link.
* @result ￼ YES if there is an available bucket. Otherwise, NO.
*/
- (BOOL) loadPreviousBucket;

/*!
* @method close
* @abstract ￼ Stops animating the @link arView AR view @/link and calls dismissModalViewController: on itself.
*/
- (void) close;

/*!
* @method isModal
* @abstract ￼ Returns whether the ARView is the top view.
* @result ￼ YES if the navigation controller is modal; otherwise NO.
*/
- (BOOL) isModal;

#if __IPHONE_4_0 < __IPHONE_OS_VERSION_MAX_ALLOWED

/*!
* @method navBar
* @abstract ￼ This is the actual navigation bar used by this view controller.
* @discussion ￼ If you attempt to access the navigationBar via "nvc.navigationBar", you will not
* access the proper navigation bar. See @link SGARViewController SGARViewController @/linkfor a more detailed discussion.
* @result ￼ The navigation bar that is displayed by this navigation view controller.
*/
- (UINavigationBar*) navBar;

#endif


/*!
* @method amountOfBuckets
* @abstract Returns the amount of buckets that are registered.
* @result ￼The amount of buckets.
*/
- (NSInteger) amountOfBuckets;

@end

/*!
* @protocol SGARViewControllerDataSource
* @abstract ￼ The data source provides all callback methods that build the bucket list structure
* for the @link SGARNavigationController SGARNavigationController @/link.
* @discussion There are three required methods that need to be implemented. Each are important
* to creating and building the bucket list structure within the @link SGARNavigationController SGARNavigationController @/link
* and, consequentally, the @link arView arView @/link. The single, optional method @link viewController:didAddAnnotationView: viewController:didAddAnnotationView: @/link
* allows the data source to be aware when new views have been loaded into the AR enviornment.
*/
@protocol SGARViewControllerDataSource <NSObject>

@required

/*!
* @method viewController:viewForAnnotation:atBucketIndex:
* @abstract ￼ Returns a view to be used in the @link arView arView @/link.
* @discussion ￼ Since @link //simplegeo/ooc/cl/SGAnnotationView SGAnnotationViews @/link are reusable,
* you can access the @link arView arView @/link and call @link //simplegeo/ooc/instm/SGARView/dequeuereusableAnnotationView dequeuereusableAnnotationView @/link
* in the same manner you would a UITableViewCell. Like the UITableViewCell, it is recommended to resuse views.
*
* When creating your SGAnnotationViews, it is not required to set the @link //simplegeo/ooc/instp/SGAnnotationView/annotation annotation @/link property.
* The @link arView arView @/link will assign the passed in annotation to the view if the view does not come assigned with an annotation.
* @param nvc The @link SGARNavigationViewContorller SGARViewController @/link that requires a new view.
* @param annotation ￼The @link SGAnnotation SGAnnotation @/link that needs a view.
* @param bucketIndex ￼The index of the bucket that is currently being loaded into the AR view.
* @result ￼ The @link //simplegeo/ooc/cl/SGAnnotationView SGAnnotationView @/link to be used
* with the @link //simplegeo/ooc/intf/SGRecordAnnotation SGRecordAnnotation @/link. If nil is returned,
* then no annotation view will be displayed for the annotation.
*/
- (SGAnnotationView*) viewController:(SGARViewController*)nvc
                   viewForAnnotation:(id<MKAnnotation>)annotation 
                       atBucketIndex:(NSInteger)bucketIndex;

/*!
* @method viewController:annotationsForBucketAtIndex:
* @abstract Asks for all the annotations that will be placed in the bucket.
* @param nvc ￼The @link SGARViewController SGARViewController @/link that needs a bucket to be filled.
* @param bucketIndex ￼The index of the bucket to be filled.
* @result ￼ An array of @link //simplegeo/ooc/cl/SGRecordAnnotation SGRecordAnnotations @/link that will be placed in the bucket.
*/
- (NSArray*) viewController:(SGARViewController*)nvc annotationsForBucketAtIndex:(NSInteger)bucketIndex;

/*!
* @method viewControllerNumberOfBuckets:
* @abstract ￼The number of buckets to create.
* @param nvc ￼The @link SGARViewController SGARViewController @/link that is asking for the amount of buckets.
* @result ￼The number of buckets the to create.
*/
- (NSInteger) viewControllerNumberOfBuckets:(SGARViewController*)nvc;

@optional

/*!
* @method viewController:didAddAnnotationsViews:
* @abstract ￼Notifies the delegate when @link //simplegeo/ooc/cl/SGAnnotationView SGAnnotationViews @/link have been
* added to the @link //simplegeo/ooc/cl/SGARView SGARView @/link.
* @param nvc ￼The @link SGARViewController SGARViewController @/link that has added the views to the @link arView arView @/link.
* @param annotationViews ￼The annotation views that were added.
*/
- (void) viewController:(SGARViewController*)nvc didAddAnnotationsViews:(NSArray*)annotationViews;

@end


