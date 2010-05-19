//
//  SGTexture.m
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

#import "SGTexture.h"
#define kMaxTextureSize	 1024 

@interface SGTexture (Private)
- (void) rebind;
- (NSUInteger) getProperLength:(double)length;
- (void) configurePixelFormat:(CGImageRef)image withTransform:(CGAffineTransform)transform;
@end

@implementation SGTexture
@synthesize size, width, height, name, pixelFormat;

- (id) initWithImage:(UIImage*)uImage
{
	CGImageRef image = [uImage CGImage];
    
	if(!image) {
		SGLog(@"SGTexture - Image is Null");
		return nil;
	}
    
    if(self = [super init]) {
        CGImageAlphaInfo info = CGImageGetAlphaInfo(image);
        BOOL hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
        
        if(CGImageGetColorSpace(image)) {
            if(hasAlpha)
                pixelFormat = kSGTexturePixelFormat_RGBA8888;
            else
                pixelFormat = kSGTexturePixelFormat_RGB565;
        } else
            pixelFormat = kSGTexturePixelFormat_A8;
        
        
        size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
        
        width = [self getProperLength:size.width];
        height = [self getProperLength:size.height];
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
            width /= 2;
            height /= 2;
            transform = CGAffineTransformScale(transform, 0.5, 0.5);
            size.width *= 0.5;
            size.height *= 0.5;
        }

        maxS = size.width / (float)width;
        maxT = size.height / (float)height;
        
        [self configurePixelFormat:image withTransform:transform];
        [self rebind];
    }
	
	return self;
}

- (void) drawAtPoint:(CGPoint)point
{
    [self drawAtPoint:point withZ:0.0];
}

- (void) drawAtPoint:(CGPoint)point withZ:(CGFloat)z
{
	GLfloat coordinates[] = { 
        0, maxT,
        maxS, maxT,
        0, 0,
        maxS, 0
    };
    
	GLfloat w = (GLfloat)width * maxS;
	GLfloat h = (GLfloat)height * maxT;
    
	GLfloat	vertices[] = {	
        -w / 2 + point.x, -h / 2 + point.y,	z,
        w / 2 + point.x, -h / 2 + point.y, z,
		-w / 2 + point.x, h / 2 + point.y, z,
        w / 2 + point.x, h / 2 + point.y, z 
    };
    
    if(!glIsTexture(name))
        [self rebind];
	
	glBindTexture(GL_TEXTURE_2D, name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) rebind
{
    glGenTextures(1, &name);
    glBindTexture(GL_TEXTURE_2D, name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, width, height, 0, type, format, data);
}

- (void) configurePixelFormat:(CGImageRef)image withTransform:(CGAffineTransform)transform
{   
    CGContextRef context = nil;
    void* imageData = nil;
    CGColorSpaceRef colorSpace;
    void* tempData;
    unsigned int* inPixel32;
    unsigned short* outPixel16;
    switch(pixelFormat) {	
        case kSGTexturePixelFormat_RGBA8888:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            imageData = malloc(height * width * 4);
            context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            format = GL_RGBA;
            type = GL_UNSIGNED_BYTE;
            internalFormat = GL_RGBA;
            break;
        case kSGTexturePixelFormat_RGB565:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            imageData = malloc(height * width * 4);
            context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            format = GL_RGB;
            type = GL_UNSIGNED_SHORT_5_6_5;
            internalFormat = GL_RGBA;
            break;
        case kSGTexturePixelFormat_A8:
            imageData = malloc(height * width);
            context = CGBitmapContextCreate(imageData, width, height, 8, width, NULL, kCGImageAlphaOnly);
            format = GL_ALPHA;
            type = GL_UNSIGNED_BYTE;
            internalFormat = GL_ALPHA;
            break;				
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
    }
    
    CGContextClearRect(context, CGRectMake(0, 0, width, height));
    CGContextTranslateCTM(context, 0, height - size.height);
    
    if(!CGAffineTransformIsIdentity(transform))
        CGContextConcatCTM(context, transform);
    
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
    CGContextDrawImage(context, imageRect, image);
    
    // We want to convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" into
    // "RRRRRGGGGGGBBBBB"
    if(pixelFormat == kSGTexturePixelFormat_RGB565) {    
        tempData = malloc(height * width * 2);
        inPixel32 = (unsigned int*)imageData;
        outPixel16 = (unsigned short*)tempData;
        int i;
        for(i = 0; i < width * height; ++i, ++inPixel32)
            *outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
        
        free(imageData);
        imageData = tempData;
    }

    data = (void*)imageData;
    CGContextRelease(context);
}    

- (NSUInteger) getProperLength:(double)length
{    
    NSUInteger i;
    if((length != 1) && (length && (length - 1))) {
        i = 1;
        while(i < length)
            i *= 2;
        length = i;
    }    
    
    return length;
}

- (void) dealloc
{
	if(name)
		glDeleteTextures(1, &name);
    
    free(data);
	
	[super dealloc];
}


@end
