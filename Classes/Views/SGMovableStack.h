//
//  SGMovableStack.h
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

#import <UIKit/UIKit.h>
#import "SGAnnotationView.h"

@class SGARView;

/*!*class
* @abstract The view that appears when a drag event occurs over an @link //simplegeo/ooc/cl/SGAnnotationView SGAnnotationView @/link 
* in the AR enviornment.
* @discussion The movable stack will display its collected annotation views in a spilled card deck fashion. The first collected view
* will be on top of the other views.
*
* To change how the stack is presented, override @link drawStackAtPoint:roll: drawStackAtPoint:roll @/link. This method 
* will notify the stack when the origin of the stack has moved along with the orientation of the device.
*/
@interface SGMovableStack : UIView {
 
    NSInteger maxStackAmount;
    SGARView* arView;
 
    @private
    NSMutableArray* movableStack;
}

/*!
* @property
* @abstract The maximum number of allowed @link //simplegeo/ooc/cl/SGAnnotationView SGAnnotationViews @/link 
* to collect. Defaults to 20.
*/
@property (nonatomic, assign) NSInteger maxStackAmount;

/*!
* @property
* @abstract The @link //simplegeo/ooc/cl/SGARView SGARView @/link that owns the movable stack. 
*/
@property (nonatomic, retain) UIView* arView;

/*!
* @method addAnnotationView:
* @abstract ￼Adds an annotation view to the stack.
* @discussion ￼If the movable stack is empty, adding an annotation view will add the stack
* as a subview of the @link //simplegeo/ooc/cl/SGARView SGARView @/link.
* @param view ￼The @link //simplegeo/ooc/cl/SGAnnotaitonView SGAnnotationView @/link to add to the movable stack.
*/
- (void) addAnnotationView:(SGAnnotationView*)view;

/*!
* @method stack 
* @abstract ￼ Returns an array of @link //simplegeo/ooc/cl/SGAnnotationView SGAnntationViews @/link that are
* associated with the movable stack.
* @result ￼ The views associated with the stack.
*/
- (NSArray*) stack;

/*!
* @method emptyStack:
* @abstract ￼Removes all @link //simplegeo/ooc/cl/SGAnnotationView SGAnnotationViews @/link from the stack.
* @discussion When emptying a stack, there are two options. By passing in the value YES once the stack is emptied,
* the views will return back to the AR enviornment. If you specify NO, then the views will no longer be present
* in the AR enviornment.
* @param stillCaptured ￼YES to keep the views alive in the AR enviornment. Otherwise; NO.
*/
- (void) emptyStack:(BOOL)stillCaptured;

/*!
* @method drawStackAtPoint:
* @abstract ￼Called everytime the stack is moved around on the @link //simplegeo/ooc/cl/SGARView SGARView @/link.
* @discussion ￼Since the movable stack can move around as a subview of the @link //simplegeo/ooc/cl/SGARView SGARView @/link,
* the position needs to be updated. 
* @param point ￼The new point of the movable stack.
* @param roll The roll orientation of the device.
*/
- (void) drawStackAtPoint:(CGPoint)point roll:(double)roll;

@end
