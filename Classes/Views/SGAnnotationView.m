//
//  SGAnnotationView.m
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

#import "SGAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

#import "SGMetrics.h"

#define MAX_PHOTO_WIDTH                 224.0
#define MAX_PHOTO_HEIGHT                224.0

@interface SGAnnotationView (Private)

- (void) createObjectSubviews;
- (void) layoutSubviewsExpanded:(BOOL)expand;
- (void) resetSubviews;

@end

@implementation SGAnnotationView

@dynamic annotation, isSelected;
@synthesize detailedLabel, titleLabel, messageLabel, targetImageView, photoImageView, closeButton, inspectorType, targetType, isCaptured, isCapturable;
@synthesize distance, bearing, altitude, isBeingInspected;
@synthesize point, needNewTexture, delegate, enableOpenGL, pinColor, containerImage, radarTargetButton;
@dynamic texture;

- (id) initAtPoint:(CGPoint)pt reuseIdentifier:(NSString*)identifier
{
    if (self = [super initWithFrame:CGRectMake(pt.x, pt.y, 0.0, 0.0)]) {
        // Order of creation is important here
        point = (SGPoint3*)malloc(sizeof(SGPoint3));
        
        radarPointTexture = nil;
        texture = nil;
        
        altitude = 0.0;
        
        [self createObjectSubviews];
                
        needNewTexture = YES;        
        
        [self setTargetType:kSGAnnotationViewTargetType_Pin];
        [self setInspectorType:kSGAnnotationViewInspectorType_Standard];
        
        reuseIdentifier = identifier;
            
        self.backgroundColor = [UIColor clearColor];
        isBeingInspected = NO;
        
        isCaptured = NO;
        isCapturable = YES;
        
        enableOpenGL = NO;
        
        pinColor = kSGPinColor_Red;
        
        radarTargetButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        UIImage* targetImage = [UIImage imageNamed:@"SGDefaultRadarTargetImage.png"];
        [radarTargetButton setImage:targetImage forState:UIControlStateNormal];
        radarTargetButton.frame = CGRectMake(0.0, 0.0, targetImage.size.width, targetImage.size.height);
    }

    return self;
}

- (void) createObjectSubviews
{        
    closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    UIImage* closeImage = [UIImage imageNamed:@"SGCloseButton.png"];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(-5.0,
                                   -7.0,
                                   closeImage.size.width, 
                                   closeImage.size.height);
    [self addSubview:closeButton];
    
    targetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 48.0, 48.0)];
    targetImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:targetImageView];
    
    backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SGGlassTargetBackground.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:20.0]];
    [self addSubview:backgroundImageView];
    
    topExpandedBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SGTopInspectorBackground.png"]];
    [self addSubview:topExpandedBGImageView];
    
    UIImage* middleImage = [[UIImage imageNamed:@"SGMiddleInspectorBackground.png"] stretchableImageWithLeftCapWidth:100.0 topCapHeight:10.0];
    middleExpandedBGImageView = [[UIImageView alloc] initWithImage:middleImage];
    [self addSubview:middleExpandedBGImageView];
    
    bottomExpandedBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SGBottomInspectorBackground.png"]];
    [self addSubview:bottomExpandedBGImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [self addSubview:titleLabel];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = [UIFont systemFontOfSize:14.0];
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.numberOfLines = 4.0;
    [self addSubview:messageLabel];
    
    detailedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    detailedLabel.textColor = [UIColor whiteColor];
    detailedLabel.backgroundColor = [UIColor clearColor];
    detailedLabel.font = [UIFont boldSystemFontOfSize:12.0];
    detailedLabel.textAlignment = UITextAlignmentRight;
    [self addSubview:detailedLabel];
    
    photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:photoImageView];
    
    [self inspectView:NO];
}


#pragma mark -
#pragma mark Accessor methods 
 

- (NSString*) reuseIdentifier
{
    return reuseIdentifier;
}

- (void) setAnnotation:(id<MKAnnotation>)newAnnotation
{
    annotation = newAnnotation;

    self.needNewTexture = YES;
}

- (void) setInspectorType:(SGAnnotationViewInspectorType)type
{    
    inspectorType = type;
    [self setNeedsLayout];
}

- (SGAnnotationViewInspectorType) inspectorType
{
    return inspectorType;
}

- (void) setTargetType:(SGAnnotationViewTargetType)type
{    
    targetType = type;
    [self setNeedsLayout];
}

- (SGAnnotationViewTargetType) targetType
{
    return targetType;
}

- (id<MKAnnotation>) annotation
{
    return annotation;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self inspectView:isBeingInspected];
}

- (void) prepareForReuse
{
    [texture release];
    texture = nil;
    delegate = nil;
    isBeingInspected = NO;
    
    [self resetSubviews];
    
    [self inspectView:NO];
}

- (void) setContainerImage:(UIImage*)image
{
    if(image) {
        if(containerImage)
            [containerImage release];
    
        containerImage = [image retain];
    }
}

- (SGTexture*) texture
{
    if(needNewTexture) {
        if(texture)
            [texture release];

        CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height + 10.0);
        
        UIGraphicsBeginImageContext(size);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        texture = [[SGTexture alloc] initWithImage:image];
        
        if(!containerImage)            
            containerImage = [image retain];
        
        needNewTexture = NO;
    }
    
    return texture;
}

- (void) removeFromSuperview
{
    self.isCaptured = NO;
    [super removeFromSuperview];
}

- (void) inspectView:(BOOL)inspect
{
    isBeingInspected = inspect;
    
    if(inspect) {
        
        [backgroundImageView removeFromSuperview];
        [targetImageView removeFromSuperview];
                        
        if(inspectorType != kSGAnnotationViewInspectorType_Custom) {
                                    
            NSString* text = messageLabel.text;
                        
            CGSize photoSize = CGSizeZero;
            if(inspectorType == kSGAnnotationViewInspectorType_Photo) {
             
                UIImage* photoImage = photoImageView.image;
                
                if(photoImageView.image)
                    photoSize = photoImage.size;
                
            }
            
            CGSize messageSize;
            if(!text || ![text length] || inspectorType == kSGAnnotationViewInspectorType_Standard) {
                
                messageSize = CGSizeMake(224.0, 20.0);
                
            } else {
                
                messageSize = [text sizeWithFont:messageLabel.font
                               constrainedToSize:CGSizeMake(224.0, 1000.0)
                                   lineBreakMode:UILineBreakModeWordWrap];    
            }
            
            
            CGFloat xInset = 9.0;
            
            self.frame = CGRectMake(self.frame.origin.x, 
                                    self.frame.origin.y,
                                    280.0 > (photoSize.width + xInset * 2.0) ? 280.0 : (photoSize.width + (xInset * 2)), 
                                    messageSize.height + 70.0 + photoSize.height + (xInset * 2));                        
            
        
            topExpandedBGImageView.hidden = NO;
            middleExpandedBGImageView.hidden = NO;
            bottomExpandedBGImageView.hidden = NO;        
        
            topExpandedBGImageView.frame = CGRectMake(-10.0, 
                                                       -10.0,
                                                      self.frame.size.width + 20.0,
                                                      topExpandedBGImageView.frame.size.height);
        
            bottomExpandedBGImageView.frame = CGRectMake(-10.0,
                                                         self.bounds.size.height - bottomExpandedBGImageView.frame.size.height,
                                                         topExpandedBGImageView.frame.size.width,
                                                         bottomExpandedBGImageView.frame.size.height);
        
            middleExpandedBGImageView.frame = CGRectMake(-11.0,
                                                         topExpandedBGImageView.frame.size.height + topExpandedBGImageView.frame.origin.y,
                                                         topExpandedBGImageView.frame.size.width + 2.0,
                                                         self.bounds.size.height - bottomExpandedBGImageView.frame.size.height - topExpandedBGImageView.frame.size.height + 10.0);
        
            [self addSubview:topExpandedBGImageView];
            [self addSubview:middleExpandedBGImageView];
            [self addSubview:bottomExpandedBGImageView];
            
            [self addSubview:targetImageView];                            
            [self addSubview:titleLabel];
            [self addSubview:detailedLabel];
            [self addSubview:closeButton];
        
            targetImageView.frame = CGRectMake(xInset, xInset, 
                                               targetImageView.frame.size.width,
                                               targetImageView.frame.size.height);
            
            CGSize titleLabelSize = [(titleLabel.text ? titleLabel.text : @"M") sizeWithFont:titleLabel.font];
            if(targetImageView.image) {
                
                CGFloat maxWidth = self.frame.size.width - targetImageView.frame.size.width - xInset - 40.0;
                if(titleLabelSize.width > maxWidth)
                    titleLabelSize.width = maxWidth;
                
                titleLabelSize.height = targetImageView.frame.size.height;
                                
            } else {
                
                CGFloat maxWidth = self.frame.size.width - xInset - 40.0;
                if(titleLabelSize.width > maxWidth)
                    titleLabelSize.width = maxWidth;
            }
            
            titleLabel.frame = CGRectMake((self.frame.size.width - titleLabelSize.width) / 2.0, 
                                            targetImageView.frame.origin.y,
                                            titleLabelSize.width,
                                            titleLabelSize.height);
                
            
            detailedLabel.frame = CGRectMake(titleLabelSize.width + titleLabel.frame.origin.x + xInset, 
                                             titleLabel.frame.origin.y, 
                                             self.frame.size.width - titleLabelSize.width - titleLabel.frame.origin.x - (xInset * 2.0),
                                             titleLabelSize.height);
            
            CGFloat space = 7.0;
            
            if(inspectorType == kSGAnnotationViewInspectorType_Photo) {
                
                
                
                photoImageView.frame = CGRectMake((self.frame.size.width - photoSize.width) / 2.0,
                                                  titleLabel.frame.origin.y + titleLabel.frame.size.height + space,
                                                  photoSize.width,
                                                  photoSize.height);
                                
                messageLabel.frame = CGRectMake((self.frame.size.width - messageSize.width) / 2.0,
                                                photoImageView.frame.origin.y + photoImageView.frame.size.height + space,
                                                messageSize.width,
                                                messageSize.height);
                
                [self addSubview:messageLabel];
                [self addSubview:photoImageView];
                
            } else if(inspectorType == kSGAnnotationViewInspectorType_Message) {
                
                messageLabel.frame = CGRectMake(targetImageView.frame.origin.x + targetImageView.frame.size.width + xInset,
                                                titleLabel.frame.origin.y + titleLabel.frame.size.height + space,
                                                messageSize.width,
                                                messageSize.height);
                                    
                
                [self addSubview:messageLabel];
        
            }  
        } 
                
    } else {
        
        [topExpandedBGImageView removeFromSuperview];
        [middleExpandedBGImageView removeFromSuperview];
        [bottomExpandedBGImageView removeFromSuperview];
        [backgroundImageView removeFromSuperview];
        [targetImageView removeFromSuperview];
        
        [messageLabel removeFromSuperview];
        [titleLabel removeFromSuperview];
        [detailedLabel removeFromSuperview];
        [photoImageView removeFromSuperview];
        [closeButton removeFromSuperview];        
        
        if(targetType != kSGAnnotationViewTargetType_Custom) {
                    
            if(targetType == kSGAnnotationViewTargetType_Glass) {
            
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                        20.0 + targetImageView.frame.size.width,
                                        40.0 + targetImageView.frame.size.height);
                
                backgroundImageView.frame = CGRectMake(-10.0, -5.0,
                                                        self.bounds.size.width + 20.0,
                                                        self.bounds.size.height  + 20.0);
                [self addSubview:backgroundImageView];
        
                targetImageView.frame = CGRectMake((self.frame.size.width - targetImageView.frame.size.width) / 2.0,
                                                9.0,
                                                targetImageView.frame.size.width,
                                                targetImageView.frame.size.height);        
                [self addSubview:targetImageView];
            
            } else if(targetType == kSGAnnotationViewTargetType_Pin) {
            
                if(pinColor == kSGPinColor_Red)
                    targetImageView.image = [UIImage imageNamed:@"SGRedPin.png"];                
                else if(pinColor = kSGPinColor_Blue)
                    targetImageView.image = [UIImage imageNamed:@"SGBluePin.png"];
                
                self.frame = CGRectMake(self.frame.origin.x,
                                         self.frame.origin.y,
                                        targetImageView.bounds.size.width, 
                                        targetImageView.bounds.size.height);
            
                targetImageView.frame = CGRectMake(0.0, 
                                                   0.0,
                                                   targetImageView.bounds.size.width,
                                                   targetImageView.bounds.size.height);
            
                [self addSubview:targetImageView];
            
            }
        
        }
    }    
    needNewTexture = YES;
}

- (void) resetSubviews
{
    detailedLabel.text = @"";
    detailedLabel.frame = CGRectZero;
    
    titleLabel.text = @"";
    titleLabel.frame = CGRectZero;
    
    messageLabel.text = @"";
    messageLabel.frame = CGRectZero;
    
    photoImageView.image = nil;
    photoImageView.frame = CGRectZero;
}

- (void) drawAnnotationView
{
    // Does nothing
}

- (void) dealloc 
{
    [reuseIdentifier release];
    [detailedLabel release]; 
    [titleLabel release];
    [messageLabel release];    
    [targetImageView release];
    [photoImageView release];
    [closeButton release];
    [radarTargetButton release];    
    [containerImage release];
    [backgroundImageView release];
    [topExpandedBGImageView release];
    [middleExpandedBGImageView release];
    [bottomExpandedBGImageView release];
    free(point);    
    [texture release];
    [radarPointTexture release];
    
    [super dealloc];
}


@end
