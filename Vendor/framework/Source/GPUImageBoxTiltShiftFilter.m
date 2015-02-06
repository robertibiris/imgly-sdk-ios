//
//  GPUImageBoxTiltShiftFilter.m
//  GPUImage
//
//  Created by Carsten Przyluczky on 13.08.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageBoxTiltShiftFilter.h"

NSString *const kGPUImageBoxTiltShiftFragmentShaderString = SHADER_STRING
(
 precision highp float;

 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 uniform lowp vec2 controlPoint1;
 uniform lowp vec2 connectionVector;
 uniform lowp vec2 scaleVector;


 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate);

     lowp vec2 v = connectionVector; //(controlPoint2 - controlPoint1) * scaleVector;
     lowp vec2 w = (textureCoordinate - controlPoint1) * scaleVector;
     float lengthV = dot(v,v);
     float dotVW = dot(v,w);
     float mixture = dotVW / lengthV;
     if(mixture > 1.0) {
         mixture = (1.0 - (mixture - 1.0) * 2.0) ;
     }
     else if(mixture < 0.0) {
         mixture = (mixture * 2.0 + 1.0 );
     } else {
         mixture = 1.0;
     }
     mixture = clamp(mixture, 0.0, 1.0);
     gl_FragColor = mix(textureColor, textureColor2,mixture);
 }
 );

@interface GPUImageBoxTiltShiftFilter()

@property(readwrite, nonatomic) CGPoint connectionVector;

@end


@implementation GPUImageBoxTiltShiftFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageBoxTiltShiftFragmentShaderString]))
    {
		return nil;
    }
    controllPoint1Uniform = [filterProgram uniformIndex:@"controlPoint1"];
    connectionVectorUniform = [filterProgram uniformIndex:@"connectionVector"];
    scaleVectorUniform = [filterProgram uniformIndex:@"scaleVector"];
    return self;
}

-(void)setControlPoint1:(CGPoint)controlPoint1 {
    _controlPoint1 = controlPoint1;
    glUniform2f(controllPoint1Uniform, _controlPoint1.x, _controlPoint1.y);
    [self calculateConnectionVector];
}

-(void)setControlPoint2:(CGPoint)controlPoint2 {
    _controlPoint2 = controlPoint2;
    [self calculateConnectionVector];
//    glUniform2f(controllPoint2Uniform, _controlPoint2.x, _controlPoint2.y);
}

-(void)setSclaeVector:(CGPoint)scaleVector {
    _scaleVector = scaleVector;
    glUniform2f(scaleVectorUniform, _scaleVector.x, _scaleVector.y);
    [self calculateConnectionVector];
}

-(void)calculateConnectionVector {
    //(controlPoint2 - controlPoint1) * scaleVector;
    self.connectionVector = CGPointMake((self.controlPoint2.x - self.controlPoint1.x) * self.scaleVector.x,
                                        (self.controlPoint2.y - self.controlPoint1.y) * self.scaleVector.y);
    glUniform2f(connectionVectorUniform, self.connectionVector.x, self.connectionVector.y);

}

@end
