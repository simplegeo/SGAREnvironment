//
//  SGGlassAnnotationView.h
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

#import "SGAnnotationView.h"

@interface SGGlassAnnotationView : SGAnnotationView {
    
    UIImageView* photoImageView;    
    UIButton* closeButton;    
    UILabel* detailedLabel;
    UILabel* titleLabel;
    UILabel* messageLabel;    

    BOOL inspectionMode;

    @private
    UIImageView* backgroundImageView;
    UIImageView* topExpandedBGImageView;
    UIImageView* middleExpandedBGImageView;
    UIImageView* bottomExpandedBGImageView;
}

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
 * @abstract Toggle between the two different styles this view can create. When inspectionMode is set to false, 
 * the target style is used. When true, the inspect style is used.
 */
@property (nonatomic, assign) BOOL inspectionMode;

+ (CGRect) targetRect;

+ (CGRect) inspectRect;

@end
