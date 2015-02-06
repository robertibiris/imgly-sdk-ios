//
//  GPUImageNoiseFilter.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 04.09.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageNoiseFilter.h"

NSString *const kGPUImageNoiseFragmentShaderString = SHADER_STRING
(
 precision highp float;

 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 uniform float intensity;

 void main()
 {

     highp vec4 base = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 overlay = texture2D(inputImageTexture2, textureCoordinate);

     lowp vec4 noisedImage = base * (overlay.a * (base / base.a) + (2.0 * overlay * (1.0 - (base / base.a)))) + overlay * (1.0 - base.a) + base * (1.0 - overlay.a);
     gl_FragColor = mix(base, noisedImage, intensity);

 }

 );

@implementation GPUImageNoiseFilter

@synthesize intensity = _intensity;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageNoiseFragmentShaderString]))
    {
        return nil;
    }


    intensityUniform = [filterProgram uniformIndex:@"intensity"];
    self.intensity = 0.0;
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setIntensity:(CGFloat)newValue;
{
    _intensity = newValue;

    [self setFloat:_intensity forUniform:intensityUniform program:filterProgram];
}


@end

