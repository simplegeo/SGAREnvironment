//
//  CLLocationAdditions.m
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

#import "CLLocationAdditions.h"

#import "SGMath.h"

@implementation CLLocation (SGAREnvironment)

- (BOOL) isEqualToLocation:(CLLocation*)location
{
    BOOL locationsAreEqual = YES;
    
    if(location) {

        // We are just going to compare these two values for now
        locationsAreEqual &= location.coordinate.latitude == self.coordinate.latitude;
        locationsAreEqual &= location.coordinate.longitude == self.coordinate.longitude;
    }
    
    return locationsAreEqual;
}

- (double) getBearingFromCoordinate:(CLLocationCoordinate2D)coord
{
    double firstLat = DEGREES_TO_RADIANS(self.coordinate.latitude);
    double firstLon = DEGREES_TO_RADIANS(self.coordinate.longitude);
    double secondLat = DEGREES_TO_RADIANS(coord.latitude);
    double secondLon = DEGREES_TO_RADIANS(coord.longitude);
    
    double deltaLong = secondLon - firstLon;
    double x = cos(firstLat) * sin(secondLat) - sin(firstLat) * cos(secondLat) * cos(deltaLong);
    double y = sin(deltaLong) * cos(secondLat);
    double b = atan2(y, x); 
    b = RADIANS_TO_DEGREES(b);
    return b < 0.0 ? b + 360.0 : b;
}

- (double) distanceToLocation:(CLLocation*)location
{
    double distance;
#if __IPHONE_4_0 && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0
    
    distance = [self distanceFromLocation:location];
    
#else
    
    distance = [self getDistanceFrom:location];
    
#endif
    return distance;
}

@end
