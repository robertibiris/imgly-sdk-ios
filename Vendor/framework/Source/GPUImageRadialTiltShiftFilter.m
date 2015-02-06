//
//  GPUImageRadialTiltShiftFilter.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 19.08.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageRadialTiltShiftFilter.h"


NSString *const kGPUImageRadialTiltShiftFragmentShaderString = SHADER_STRING
(
 precision highp float;

 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;


 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform lowp vec2 center;
 uniform lowp float radius;
 uniform highp vec2 scaleVector;

 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate);
     lowp vec2 w = (textureCoordinate - center) * scaleVector;
     float lengthW = length(w);
     float mixture = 0.0;
     if (lengthW < radius) {
         mixture = 1.0;
     }
     else {
         mixture = lengthW / radius ;
         mixture = (1.0 - (mixture - 1.0) * 2.0);
     }

     mixture = clamp(mixture, 0.0, 1.0);
     gl_FragColor = mix(textureColor, textureColor2,mixture);
 }
 );

@interface GPUImageRadialTiltShiftFilter()

@property(readwrite, nonatomic) CGPoint center;
@property(readwrite, nonatomic) float radius;

@end

@implementation GPUImageRadialTiltShiftFilter

- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageRadialTiltShiftFragmentShaderString]))
    {
        return nil;
    }
    centerUniform = [filterProgram uniformIndex:@"center"];
    radiusUniform  = [filterProgram uniformIndex:@"radius"];
    scaleVectorUniform = [filterProgram uniformIndex:@"scaleVector"];
    return self;
}

-(void)setControlPoint1:(CGPoint)controlPoint1 {
    _controlPoint1 = controlPoint1;
    [self calculateCenterAndRadius];
}

-(void)setControlPoint2:(CGPoint)controlPoint2 {
    _controlPoint2 = controlPoint2;
    [self calculateCenterAndRadius];
}

-(void)setSclaeVector:(CGPoint)scaleVector {
    _scaleVector = scaleVector;
    glUniform2f(scaleVectorUniform, _scaleVector.x, _scaleVector.y);
    [self calculateCenterAndRadius];
}

- (void)calculateCenterAndRadius {
    self.center = CGPointMake((self.controlPoint1.x + self.controlPoint2.x) * 0.5,
                              (self.controlPoint1.y + self.controlPoint2.y) * 0.5);
    glUniform2f(centerUniform, self.center.x, self.center.y);

    float midVectorX = (self.center.x - self.controlPoint1.x) * self.scaleVector.x ;
    float midVectorY = (self.center.y - self.controlPoint1.y) * self.scaleVector.y ;
    self.radius = sqrt(midVectorX * midVectorX + midVectorY * midVectorY) ;

    glUniform1f(radiusUniform, self.radius);
}

@end
