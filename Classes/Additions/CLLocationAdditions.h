//
//  CLLocationAdditions.h
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
* @category
* @abstract Helper methods for CLLocation objects.
*/
@interface CLLocation (SGAREnvironment)

/*!
* @method isEqualToLocation:
* @abstract Compares the lat/lon properties of each object to
* eachother.
* @param location The location object to comapre to.
* @result YES if the locations are equal. Otherwise, NO.
*/
- (BOOL) isEqualToLocation:(CLLocation*)location;

/*!
* @method getBearingFromCoordinate:
* @abstract Returns the bearing of the CLLocation object to the
* passed in coordinate.
* @param coord The lat/lon coordinate that will be used to determine
* the bearing.
* @result The bearing ￼of the location object to the passed in
* coordinate.
*/
- (double) getBearingFromCoordinate:(CLLocationCoordinate2D)coord;

/*!
* @method distanceToLocation:
* @abstract Wraps the internal distance calculation method due
* to deprecated versions in the iPhone sSDKs.
* @param location The location to determine the distance from.
* @result The distance of the CLLocation object to the passed in
* location.
*/
- (double) distanceToLocation:(CLLocation*)location;

@end
