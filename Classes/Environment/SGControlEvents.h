//
//  SGControlEvents.h
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
* @enum SGControlEvent
* @abstract The control events that are triggered within the AR enviornment.
* @discussion These control events are created from @link //simplegeo/ooc/cl/SG3DOverlayEnvironment SG3DOverlayEnviornment @/link.
* Since the AR environment is rendered in OpenGL, we have to be responsible for computing
* what type of touch events are generated.
* @constant kSGControlEvent_Drag
* @constant kSGControlEvent_DragEnded
* @constant kSGControlEvent_Touch
* @constant kSGControlEvent_DoubleTouch
* @constant kSGControlEvent_TouchEnded
*/
enum SGControlEvent {

    kSGControlEvent_Drag = 0,
    kSGControlEvent_DragEnded,
    kSGControlEvent_Touch,
    kSGControlEvent_DoubleTouch,
    kSGControlEvent_TouchEnded

};

typedef NSInteger SGControlEvent;