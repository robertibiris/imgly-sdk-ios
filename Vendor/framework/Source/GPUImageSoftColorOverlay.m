//
//  GPUImageSoftColorOverlay.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageSoftColorOverlay.h"

NSString *const kGPUImageSoftColorOverlayFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;
 uniform highp vec3 overlayColor;

 void main()
 {
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 overlayColorAsVec4 = vec4(overlayColor.r, overlayColor.g, overlayColor.b, textureColor.a);
     gl_FragColor = max(textureColor, overlayColorAsVec4);
 }
 );

@implementation GPUImageSoftColorOverlay

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageSoftColorOverlayFragmentShaderString]))
    {
        return nil;
    }

    overlayColorUniform = [filterProgram uniformIndex:@"overlayColor"];
    GPUVector3 colorToReplace = {0, 0, 0};
    [self setVec3:colorToReplace forUniform:overlayColorUniform program:filterProgram];
    return self;
}

- (void) setOverlayColorRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue{
    GLfloat redComponent = (GLfloat)red / 255.0;
    GLfloat greenComponent = (GLfloat)green / 255.0;
    GLfloat blueComponent = (GLfloat)blue / 255.0;

    GPUVector3 colorToReplace = {redComponent, greenComponent, blueComponent};
    [self setVec3:colorToReplace forUniform:overlayColorUniform program:filterProgram];
}


@end
