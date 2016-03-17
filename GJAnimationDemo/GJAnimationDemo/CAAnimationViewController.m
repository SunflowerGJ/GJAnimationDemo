//
//  CAAnimationViewController.m
//  GJAnimationDemo
//
//  Created by GJ on 16/3/17.
//  Copyright © 2016年 GJ. All rights reserved.
//

#import "CAAnimationViewController.h"

//#import <QuartzCore/QuartzCore.h>

#define IsIOS7orAbove ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)
#define kYOffset        (IsIOS7orAbove ? (44 + 20) : 0)

@interface CAAnimationViewController ()
{
    CALayer *scaleLayer;
    CALayer *moveLayer;
    CALayer *rotateLayer;
    CALayer *groupLayer;
}
@end

@implementation CAAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"CAAnimation";
    
//    [self loadScaleLayer];
    [self initScaleLayer];
    [self initMoveLayer];
    [self initRotateLayer];
    [self initGroupLayer];
}
-(void)loadScaleLayer{
    CALayer *layerActor = [[CALayer alloc] init];
    [layerActor setBackgroundColor:[UIColor yellowColor].CGColor];
    layerActor.frame = CGRectMake(60, 100, 50, 50);
    layerActor.cornerRadius = 10;
    [self.view.layer addSublayer:layerActor];
    
    CABasicAnimation *animateActor = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animateActor.fromValue = @(1);
    animateActor.toValue = @(1.5);
    animateActor.autoreverses = YES;//
    animateActor.fillMode = kCAFillModeForwards;
    animateActor.repeatCount = MAXFLOAT;//永久重复
    animateActor.duration = 0.8;
    
    [layerActor addAnimation:animateActor forKey:@"scaleAnimation"];
}
- (void)initScaleLayer
{
    //演员初始化
    scaleLayer = [[CALayer alloc] init];
    scaleLayer.backgroundColor = [UIColor blueColor].CGColor;
    scaleLayer.frame = CGRectMake(60, 20 + kYOffset, 50, 50);
    scaleLayer.cornerRadius = 10;
    [self.view.layer addSublayer:scaleLayer];
    
    //设定剧本
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.5];
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fillMode = kCAFillModeBackwards;
    scaleAnimation.repeatCount = MAXFLOAT;
    scaleAnimation.duration = 0.8;
    
    //开演
    [scaleLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}
- (void)initMoveLayer
{
    //演员初始化
    moveLayer = [[CALayer alloc] init];
    moveLayer.backgroundColor = [UIColor redColor].CGColor;
    moveLayer.frame = CGRectMake(60, 130 + kYOffset, 50, 50);
    moveLayer.cornerRadius = 10;
    [self.view.layer addSublayer:moveLayer];
    
    //设定剧本
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:moveLayer.position];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(320 - 80,
                                                                  moveLayer.position.y)];
    moveAnimation.autoreverses = YES;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.repeatCount = MAXFLOAT;
    moveAnimation.duration = 2;
    
    //开演
    [moveLayer addAnimation:moveAnimation forKey:@"moveAnimation"];
}

- (void)initRotateLayer
{
    //演员初始化
    rotateLayer = [[CALayer alloc] init];
    rotateLayer.backgroundColor = [UIColor greenColor].CGColor;
    rotateLayer.frame = CGRectMake(60, 240 + kYOffset, 50, 50);
    rotateLayer.cornerRadius = 10;
    [self.view.layer addSublayer:rotateLayer];
    
    //设定剧本
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:2.0 * M_PI];
    rotateAnimation.autoreverses = YES;
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.repeatCount = MAXFLOAT;
    rotateAnimation.duration = 2;
    
    //开演
    [rotateLayer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
}

- (void)initGroupLayer
{
    //演员初始化
    groupLayer = [[CALayer alloc] init];
    groupLayer.frame = CGRectMake(60, 340+100 + kYOffset, 50, 50);
    groupLayer.cornerRadius = 10;
    groupLayer.backgroundColor = [[UIColor purpleColor] CGColor];
    [self.view.layer addSublayer:groupLayer];
    
    //设定剧本
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.5];
    scaleAnimation.autoreverses = YES;
    scaleAnimation.repeatCount = MAXFLOAT;
    scaleAnimation.duration = 0.8;
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:groupLayer.position];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(320 - 80,
                                                                  groupLayer.position.y)];
    moveAnimation.autoreverses = YES;
    moveAnimation.repeatCount = MAXFLOAT;
    moveAnimation.duration = 2;
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:6.0 * M_PI];
    rotateAnimation.autoreverses = YES;
    rotateAnimation.repeatCount = MAXFLOAT;
    rotateAnimation.duration = 2;
    
    CAAnimationGroup *groupAnnimation = [CAAnimationGroup animation];
    groupAnnimation.duration = 2;
    groupAnnimation.autoreverses = YES;
    groupAnnimation.animations = @[moveAnimation, scaleAnimation, rotateAnimation];
    groupAnnimation.repeatCount = MAXFLOAT;
    //开演
    [groupLayer addAnimation:groupAnnimation forKey:@"groupAnnimation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
