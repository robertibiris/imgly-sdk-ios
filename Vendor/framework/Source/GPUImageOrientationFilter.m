//
//  GPUImageOrientationFilter.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 21.08.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageOrientationFilter.h"


NSString *const kGPUImageFlipFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
 uniform int flipHorizontal;
 uniform int flipVertical;

 void main()
 {
     highp vec2 uv = textureCoordinate;
     if(flipHorizontal == 1) {
         uv.x = 1.0 - uv.x;
     }
     if(flipVertical == 1) {
         uv.y = 1.0 - uv.y;
     }

    gl_FragColor = texture2D(inputImageTexture, uv);

 }
 );

@implementation GPUImageOrientationFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageFlipFragmentShaderString]))
    {
        return nil;
    }

    flipHorizontalUniform = [filterProgram uniformIndex:@"flipHorizontal"];
    flipVerticalUniform = [filterProgram uniformIndex:@"flipVertical"];
    [self setInteger:0 forUniform:flipHorizontalUniform program:filterProgram];
    [self setInteger:0 forUniform:flipVerticalUniform program:filterProgram];
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setFlipHorizontal:(GLint)flipHorizontal {
    _flipHorizontal = flipHorizontal;
    [self setInteger:flipHorizontal forUniform:flipHorizontalUniform program:filterProgram];
}

- (void)setFlipVertical:(GLint)flipVertical {
    _flipVertical = flipVertical;
    [self setInteger:flipVertical forUniform:flipVerticalUniform program:filterProgram];
}

@end

