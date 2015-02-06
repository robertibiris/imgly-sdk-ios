//
//  GPUImageOneColorGrayFilter.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 30.10.12.
//  Copyright (c) 2012 Brad Larson. All rights reserved.
//

#import "GPUImageOneColorGrayFilter.h"

@implementation GPUImageOneColorGrayFilter

@synthesize thresholdSensitivity = _thresholdSensitivity;
@synthesize smoothing = _smoothing;

NSString *const kGPUOneColorGrayFragmentShaderString = SHADER_STRING
(
     precision highp float;
     
     varying vec2 textureCoordinate;
     
     uniform float thresholdSensitivity;
     uniform float smoothing;
     uniform vec3 colorToReplace;
     uniform sampler2D inputImageTexture;
     
     const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

     void main() // normales Graubild mit rot = rot
     {
         vec4 color = texture2D(inputImageTexture , textureCoordinate);
         float luminance = dot(color.rgb, W);
         float red = max(color.r - color.g - color.b, 0.0);
         color = vec4(vec3(luminance), 1.0);
         color = vec4(((color.rgb - vec3(0.5)) * 1.2 + vec3(0.5)), color.w);
         color.r +=  red * 1.2;
         
         gl_FragColor =  color;// apply contrast and return
     }
);


#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUOneColorGrayFragmentShaderString]))
    {
		return nil;
    }
    
    thresholdSensitivityUniform = [filterProgram uniformIndex:@"thresholdSensitivity"];
    smoothingUniform = [filterProgram uniformIndex:@"smoothing"];
    colorToReplaceUniform = [filterProgram uniformIndex:@"colorToReplace"];
    
    self.thresholdSensitivity = 0.3;
    self.smoothing = 0.11;
    [self setColorToReplaceRed:1.0 green:0.0 blue:0.0];
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setColorToReplaceRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
{
    GPUVector3 colorToReplace = {redComponent, greenComponent, blueComponent};
    
    [self setVec3:colorToReplace forUniform:colorToReplaceUniform program:filterProgram];
}

- (void)setThresholdSensitivity:(GLfloat)newValue;
{
    _thresholdSensitivity = newValue;
    
    [self setFloat:_thresholdSensitivity forUniform:thresholdSensitivityUniform program:filterProgram];
}

- (void)setSmoothing:(GLfloat)newValue;
{
    _smoothing = newValue;
    
    [self setFloat:_smoothing forUniform:smoothingUniform program:filterProgram];
}


@end
