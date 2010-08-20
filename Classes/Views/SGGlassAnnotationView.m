//
//  SGGlassAnnotationView.m
//  ARViewStyles
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

#import "SGGlassAnnotationView.h"

@interface SGGlassAnnotationView (Private)

- (void) createObjectSubviews;
- (void) resetSubviews;

@end

@implementation SGGlassAnnotationView
@synthesize detailedLabel, titleLabel, messageLabel, photoImageView, closeButton;
@dynamic inspectionMode;

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier
{
    if(self = [super initWithFrame:frame reuseIdentifier:identifier]) {
        [self createObjectSubviews];
        [self resetSubviews];
    }
    
    return self;
}

+ (CGRect) targetRect
{
    return CGRectMake(0.0, 0.0, 80.0, 100.0);
}

+ (CGRect) inspectRect;
{
    return CGRectMake(0.0, 0.0, 280.0, 200.0);
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
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    [self resetSubviews];
}

#pragma mark -
#pragma mark Accessor methods 

- (void) setInspectionMode:(BOOL)mode
{
    inspectionMode = mode;
    [self layoutSubviews];
}

- (BOOL) inspectionMode
{
    return inspectionMode;
}

#pragma mark -
#pragma mark UIView overrides 

- (void) layoutSubviews
{
    [super layoutSubviews];
    if(inspectionMode) {
        [backgroundImageView removeFromSuperview];
        [targetImageView removeFromSuperview];
                    
        CGSize photoSize = CGSizeZero;
        UIImage* photoImage = photoImageView.image;                
        if(photoImageView.image)
            photoSize = photoImage.size;
        
        CGSize messageSize;
        NSString* text = messageLabel.text;
        if(!text || ![text length])
            messageSize = CGSizeMake(224.0, 20.0);
        else
            messageSize = [text sizeWithFont:messageLabel.font
                           constrainedToSize:CGSizeMake(224.0, 1000.0)
                               lineBreakMode:UILineBreakModeWordWrap];    
        
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
        if(photoImageView.image) {                
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
            
        } else {
            messageLabel.frame = CGRectMake(targetImageView.frame.origin.x + targetImageView.frame.size.width + xInset,
                                            titleLabel.frame.origin.y + titleLabel.frame.size.height + space,
                                            messageSize.width,
                                            messageSize.height);
            [self addSubview:messageLabel];                
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
    }
    
    self.needNewTexture = YES;    
}

#pragma mark -
#pragma mark Utility methods 

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

- (void) dealloc
{
    [detailedLabel release]; 
    [titleLabel release];
    [backgroundImageView release];
    [topExpandedBGImageView release];
    [middleExpandedBGImageView release];
    [bottomExpandedBGImageView release];
    [photoImageView release];
    [closeButton release];
    [messageLabel release];    
    
    [super dealloc];
}

@end
