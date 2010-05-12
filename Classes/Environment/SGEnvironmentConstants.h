//
//  SGEnvironmentConstants.h
//  SGAREnvironments
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

extern void SGInitializeEnvironmentSettings();

extern float kSGEnvironment_ViewingRadius;
extern float kSGSphere_Radius;
extern float kSGAnnotation_MaximumDistance;
extern float kSGAnnotation_MinimumDistance;

/*!
 * @function SGSetEnvironmentViewingRadius
 * @abstract ￼ Sets the viewing radius of the AR view. The default is 100m.
 * @discussion The viewing radius determines what records are drawn in the AR view. If the distance
 * from the record to the current location is greater than the view radius, then the record will
 * not be drawn.
 * @param ￼ radius The radius in meters.
 */ 
extern void SGSetEnvironmentViewingRadius(float radius);

/*!
 * @function SGSetEnvironmentMaximumAnnotationDistance
 * @abstract ￼ Sets the maximum allowed distance for a record annotation view. The default is 100m.
 * @discussion ￼ This helps scale views to a decent size because the enviornment is orthogonal.
 * @param ￼ maxDistance The maximum distance for a record annotation view.
 */
extern void SGSetEnvironmentMaximumAnnotationDistance(float maxDistance);

/*!
 * @function SGSetEnvironmentMinimumAnnotationDistance
 * @abstract ￼ Sets the minimum allowed distance for a record annotation view. The default is 3m.
 * @discussion ￼ This helps keep record annotation views at a safe distance from device's current location.
 * @param ￼ minDistance The minimum distance for a record annotation view.
 */
extern void SGSetEnvironmentMinimumAnnotationDistance(float minDistance);