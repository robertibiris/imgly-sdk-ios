//
//  GPUImageX400Filter.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 23.09.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageX400Filter.h"

NSString *const kGPUImageX400FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     highp vec4 color = texture2D(inputImageTexture, textureCoordinate);
     highp float gray = color.r * 0.3 + color.g * 0.3 + color.b * 0.3;
     gray -= 0.2;
     gray = clamp(gray,0.0,1.0);
     gray += 0.15;
     gray *= 1.4;
     gl_FragColor = vec4(vec3(gray), 1.0);
 }
 );

@implementation GPUImageX400Filter

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageX400FragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}

@end

