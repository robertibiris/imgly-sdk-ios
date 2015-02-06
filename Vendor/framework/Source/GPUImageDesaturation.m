//
//  GPUImageDesaturation.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageDesaturation.h"

NSString *const kGPUImageDesaturationFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float desaturation;
 
 void main()
 {
     highp vec3 color = texture2D(inputImageTexture, textureCoordinate).xyz;
     highp vec3 grayXfer = vec3(0.3, 0.59, 0.11);
     highp vec3 gray = vec3(dot(grayXfer, color));
     gl_FragColor = vec4(mix(color, gray, desaturation), 1.0);
 }
 );

@implementation GPUImageDesaturation

@synthesize desaturation = _desaturation;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageDesaturationFragmentShaderString]))
    {
		return nil;
    }
    
    desaturationUniform = [filterProgram uniformIndex:@"desaturation"];
    self.desaturation = 0.0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setDesaturation:(CGFloat)newValue;
{
    _desaturation = newValue;
    
    [self setFloat:_desaturation forUniform:desaturationUniform program:filterProgram];
}

@end

