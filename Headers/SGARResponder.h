//
//  SGARResponder.h
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

/*!
* @protocol SGARResponder
* @abstract Defines￼ the protocol for objects to respond to gesture and touch events created in the @link //simplegeo/ooc/cl/SGARView SGARView @/link.
* @discussion There are essentially two different enviornments where touch evenets can be generated, the augmented reality enviornment and the 
* normal UIResponder chain. In order to loop in the AR envoirnment with the UIResponder chain, pre-calculations of touch events need to be
* acknowledged by the the AR view before they can be released onto the normal UIResponder chain. This protocol attempts to provides callback
* notifications when gestures are created within the AR envoirnment.
*
* SGARResponders are registered with @link //simplegeo/ooc/cl/SGARView SGARView @/link via
* @link //simplegeo/ooc/instm/SGARView/addResponder: addResponder: @/link.
*/
@protocol SGARResponder <NSObject>

@optional

/*!
* @method ARSingleTap:
* @abstract Notifies the reciever when a single touch event has occurred.
* @param point ￼The point at which the touch event occurred.
*/
- (void) ARSingleTap:(CGPoint)point;

/*!
* @method ARDoubleTap:
* @abstract ￼Notifies the reciever when a double touch event has occurred.
* @param point ￼The point at which the touch event occurred.
*/
- (void) ARDoubleTap:(CGPoint)point;

/*!
* @method ARSingleTapAtPoint:andPoint:
* @abstract Notifies the reciever when a single touch event occurs at two points.
* @param pointOne ￼One of the two points at which the touch event occurred.
* @param pointTwo ￼The other point at which the touch event occurred.
*/
- (void) ARSingleTapAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo;

/*!
* @method ARPinchAtPoint:andPoint:withDistance:
* @abstract Notifies the reciever when a pinch event occurs.
* @param pointOne ￼One of the two points at which the touch event occurred.
* @param pointTwo ￼The other point at which the touch event occurred.
* @param distance ￼The distance between the two points. Why? For convience.
*/
- (void) ARPinchAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo withDistance:(CGFloat)distance;

/*!
* @method ARPullAtPoint:andPoint:withDistance:
* @abstract Notifies the reciever when a pull event occurs.
* @param pointOne ￼One of the two points at which the touch event occurred.
* @param pointTwo ￼The other point at which the touch event occurred.
* @param distance ￼The distance between the two points. Why? Because I can.
*/
- (void) ARPullAtPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo withDistance:(CGFloat)distance;

/*!
* @method ARMoveFromPoint:toPoint:
* @abstract Notifies the reciever when a drag event occurs.
* @param fromPoint ￼The start point of the drag.
* @param toPoint ￼The end point of the drag.
*/
- (void) ARMoveFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

/*!
* @method ARMoveEndedAtPoint:
* @abstract Notifies the reicever when a drag events finishs.
* @param point ￼The point at which the drag event was completed.
*/
- (void) ARMoveEndedAtPoint:(CGPoint)point;

/*!
* @method ARViewDidShake
* @abstract Notifies the reciever when the view is shaken.
*/
- (void) ARViewDidShake;

//
// The following methods are implemented but not thoroughly tested.
//

/*!
 * @method ARTapEndedAtPoint:
 * @abstract Notifies the reciever when a tap has been released.
 * @ point The point at which the tap was released.
 */
- (void) ARTapEndedAtPoint:(CGPoint)point;

/*!
 * @method ARHorizontalSwipeAtPoint:toPoint:
 * @abstract Notifies the delegate when a horizontal swipe has occurred.
 * @param fromPoint ￼The starting point of the swipe.
 * @param toPoint ￼The end point of the swipe.
 */
- (void) ARHorizontalSwipeAtPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

/*!
 * @method ARVerticalSwipeAtPoint:toPoint:
 * @abstract Notifies the delegate when a vertical swipe has occurred.
 * @param fromPoint ￼The starting point of the swipe.
 * @param toPoint ￼The end point of the swipe.
 */
- (void) ARVerticalSwipeAtPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

@end
