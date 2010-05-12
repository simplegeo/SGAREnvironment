//
//  SGTexture.h
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
#import <OpenGLES/ES1/gl.h>

/*
* @enum SGTexturePixelFormat
* @abstract The supported pixel formats for generating
* OpenGL textures.
* @constant kSGTexturePixelFormat_RGBA8888
* @constant kSGTexturePixelFormat_RGB565
* @constant kSGTexturePixelFormat_A8
*/
typedef enum {

	kSGTexturePixelFormat_RGBA8888 = 0,
	kSGTexturePixelFormat_RGB565,
	kSGTexturePixelFormat_A8,
    
} SGTexturePixelFormat;

/*!
* @class SGTexture 
* @abstract This class attempts to represent a UIImage as an OpenGL
* texture.
*/
@interface SGTexture : NSObject
{
    SGTexturePixelFormat pixelFormat;
    NSUInteger width;
    NSUInteger height;
    GLuint name;
	CGSize size;
    GLfloat maxS;
    GLfloat maxT;
    
    @private    
    void* data;
    GLenum format;
    GLenum type;
    GLint internalFormat;
}

/*!
* @property 
* @abstract The pixel format associated with this texture.
*/
@property(readonly) SGTexturePixelFormat pixelFormat;

/*!
* @property
* @abstract The width of the texture.
*/
@property(readonly) NSUInteger width;

/*!
* @property
* @abstract The height of the texture.
*/
@property(readonly) NSUInteger height;

/*!
* @property
* @abstract The integer name associated to the texture.
*/
@property(readonly) GLuint name;

/*!
* @property
* @abstract The height and width of the texture.
*/
@property(readonly, nonatomic) CGSize size;

/*!
* @method initWithImage:
* @abstract Initializes a new SGTexture with a UIImage.
* @param image ￼The image to use while constructing the texture.
* @result ￼A new SGTexture.
*/
- (id) initWithImage:(UIImage*)image;

/*!
* @method drawAtPoint:
* @abstract Renders the texture at the given point, assuming z is 0.
* @param point ￼
*/
- (void) drawAtPoint:(CGPoint)point;

/*!
* @method drawAtPoint:withZ:
* @abstract Renders the texture at given point with a predetermined
* z coordinate.
* @param point ￼
* @param z ￼
*/
- (void) drawAtPoint:(CGPoint)point withZ:(CGFloat)z;

@end


