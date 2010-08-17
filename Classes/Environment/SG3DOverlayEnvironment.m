//
//  SG3DOverlayEnvironment.m
//  SRARView
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

#import "SGARView.h"
#import "SGAnnotationView.h"
#import "SGRadar.h"
#import "SGMovableStack.h"
#import "SGARResponder.h"

#import "SG3DOverlayEnvironment.h"
#import "SGEnvironmentConstants.h"

#import "CLLocationAdditions.h"

#import "SGTexture.h"
#import "SGMetrics.h"
#import "SGMath.h"
#import "GLU+iPhone.h"

#define kAccelerometer_Rate               30.0

// Get the average height of a person
static GLfloat yEyePosition = kSGMeter * 1.7018f;

@interface SG3DOverlayEnvironment (Private)

- (void) drawLocatableObjects;
- (void) moveCameraForward:(BOOL)forward withDistance:(CGFloat)distance;
- (CGRect) getCapturableAreaFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

- (SGPoint3*) unprojectWindowPoint:(CGPoint)point;
- (SGAnnotationView*) closestAnnotationViewForPoint:(CGPoint)point;

- (void) sortAnnotationViews;
- (double) getAnnotationViewDistance:(SGAnnotationView*)annotationView;

@end

@implementation SG3DOverlayEnvironment

@synthesize locationManager, responders, arView, cameraStepDistance, fovy;

- (id) init
{
    if(self = [super init]) {
        responders = [[NSMutableArray alloc] init];

        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
            
        currentLocation = nil;
        filter = [[LowpassFilter alloc] initWithSampleRate:kAccelerometer_Rate cutoffFrequency:1.5];
        
        pitch = 0.0f;
        yaw = 0.0f;
        roll = 0.0f;
        
        fovy = 65.0f;
        
        cameraXCoord = 0.0f;
        cameraZCoord = 0.0f;
        cameraStepDistance = 1.0f;

        annotationViews = [[NSMutableArray alloc] init];
        containers = [[NSMutableArray alloc] init];

        inspectedView = nil;
                
        modelMatrix = (GLfloat*)malloc(sizeof(GLfloat) * 16);
        projectionMatrix = (GLfloat*)malloc(sizeof(GLfloat) * 16);
        viewport = (GLint*)malloc(sizeof(GLint) * 16);
    }
    
    return self;
}

#pragma mark -
#pragma mark Sort functions  

int sortRecordByDistance(id view1, id view2, void* blah) {
	SGAnnotationView* v1 = (SGAnnotationView*)view1;
	SGAnnotationView* v2 = (SGAnnotationView*)view2;
    
    double d1 = v1.distance;
    double d2 = v2.distance;
    
	NSComparisonResult result;
	if(d1 > d2)
		result = NSOrderedDescending;
	else if(d2 > d1)
		result = NSOrderedAscending;
    else 
        result = NSOrderedSame;
    
	return result;
}

#pragma mark -
#pragma mark Accessor methods 

- (void) addAnnotationViews:(NSArray*)views
{
    [annotationViews removeAllObjects];

    // Add the annotations view to the radar and ar views
    if(arView.radar) 
        [arView.radar addAnnotationViews:(NSArray*)views];
    
    for(SGAnnotationView* view in views)
        [self addAnnotationView:view];
    
    [self sortAnnotationViews];
}

- (void) addAnnotationView:(SGAnnotationView*)annotationView
{
    [annotationView.closeButton addTarget:self action:@selector(closeAnnotationView:) forControlEvents:UIControlEventTouchUpInside];
    [annotationViews addObject:annotationView];
}

- (void) removeLocatableObject:(SGAnnotationView*)annotationView
{
    [annotationView.closeButton removeTarget:self action:@selector(closeAnnotationView:) forControlEvents:UIControlEventTouchUpInside];
    [annotationViews removeObject:annotationView];
}

- (void) closeAnnotationView:(id)button
{
    BOOL closeView = YES;
    if(inspectedView) {
        if([inspectedView isKindOfClass:[SGAnnotationView class]]) {
            SGAnnotationView* view = (SGAnnotationView*)inspectedView;
            if(view.delegate && [view.delegate respondsToSelector:@selector(shouldCloseAnnotationView:)])
                closeView = [view.delegate shouldCloseAnnotationView:view];
        }
    }
        
    if(closeView) {
        [inspectedView removeFromSuperview];
        inspectedView = nil;           
    }
}

#pragma mark -
#pragma mark SG3DOverlayView delegate methods  

- (void) initiate
{
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometer_Rate)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    fovy = 65.0f;
    
    locationManager.delegate = self;
    [locationManager startUpdatingHeading];
    [locationManager startUpdatingLocation];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void) cleanUp
{
    fovy = 0.0f;
    [locationManager stopUpdatingHeading];
    locationManager.delegate = nil;
}

- (void) setupView:(SG3DOverlayView*)view
{
	glMatrixMode(GL_PROJECTION);
        
    glViewport(0.0, 0.0, view.bounds.size.width, view.bounds.size.height);
    gluPerspective(fovy, view.bounds.size.width / view.bounds.size.height, 0.5, kSGSphere_Radius + 10.0);
            
    glGetIntegerv(GL_VIEWPORT, viewport);
    glGetFloatv(GL_PROJECTION_MATRIX, projectionMatrix);
    
    glMatrixMode(GL_MODELVIEW);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    
    if(arView.radar)
        [arView bringSubviewToFront:arView.radar];
}

- (void) drawView:(SG3DOverlayView*)view
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
        
    glMatrixMode(GL_MODELVIEW);
    glRotatef(90.0f * roll, 0.0f, 0.0f, 1.0f);
    glRotatef(-90.0f * pitch, 1.0f, 0.0f, 0.0f); 
    glRotatef(heading, 0.0f, 1.0f, 0.0f);
    
    glTranslatef(0.0f, -yEyePosition, 0.0f);
        
    [arView drawComponent:kSGChromeComponent_Gridlines heading:heading roll:roll];
    
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glTranslatef(-cameraXCoord, 0.0f, -cameraZCoord);
    [self drawLocatableObjects];
    glGetFloatv(GL_MODELVIEW_MATRIX, modelMatrix);                           
    
    if(arView.enableWalking)
        arView.walkingOffset = CGPointMake(cameraXCoord, -cameraZCoord);
    
    [arView drawComponent:kSGChromeComponent_Radar heading:heading roll:roll];
    [arView drawComponent:kSGChromeComponent_MovableStack heading:heading roll:roll];    
}

#pragma mark -
#pragma mark Touch event handlers 

- (void) view:(SG3DOverlayView*)overlayView ARSingleTap:(CGPoint)point
{
    SGLog(@"SGGesture - Single tap at %f,%f", point.x, point.y);
    
    // Chrome manager gets first dibs on touch events
    if(![arView hitTestAtPoint:point withEvent:kSGControlEvent_Touch]) {
        if(!inspectedView) {
            SGAnnotationView* closestView = [self closestAnnotationViewForPoint:point];
            if(closestView && closestView.distance <= kSGSphere_Radius) {
                selectedView = closestView;
                selectedView.isSelected = YES;
            
                if(closestView.delegate && [closestView.delegate respondsToSelector:@selector(shouldInspectAnnotationView:)]) {
                    UIView* viewToInspect = [closestView.delegate shouldInspectAnnotationView:closestView];
                
                    if(viewToInspect) {
                        if([viewToInspect isKindOfClass:[SGAnnotationView class]]) {
                            viewToInspect.hidden = NO;
                            [(SGAnnotationView*)viewToInspect inspectView:YES];
                            ((SGAnnotationView*)viewToInspect).isCaptured = YES;
                        
                            viewToInspect.frame = CGRectMake((arView.frame.size.width - viewToInspect.frame.size.width) / 2.0,
                                                       (arView.frame.size.height - viewToInspect.frame.size.height) / 2.0,
                                                       viewToInspect.frame.size.width,
                                                         viewToInspect.frame.size.height);
                        } 
                    
                        [arView addSubview:viewToInspect];
                        inspectedView = viewToInspect;
                    } else {
                        // No inspection was declared
                        inspectedView = nil;
                    }
                }
            }         
        }  
    
        for(id<SGARResponder> responder in responders)
            if([responder respondsToSelector:@selector(ARSingleTap:)])
               [responder ARSingleTap:point];
    }
}

- (void) view:(SG3DOverlayView*)view ARDoubleTap:(CGPoint)point
{
    SGLog(@"SGGesture - Double tap at %f,%f", point.x, point.y);
    
    if(![arView hitTestAtPoint:point withEvent:kSGControlEvent_DoubleTouch])  {
        [self moveCameraForward:YES withDistance:50.0f];

        for(id<SGARResponder>responder in responders)
            if([responder respondsToSelector:@selector(ARDoubleTap:)])
                [responder ARDoubleTap:point];
    }
}

- (void) view:(SG3DOverlayView *)view tapReleased:(CGPoint)point
{
    SGLog(@"SGGesture - Tap released at %f,%f", point.x, point.y);
    
    if(![arView hitTestAtPoint:point withEvent:kSGControlEvent_TouchEnded]) {
        if(selectedView) {
            selectedView.isSelected = NO;
            selectedView = nil;
        }
        for(id<SGARResponder>responder in responders)
            if([responder respondsToSelector:@selector(ARTapEndedAtPoint:)])
                [responder ARTapEndedAtPoint:point];
    }
}

- (void) view:(SG3DOverlayView*)view ARPinchAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo withDistance:(CGFloat)distance
{
    SGLog(@"SGGesture - Pinch at %f,%f and %f,%f", pointOne.x, pointOne.y, pointTwo.x, pointTwo.y);
    
    [self moveCameraForward:NO withDistance:cameraStepDistance * kSGMeter];
    
    for(id<SGARResponder> responder in responders)
        if([responder respondsToSelector:@selector(ARPinchAtPoint:andPoint:withDistance:)])
            [responder ARPinchAtPoint:pointOne andPoint:pointTwo withDistance:distance];
}

- (void) view:(SG3DOverlayView*)view ARPullAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo withDistance:(CGFloat)distance
{
    SGLog(@"SGGesture - Pull at %f,%f and %f,%f", pointOne.x, pointOne.y, pointTwo.x, pointTwo.y);
    
    [self moveCameraForward:YES withDistance:cameraStepDistance * kSGMeter];
    
    for(id<SGARResponder> responder in responders)
        if([responder respondsToSelector:@selector(ARPullAtPoint:andPoint:withDistance:)])
            [responder ARPullAtPoint:pointOne andPoint:pointTwo withDistance:distance];
}

- (void) view:(SG3DOverlayView*)view ARSingleTapAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo
{
    SGLog(@"SGGesture - Single tap at %f,%f and %f,%f", pointOne.x, pointOne.y, pointTwo.x, pointTwo.y);
    
    [self moveCameraForward:NO withDistance:cameraStepDistance * kSGMeter * 5.0];

    for(id<SGARResponder> responder in responders)
        if([responder respondsToSelector:@selector(ARSingleTapAtPoint:andPoint:)])
           [responder ARSingleTapAtPoint:pointOne andPoint:pointTwo];
            
}

- (void) view:(SG3DOverlayView*)view ARHorizontalSwipeAtPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    SGLog(@"SGGesture - Horizontal swipe at %f,%f to %f,%f", fromPoint.x, fromPoint.y, toPoint.x, toPoint.y);
    
    for(id<SGARResponder> responder in responders)
        if([responder respondsToSelector:@selector(ARHorizontalSwipeAtPoint:toPoint:)])
           [responder ARHorizontalSwipeAtPoint:fromPoint toPoint:toPoint];
}

- (void) view:(SG3DOverlayView*)view ARVerticalSwipeAtPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    SGLog(@"SGGesture - Vertical swipe at %f,%f to %f,%f", fromPoint.x, fromPoint.y, toPoint.x, toPoint.y);
    
    for(id<SGARResponder> responder in responders)
        if([responder respondsToSelector:@selector(ARVerticalSwipeAtPoint:toPoint:)])
            [responder ARVerticalSwipeAtPoint:fromPoint toPoint:toPoint];
}

- (void) view:(SG3DOverlayView*)view ARMoveFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{    
    SGLog(@"SGGesture - Drag from %f,%f to %f,%f", fromPoint.x, fromPoint.y, toPoint.x, toPoint.y);
    
    [arView hitTestAtPoint:toPoint withEvent:kSGControlEvent_Drag];
    
    SGAnnotationView* annotationView = [self closestAnnotationViewForPoint:toPoint];
    if(annotationView && annotationView.isCapturable) {
        if(![[arView.movableStack stack] count])
            arView.movableStack.frame = CGRectMake(toPoint.x, toPoint.y,
                                            arView.movableStack.frame.size.width,
                                            arView.movableStack.frame.size.height);
        
        [arView.movableStack addAnnotationView:annotationView];                
    }

    for(id<SGARResponder> responder in responders)
        if([responder respondsToSelector:@selector(ARMoveFromPoint:toPoint:)])
            [responder ARMoveFromPoint:fromPoint toPoint:toPoint];
}

- (void) view:(SG3DOverlayView*)view ARMoveEndedAtPoint:(CGPoint)point
{
    SGLog(@"SGGesture - Drag ended at %f,%f", point.x, point.y);
    
    [arView hitTestAtPoint:point withEvent:kSGControlEvent_DragEnded];
}

- (void) ARViewDidShake:(SG3DOverlayView*)view
{
    SGLog(@"SGGesture - Shake");

    // Recenter ourselves
    cameraZCoord = 0.0f;
    cameraXCoord = 0.0f;
}

#pragma mark -
#pragma mark UIAccelerometer delegate methods

- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
    double kAccelerationThreshold = 2.2;
    
    if(fabsf(acceleration.x) > kAccelerationThreshold || fabsf(acceleration.y) > kAccelerationThreshold || fabsf(acceleration.z) > kAccelerationThreshold)
        [self ARViewDidShake:nil];
    else {
        [filter addAcceleration:acceleration];
    
        pitch = filter.z;
        roll = filter.x;
        yaw = filter.y;
    }
}

#pragma mark -
#pragma mark CLLocationManager delegate methods 
 
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
    if(currentLocation)
        [currentLocation release];
    
    currentLocation = [newLocation retain];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error
{
    SGLog(@"SG3DOverlayEnvironment - Unable to retreive location");
}

- (void) locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading
{
    heading = newHeading.trueHeading;
    heading += -90.0 * roll;
}

#pragma mark -
#pragma mark Draw methods 

- (void) drawLocatableObjects
{
    if(currentLocation) {
        GLfloat xCoord, zCoord, yCoord, bearing;
        double distance;
        SGTexture* texture;
        id<MKAnnotation> annotation;
        for(SGAnnotationView* annotationView in annotationViews) {
            annotation = annotationView.annotation;
            annotation.coordinate;

            if(annotation && !annotationView.isCaptured) {                
                bearing = (double)[currentLocation getBearingFromCoordinate:annotation.coordinate];
                distance = [self getAnnotationViewDistance:annotationView];
                
                zCoord = -distance * cos(DEGREES_TO_RADIANS(bearing));
                xCoord = distance * sin(DEGREES_TO_RADIANS(bearing));
                yCoord = kSGMeter * annotationView.altitude;
                
                glPushMatrix();
                
                glTranslatef(xCoord, yCoord, zCoord);
                glRotatef(-bearing, 0.0, 1.0, 0.0);
                
                // If the texture becomes to close to the camera, we need
                // to scale it approprietly
                if(distance < 3.0 * kSGMeter)
                    glScalef(distance / 300.0f, distance / 300.0f, 1.0f);
                
                if(annotationView.enableOpenGL)
                    [annotationView drawAnnotationView];
                else {
                    texture = annotationView.texture;
            
                    if(texture) {    
                        glEnable(GL_TEXTURE_2D);
                        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
                        [texture drawAtPoint:CGPointMake(0.0, -texture.size.height / 2.0)];
                        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
                        glDisable(GL_TEXTURE_2D);
                    }
                }
                
                glPopMatrix();
                
                annotationView.bearing = bearing;
                annotationView.distance = distance;
            
                // Save later for touch calculations
                annotationView.point->x = xCoord;
                annotationView.point->y = yCoord;
                annotationView.point->z = zCoord;
            }                   
        }

    }
}

- (void) moveCameraForward:(BOOL)forward withDistance:(CGFloat)distance
{
    if(arView.enableWalking) {
        CGFloat bearing = heading;
        if(!forward)
            bearing = 180.0 + bearing;
        
        CGFloat zCoord = -distance * cos(DEGREES_TO_RADIANS(bearing));
        CGFloat xCoord = distance * sin(DEGREES_TO_RADIANS(bearing));    
    
        CGFloat futureCameraXCoord = cameraXCoord + xCoord;
        CGFloat futureCameraZCoord = cameraZCoord + zCoord;
    
        // Make sure we don't cross into the abyss
        if(futureCameraXCoord > -kSGSphere_Radius && futureCameraXCoord < kSGSphere_Radius &&
           futureCameraZCoord > -kSGSphere_Radius && futureCameraZCoord < kSGSphere_Radius) {
     
            cameraXCoord = futureCameraXCoord;
            cameraZCoord = futureCameraZCoord;
        }
        [self sortAnnotationViews];
    }        
}

#pragma mark -
#pragma mark Helper methods  

- (SGAnnotationView*) closestAnnotationViewForPoint:(CGPoint)point
{
    CGRect boundingBox;
    CGPoint windowPoint;
    CGFloat z, width, height, delta;
    SGAnnotationView* closestView = nil;
    for(SGAnnotationView* view in annotationViews) {
        gluProject(view.point->x, view.point->y, view.point->z,
                   modelMatrix, projectionMatrix, viewport,
                   &windowPoint.x, &windowPoint.y, &z);
        
        windowPoint.y = viewport[3] - windowPoint.y;
        
        // Make sure the view is not captured and is on the correct
        // side of the screen.
        if(z < 1.0f && !view.isCaptured) {            
            delta = (kSGSphere_Radius / 2.0) / view.distance;
        
            // Do some scaling based on the distance.
            width = view.texture.size.width * delta;
            height = view.texture.size.height * delta;

            // Allows for a larger touch space
            if(width < 40.0)
                width = 40.0;
            
            if(height < 40.0)
                height = 40.0;
        
            boundingBox = CGRectMake(windowPoint.x - (width / 2.0f), 
                                     windowPoint.y,
                                     width, 
                                     height);
        
            // Check to see that the point is located in the bounding box
            if(CGRectContainsPoint(boundingBox, point)) {
                // Make sure to grab the closest view
                if(!closestView || (closestView && closestView.distance < view.distance)) {
                    SGLog(@"SG3DOverlayEnironment - View touched at %f %f", point.x, point.y);
                    closestView = view;
                }                
            }
        }
    }
    
    return closestView;
}

- (SGPoint3*) unprojectWindowPoint:(CGPoint)winPos
{
    //opengl origin is at the bottom not at the top
    winPos.y = (float)viewport[3] - winPos.y;
        
    float cX, cY, cZ, fX, fY, fZ = 0.0f;

    //gives us camera position (near plan)
    gluUnProject( winPos.x, winPos.y, 0.5f, modelMatrix, projectionMatrix, viewport, &cX, &cY, &cZ);
    
    //far plane
    gluUnProject( winPos.x, winPos.y, kSGSphere_Radius, modelMatrix, projectionMatrix, viewport, &fX, &fY, &fZ);
    
    fX -= cX;
    fY -= cY;
    fZ -= cZ;
    
    float rayLength = sqrtf(cX*cX + cY*cY + cZ*cZ);
    
    // normalize
    fX /= rayLength;
    fY /= rayLength;
    fZ /= rayLength;
        
    float dot1, dot2 = 0.0f;
    
    float pointInPlaneX = 0;
    float pointInPlaneY = 0;
    float pointInPlaneZ = 0;
    float planeNormalX = 0;
    float planeNormalY = 0;
    float planeNormalZ = -1;
    
    pointInPlaneX -= cX;
    pointInPlaneY -= cY;
    pointInPlaneZ -= cZ;
    
    dot1 = (planeNormalX * pointInPlaneX) + (planeNormalY * pointInPlaneY) + (planeNormalZ * pointInPlaneZ);
    dot2 = (planeNormalX * fX) + (planeNormalY * fY) + (planeNormalZ * fZ);
    
    float t = dot1/dot2;
    
    fX *= t;
    fY *= t;
    fZ *= t;
    
    fX += cX;
    fY += cY;
    fZ += cZ;
    
    return V3New(fX, fY, fZ);
}

- (void) sortAnnotationViews
{
    if(annotationViews && [annotationViews count]) {
        // Calculate the distance from the current location
        for(SGAnnotationView* annotationView in annotationViews)
            annotationView.distance = [self getAnnotationViewDistance:annotationView];
        
        [annotationViews sortUsingFunction:sortRecordByDistance context:nil];
    }
}

- (double) getAnnotationViewDistance:(SGAnnotationView*)annotationView
{
    CLLocation* viewLocation = [[CLLocation alloc] initWithLatitude:annotationView.annotation.coordinate.latitude 
                                                           longitude:annotationView.annotation.coordinate.longitude];
    
    // The distance returned is in meters; however, we want to convert them
    // into the metric that we are using.
    double distance = [currentLocation distanceToLocation:viewLocation] * kSGMeter;    
    if(distance > kSGAnnotation_MaximumDistance)
        distance = kSGAnnotation_MaximumDistance;
    else if(distance < kSGAnnotation_MinimumDistance)
        distance = kSGAnnotation_MinimumDistance;
    
    [viewLocation release];
    
    return distance;
}

- (void) dealloc
{
    [locationManager release];
    [responders release];
    [arView release];
    [filter release];
    [currentLocation release];
    [annotationViews release];
    [containers release];

    if(inspectedView)
        [inspectedView release];
        
    [super dealloc];
}

@end
