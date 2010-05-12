//
//  SGAREnvironment.m
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

#import "SGARView.h"

#import "SG3DOverlayEnvironment.h"
#import "SGMetrics.h"
#import "SGEnvironmentConstants.h"

#import "SGAnnotationView.h"
#import "SGARResponder.h"
#import "SGRadar.h"
#import "SGMovableStack.h"
#import "SGAnnotationViewContainer.h"

@interface SGARView (Private)

- (void) setupViewableObjects;
- (void) setUpOverlayView;

- (void) loadObjectIntoSortedBucket:(NSInteger)bucketIndex;

- (void) createGraphLines;

- (void) drawGraphLines;
- (void) drawRadarWitHeading:(double)heading roll:(double)roll;
- (void) drawMovableStackAtPoint:(CGPoint)point roll:(double)roll;

- (void) dragStarted:(BOOL)started atPoint:(CGPoint)point;

@end

@implementation SGARView

@synthesize dataSource, locationManager, movableStack, enableWalking, enableGridLines;
@dynamic walkingOffset, radar, gridLineColor;

- (id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
        SGInitializeEnvironmentSettings();
        
        overlaySubviews = [[NSMutableArray alloc] init];
        annotationViews = [[NSMutableDictionary alloc] init];
        
        [self setGridLineColor:[UIColor whiteColor]];
        
        enableWalking = NO;
        enableGridLines = NO;
        dragging = NO;
        previousContainer = nil;
        
        touchPoint = CGPointZero;
        
        [self setRadar:[[[SGRadar alloc] initWithFrame:CGRectMake(30.0, 90.0, 100.0, 100.0)] autorelease]];
        
        containers = [[NSMutableArray alloc] init];
        
        movableStack = [[SGMovableStack alloc] initWithFrame:CGRectZero];
        movableStack.arView = self;
        
        [self createGraphLines];
        
        
        self.backgroundColor = [UIColor clearColor];
        [self setUpOverlayView];
    }
    
    return self;
}

#pragma mark -
#pragma mark Setup methods 
 
- (void) setUpOverlayView
{    
    enviornmentDrawer = [[SG3DOverlayEnvironment alloc] init];
    enviornmentDrawer.arView = self;
    
    openGLOverlayView = [[SG3DOverlayView alloc] initWithFrame:self.bounds];
    openGLOverlayView.delegate = enviornmentDrawer;
    
    [self addSubview:openGLOverlayView];
}

#pragma mark -
#pragma mark Accessor methods 

- (void) setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    openGLOverlayView.bounds = self.bounds;
}

- (void) setRadar:(SGRadar*)newRadar
{
    if(newRadar) {
        NSArray* views = radar.annotationViews;
        if(radar) {
            [radar release];
            radar = nil;
        }
        
        radar = [newRadar retain];
        [radar addAnnotationViews:views];
        [self addSubview:radar];
    }
}

- (SGRadar*) radar
{
    return radar;
}

- (void) dragStarted:(BOOL)started atPoint:(CGPoint)point
{
    dragging = started;
    touchPoint = point;
    
    if(!started)
        previousContainer = nil;
}

- (void) removeContainer:(SGAnnotationViewContainer*)container
{
    if(container) {
        [containers removeObject:container];
        container.arView = nil;
        [container removeFromSuperview];
    }
}

- (void) addContainer:(SGAnnotationViewContainer*)container
{
    if(container) {
        container.arView = self;
        [containers addObject:container];
        [self addSubview:container];
    }
}

- (void) setMovableStack:(SGMovableStack*)ms
{
    if(movableStack)
        [movableStack release];
    
    movableStack = [ms retain];
    movableStack.arView = self;
}

- (NSArray*) getContainers
{
    return [NSArray arrayWithArray:containers];
}

- (void) setGridLineColor:(UIColor*)color
{
    gridLineColorComponents = (CGFloat*)CGColorGetComponents(color.CGColor);
}

- (UIColor*) gridLineColor
{
    return [UIColor colorWithRed:gridLineColorComponents[0] green:gridLineColorComponents[1] 
                            blue:gridLineColorComponents[2] alpha:gridLineColorComponents[3]];
}
 
- (void) reloadData
{       
    [self empty];
    
    // Make every view resuseable and place them in the proper bucket
    NSMutableArray* viewBucket;
    for(SGAnnotationView* view in overlaySubviews) {
        
        // Place each view in the proper bucket so a user
        // might be able to access the view later
        viewBucket = [annotationViews objectForKey:view.reuseIdentifier];
        
        if(!viewBucket) {
            
            viewBucket = [[[NSMutableArray alloc] init] autorelease];
            [annotationViews setObject:viewBucket forKey:view.reuseIdentifier];
            
        }
        
        [viewBucket addObject:view];
    }        
    
    // Empty out all of the subviews that were recycled
    [overlaySubviews removeAllObjects];

    // Get the amount of annotations to display
    NSArray* annotations = [dataSource arView:self annotationsAtLocation:enviornmentDrawer.locationManager.location];
    
    if(annotations && [annotations count]) {
     
        int amountOfAnnotations = [annotations count];
        SGAnnotationView* overlaySubview;
        id<MKAnnotation> annotation = nil;
        for(int i = 0; i < amountOfAnnotations; i++) {
        
            annotation = [annotations objectAtIndex:i];
            overlaySubview = [dataSource arView:self viewForAnnotation:annotation];
            
            if(overlaySubview) {
                
                if(!overlaySubview.annotation)
                    overlaySubview.annotation = annotation;
                
                [overlaySubviews addObject:overlaySubview];
            }   
        }
    }
    
    if([overlaySubviews count]) {
        
        [enviornmentDrawer addAnnotationViews:overlaySubviews];
    
        if([dataSource respondsToSelector:@selector(arView:didAddAnnotationViews:)])
            [dataSource arView:self didAddAnnotationViews:overlaySubviews];
    }
}

- (void) clear
{
    [annotationViews removeAllObjects];
    [overlaySubviews removeAllObjects];
    
    // Redraw the
    [openGLOverlayView startAnimation];
    [openGLOverlayView stopAnimation];
}

#pragma mark -
#pragma mark Draw methods 

- (void) drawComponent:(SGChromeComponent)chromeComponent heading:(double)heading roll:(double)roll;
{
    if(enableGridLines && chromeComponent & kSGChromeComponent_Gridlines)
        [self drawGraphLines];
    
    if(radar && !radar.hidden && chromeComponent & kSGChromeComponent_Radar)
        [self drawRadarWithAnnotationViews:objects heading:heading roll:roll];
    
    if(movableStack && chromeComponent & kSGChromeComponent_MovableStack)
        [self drawMovableStackAtPoint:touchPoint roll:roll];
}

- (void) drawGraphLines
{
    glColor4f(gridLineColorComponents[0], gridLineColorComponents[1],
              gridLineColorComponents[2], gridLineColorComponents[3]);
    glVertexPointer(3.0, GL_FLOAT, 0, gridLines);
    glDrawArrays(GL_LINES, 0, kSGSphere_Radius * 8.0);
}

- (void) drawRadarWithHeading:(double)heading roll:(double)roll
{
    [radar drawRadarWithHeading:heading roll:roll];
}

- (void) drawMovableStackAtPoint:(CGPoint)point roll:(double)roll
{        
    [movableStack drawStackAtPoint:point roll:roll];
}

- (SGAnnotationView*) dequeueReuseableAnnotationViewWithIdentifier:(NSString*)viewId
{
    SGAnnotationView* view = nil;
    
    NSMutableArray* nonUsedViews = [annotationViews objectForKey:viewId];
    if(nonUsedViews && [nonUsedViews count]) {
        view = [[nonUsedViews lastObject] retain];
        [nonUsedViews removeLastObject];
        [view prepareForReuse];
        [view autorelease];
    }
    
    return view;
}

- (void) startAnimation
{
    for(SGAnnotationView* annotationView in overlaySubviews)
        [annotationView layoutSubviews];
    
    [openGLOverlayView startAnimation];
    [openGLOverlayView becomeFirstResponder];    
}

- (void) stopAnimation
{
    [openGLOverlayView stopAnimation];
    [openGLOverlayView resignFirstResponder];
}

- (void) addResponder:(id<SGARResponder>)responder
{
    [[enviornmentDrawer responders] addObject:responder];
}

- (void) removeResponder:(id<SGARResponder>)responder
{
    [[enviornmentDrawer responders] removeObject:responder];
}

#pragma mark -
#pragma mark Helper methods

- (void) createGraphLines
{
    int amountOfLines = kSGSphere_Radius * 2.0 * 2.0;
    int numberOfVertices = amountOfLines * 3.0 * 2.0;
    
    gridLines = malloc(sizeof(float) * numberOfVertices);
    
    GLfloat deviation = kSGMeter;
    
    GLfloat xCoord = kSGSphere_Radius;
    GLfloat zCoord = kSGSphere_Radius;
    
    int i;
    for(i = 0; i < numberOfVertices; i+=12) {
        
        // Horizontal
        gridLines[i] = -kSGSphere_Radius;
        gridLines[i+1] = 0.0;
        gridLines[i+2] = zCoord;
        
        gridLines[i+3] = kSGSphere_Radius;
        gridLines[i+4] = 0.0;
        gridLines[i+5] = zCoord;
        
        // Vertical
        gridLines[i+6] = xCoord;
        gridLines[i+7] = 0.0; 
        gridLines[i+8] = -kSGSphere_Radius;
        
        gridLines[i+9] = xCoord;
        gridLines[i+10] = 0.0;
        gridLines[i+11] = kSGSphere_Radius;
        
        zCoord -= deviation;
        xCoord -= deviation;
    }
}

- (BOOL) hitTestAtPoint:(CGPoint)point withEvent:(SGControlEvent)event
{
    BOOL touchOnComponent = NO;
    if(event == kSGControlEvent_Drag) {
        
        [self dragStarted:YES atPoint:point];
        
    } else if(event == kSGControlEvent_DragEnded) {
        
        [self dragStarted:NO atPoint:point];
    }
    
    // Run through all of the Chrome components to see if 
    // we need to deal with the tap
    
    // Radar
    if(event == UIControlEventTouchUpInside && radar &&
       CGRectContainsPoint(radar.frame, point))
        touchOnComponent = YES;
    
    // Containers
    if(!touchOnComponent) {
        CGRect containerFrame;
        for(SGAnnotationViewContainer* container in containers) {
            // We enlarge the frame because most objects that want to be placed
            // inside the container are larger than 1 px
            containerFrame = CGRectInset(container.frame, -25.0, -25.0);
            if(CGRectContainsPoint(containerFrame, point)) {
                if(movableStack) {
                    // The stack has encountered the container on a drag event
                    if(event == kSGControlEvent_Drag)
                        [container sendActionsForControlEvents:UIControlEventTouchDragEnter];
                    else if(event == kSGControlEvent_DragEnded) {
                        // The stack is held within the container            
                        NSArray* stack = [movableStack stack];
                        if(stack && [stack count]) {
                            [container addRecordAnnotationViews:stack];
                            [movableStack emptyStack:YES];
                        }
                        
                        [container sendActionsForControlEvents:UIControlEventTouchUpInside];
                    } 
                    
                    touchOnComponent = YES;
                    previousContainer = container;
                }
            }
        }
    }
    
    if(event == kSGControlEvent_Drag && !touchOnComponent && previousContainer) {
        [previousContainer sendActionsForControlEvents:UIControlEventTouchDragExit];
        previousContainer = nil;
    }
    
    if(event == kSGControlEvent_DragEnded) {
        NSArray* stack = [movableStack stack];
        if(stack && [stack count])
            [movableStack emptyStack:NO];
    }
    
    return touchOnComponent;
}

- (void) empty
{
    for(SGAnnotationViewContainer* container in containers)
        for(SGAnnotationView* view in [container getRecordAnnotationViews])
            [container removeAnnotationView:view];

    if(movableStack)
        [movableStack emptyStack:NO];
}

- (void) dealloc
{
    [locationManager release];
    [radar release];    
    [movableStack release];
    [gridLineColor release];
    [annotationViews release];    
    [overlaySubviews release];
    [openGLOverlayView stopAnimation];
    [openGLOverlayView resignFirstResponder];
    [openGLOverlayView release];
    [enviornmentDrawer release];
    free(gridLines);
    if(previousContainer)
        [previousContainer release];
    [containers release];

    
    [super dealloc];
}

@end