//
//  GPUImageColorAddGlow.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 19.11.12.
//  Copyright (c) 2012 Brad Larson. All rights reserved.
//

 
#import "GPUImageGreenGobblin.h"

NSString *const kGPUImageGreenGobblinFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
  
 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     color.b = color.g * 0.33;
     color.r = color.r * 0.6;
     color.b += color.r * 0.33;
     color.g = color.g * 0.7;
     gl_FragColor = color;
 }
);

@implementation GPUImageGreenGobblin


#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageGreenGobblinFragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}

@end
