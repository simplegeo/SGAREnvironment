//
//  SGARNavigationViewController.m
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

#import "SGARNavigationViewController.h"
#import "SGMovableStack.h"

@interface SGARNavigationViewController (Private)

- (void) loadObjectsIntoBucket:(NSInteger)index;
- (void) setupViewableObjects;
- (void) sortViewableObjects;

- (void) createSubviews;

@end

@implementation SGARNavigationViewController

@synthesize arView, dataSource, bucketIndex;

- (id) init
{
    if(self = [super init]) {
        super.title = @"ARView";
        buckets = [[NSMutableArray alloc] init];
        bucketIndex = -1;

        isModal = NO;

        dataSource = nil;
        [self createSubviews];
    }

    return self;
}

- (void) createSubviews
{
    arView = [[SGARView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
    arView.dataSource = self;

#if __IPHONE_4_0 < __IPHONE_OS_VERSION_MAX_ALLOWED

    myNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 18.0, 320.0, 44.0)];
    myNavigationBar.tintColor = [UIColor blackColor];
    myNavigationBar.translucent = YES;
    
    myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 
                                                            480.0 - myNavigationBar.frame.size.height,
                                                            320.0,
                                                            myNavigationBar.frame.size.height)];
    myToolbar.tintColor = [UIColor blackColor];
    myToolbar.translucent = YES;
    
    myNavigationItem = [[UINavigationItem alloc] initWithTitle:@"AR View"];
    myNavigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self action:@selector(close)];            
    
    [myNavigationBar pushNavigationItem:myNavigationItem animated:NO];
    
    [arView addSubview:myNavigationBar];
    [arView addSubview:myToolbar];

#endif
}

- (BOOL) isModal
{
    return isModal;
}

#pragma mark -
#pragma mark Data loaders

- (void) reloadAllBuckets
{
    [buckets removeAllObjects];
    
    NSInteger numberOfBuckets = [dataSource viewControllerNumberOfBuckets:self];
    
    NSArray* bucket;
    for(int i = 0; i < numberOfBuckets; i++) {
        bucket = [dataSource viewController:self annotationsForBucketAtIndex:i];
        [buckets addObject:bucket];
    }
         
    bucketIndex = 0;
    
    [arView reloadData];
}

- (void) reloadBucketAtIndex:(NSInteger)newBucketIndex
{
    if(newBucketIndex < [buckets count] && newBucketIndex >= 0) {
        [buckets replaceObjectAtIndex:bucketIndex withObject:[dataSource viewController:self
                                                           annotationsForBucketAtIndex:newBucketIndex]];
        
        bucketIndex = newBucketIndex;
        
        [arView reloadData];
    }
}

- (BOOL) loadNextBucket
{
    if(bucketIndex >= 0 && bucketIndex < [buckets count] - 1) {
        bucketIndex++;
        [arView reloadData];

        return YES;
    }
    
    return NO;
}

- (BOOL) loadPreviousBucket
{
    if(bucketIndex > 0) {
        bucketIndex--;
        [arView reloadData];

        return YES;
    }

    return NO;
}

#pragma mark -
#pragma mark UIViewController overrides 

#if __IPHONE_4_0 < __IPHONE_OS_VERSION_MAX_ALLOWED
 
- (UINavigationBar*) navBar
{
    return myNavigationBar;
}

- (UINavigationItem*) navigationItem
{
    return myNavigationItem;
}

- (void) setTitle:(NSString*)newTitle
{
    if(newTitle) {
        myNavigationItem.title = newTitle;
        super.title = newTitle;
    }
}

- (NSString*) title
{
    return myNavigationItem.title;
}

- (void) setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    myToolbar.hidden = hidden;
}

- (void) setToolbarItems:(NSArray*)items animated:(BOOL)animated
{
    [myToolbar setItems:items animated:animated];
}

- (NSArray*) toolbarItems
{
    return myToolbar.items;
}

- (UIToolbar*) toolbar
{
    return myToolbar;
}

#endif

- (void) loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];

#if __IPHONE_4_0 >= __IPHONE_OS_VERSION_MAX_ALLOWED
    
    [self.view addSubview:arView];

#else

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.showsCameraControls = NO;
        self.cameraOverlayView = arView;
    }

#endif

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isModal = YES;
    [arView startAnimation];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isModal = NO;
    [arView stopAnimation];    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) pushViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    [self setNavigationBarHidden:NO animated:NO];
    [super pushViewController:viewController animated:animated];
}

#pragma mark -
#pragma mark UIBarButtonItem methods 
 
- (void) close
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark SGARView data source methods 
 
- (NSArray*) arView:(SGARView*)aView annotationsAtLocation:(CLLocation*)location
{
    NSArray* array = nil;
    
    if(bucketIndex < [buckets count] && bucketIndex >= 0)
        array = [buckets objectAtIndex:bucketIndex];
    
    return array;
}

- (SGAnnotationView*) arView:(SGARView*)aView viewForAnnotation:(id<MKAnnotation>)annotation
{
    return [dataSource viewController:self
                    viewForAnnotation:annotation
                        atBucketIndex:bucketIndex];
}

- (NSInteger) amountOfBuckets
{
    return [buckets count];
}

- (void) arView:(SGARView *)arView didAddAnnotationViews:(NSArray*)annotaitonViews
{
    if(dataSource && [dataSource respondsToSelector:@selector(viewController:didAddAnnotationsViews:)])
        [dataSource viewController:self didAddAnnotationsViews:annotaitonViews];
    
}

- (void) dealloc
{
    [annotations release];
    [buckets release];

#if __IPHONE_4_0 < __IPHONE_OS_VERSION_MAX_ALLOWED

    [myNavigationItem release];
    [myNavigationBar release];
    [myToolbar release];

#endif
    
    [arView release];
        
    [super dealloc];
}

@end