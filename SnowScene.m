//
//  SnowScene.m
//  uTime
//
//  Created by Matthew Jagiela on 12/4/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

#import "SnowScene.h"

@implementation SnowScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor clearColor];
        NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"S" ofType:@"sks"];
        SKEmitterNode *snow = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        snow.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height);
        snow.name = @"particleBokeh";
        snow.targetNode = self.scene;
        [self addChild:snow];
    }
    return self;
}

@end
