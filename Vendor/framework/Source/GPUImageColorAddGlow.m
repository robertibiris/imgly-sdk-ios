//
//  GPUImageColorAddGlow.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 19.11.12.
//  Copyright (c) 2012 Brad Larson. All rights reserved.
//

 
#import "GPUImageColorAddGlow.h"

NSString *const kGPUImageColorGlowAddFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
 
 uniform highp float glowStart;
 uniform highp float glowEnd;
 uniform vec3 colorToAdd;
 
 void main()
 {
     lowp vec3 rgb = texture2D(inputImageTexture, textureCoordinate).rgb;
     vec2 texturCoord =  textureCoordinate - vec2(0.5,0.5);
     texturCoord /= 0.75;
     lowp float d = 1.0 - dot(texturCoord, texturCoord);
     d = clamp(d , 0.2, 1.0);
     rgb = rgb * (d * colorToAdd.rgb);
     gl_FragColor = vec4(vec3(rgb),1.0);
     //    gl_FragColor = vec4(vec3(d),1.0);
 }
 );

@implementation GPUImageColorAddGlow

@synthesize glowStart =_glowStart;
@synthesize glowEnd = _glowEnd;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageColorGlowAddFragmentShaderString]))
    {
		return nil;
    }
    
    glowStartUniform = [filterProgram uniformIndex:@"glowStart"];
    glowEndUniform = [filterProgram uniformIndex:@"glowEnd"];
    colorToAddUniform = [filterProgram uniformIndex:@"colorToAdd"];
    
    self.glowStart = 0.0;
    self.glowEnd = 1.0;
    [self setColorToAddRed:1.0 green:1.0 blue:1.0];

    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setVignetteStart:(CGFloat)newValue;
{
    _glowStart = newValue;
    [self setFloat:_glowStart forUniform:glowStartUniform program:filterProgram];
}

- (void)setVignetteEnd:(CGFloat)newValue;
{
    _glowEnd = newValue;
    [self setFloat:_glowEnd forUniform:glowEndUniform program:filterProgram];
}

- (void)setColorToAddRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
{
    GPUVector3 colorToAdd = {redComponent, greenComponent, blueComponent};
    [self setVec3:colorToAdd forUniform:colorToAddUniform program:filterProgram];
}
@end
