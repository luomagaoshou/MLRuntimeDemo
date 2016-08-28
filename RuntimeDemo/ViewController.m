//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 妙龙赖 on 16/8/28.
//  Copyright © 2016年 妙龙赖. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>

#import "NSObject+RunTimeHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self runtimeMethodUsage];
    [self runtimeIvarAndPropertyUsage];
    
    
    [self runtimeCategoryUsage];
    
    
}

- (void)runtimeMethodUsage{
    
    
    Class testClass = [UIView class];
    
    //添加方法
    [self addMethodWithClass:testClass];
    
    //使用view作为 测试对象
    id testObject =self.view;
    //测试
    [self testAddMethodWithClass:testClass object:testObject];
    
    
}
- (void)runtimeIvarAndPropertyUsage{
    
    //根据名字取得类
    Class testClass = objc_getClass("MLView");
    if (!testClass) {
        //动态创建类
        testClass = objc_allocateClassPair([UIView class], "MLView", 0);
    }
    //添加ivar(只有动态创建类时才能添加ivar)与property
    [self addIvarAndPropertyWithClass:testClass];
    //注册类名
    objc_registerClassPair(testClass);
    //使用view作为 测试对象
    id testObject =self.view;
    //设置testObject的类，就可以使用动态创建的ivar
    object_setClass(testObject, testClass);
    //测试
    [self testIvarAndPropertyWithClass:testClass object:testObject];
    
}




- (void)addMethodWithClass:(Class)class{
    
    
    //添加imp到sel
    BOOL isAddInstanceMethodFormImpSuccess = class_addMethod(class, sel_registerName("instanceMethod"), (IMP)testFunc1, "v@:");
    if (isAddInstanceMethodFormImpSuccess) {
        NSLog(@"添加imp方法成功");
    }
#if 0
    //取得instanceMethod的Method  并对其imp重新赋值
    Method method = class_getInstanceMethod(class, @selector(instanceMethod));
    IMP oringinalImp = method_setImplementation(method, (IMP)testFunc2);
#endif
    
    //添加类方法
    BOOL isAddClassMethodFormImpSuccess = class_addMethod(object_getClass(class), sel_registerName("classMethod"), (IMP)testFunc3, "v@:");
    if (isAddClassMethodFormImpSuccess) {
        NSLog(@"添加imp方法成功");
    }
    
    
    //取得blcok的imp指针
    IMP impOfBlock = imp_implementationWithBlock(^(id obj, NSString *string,...){
        NSLog(@"调用者:%@\nstring:%@", obj, string);
    });
    
    //添加impOfBlock到sel
    BOOL isAddMethodFormImpOfBlockSuccess = class_addMethod(class, sel_registerName("instanceMethodImpOfBlock:"), impOfBlock, "v@:@");
    if (isAddMethodFormImpOfBlockSuccess) {
        NSLog(@"添加impOfBlock方法成功");
    }
    
    
}

- (void)testAddMethodWithClass:(Class)class object:(id)object{
#if 1
    [object performSelector:@selector(instanceMethod)];
    [object performSelector:@selector(instanceMethodImpOfBlock:) withObject:@"我要调用Block"];
    [(id)class performSelector:@selector(classMethod)];
    
#else
    //使用 objc_msgSend调用方法
    ((void (*)(id, SEL))objc_msgSend)(object, @selector(instanceMethod));
    ((void (*)(id, SEL, NSString *))objc_msgSend)(object, @selector(instanceMethodImpOfBlock:), @"我要调用Block");
    ((void (*)(id, SEL))objc_msgSend)(class, @selector(classMethod));
#endif
    
}



/**
 *  添加ivar与property
 *
 *  @param class 测试类
 */
- (void)addIvarAndPropertyWithClass:(Class)class{
    //Ivar
    BOOL isAddIvarSuccess = class_addIvar(class, "_runtimeString", sizeof(NSString *), log(sizeof(NSString *)), "@\"NSString\"");
    if (isAddIvarSuccess) {
        NSLog(@"添加ivar成功");
    }
    //Declared Properties 苹果官方定义propety文档
    // https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
    
    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t backingivar  = { "V", "_runtimeString" };
    objc_property_attribute_t attrs[] = {type, backingivar};
    BOOL isAddPropertySuccess = class_addProperty(class, "runtimeString", attrs, sizeof(attrs)/sizeof(objc_property_attribute_t));
    if (isAddPropertySuccess) {
        NSLog(@"添加property成功");
    }
}
/**
 *测试添加的ivar与property
 *
 *  @param class  测试类
 *  @param object 测试对象
 */
- (void)testIvarAndPropertyWithClass:(Class)class object:(id)object{
    //获取ivar并赋值
    Ivar ivar = class_getInstanceVariable(class, "_runtimeString");
    object_setIvar(object, ivar, @"addIvar测试字符串");
    NSLog(@"addIvar的值:%@", object_getIvar(object, ivar));
    
    //获取property并赋值
    objc_property_t property = class_getProperty(class, "runtimeString");
    const char *propertyAttr = property_getAttributes(property);
    NSLog(@"addProperty的细节:%s", propertyAttr);
    [object setValue:@"addProperty测试字符串" forKey:@"_runtimeString"];
    NSLog(@"addProperty的值:%@", [object valueForKey:@"_runtimeString"]);
    
}



#pragma mark - 测试用的函数
void testFunc1(id self, SEL _cmd) {
    
    NSLog(@"实现testFunc1");
    
}
void testFunc2(id self, SEL _cmd) {
    
    NSLog(@"实现testFunc2");
    
}
void testFunc3(id self, SEL _cmd) {
    
    NSLog(@"%@", @"实现testFunc3");
    
}



#pragma mark - RunTime Category的使用
- (void)runtimeCategoryUsage
{
    
    NSObject *testObject = [[NSObject alloc] init];
    testObject.featureIdentifier = @"特性标记:哈哈哈";
    NSLog(@"关联属性值为:%@", testObject.featureIdentifier);

    
    Class testClass = objc_getClass("UIView");
    NSAssert(testClass, @"该类不存在，请设置存在的类");
    NSLog(@"该类的ivars:%@", [testClass arrayOfIvars]);
    NSLog(@"该类的properties:%@", [testClass arrayOfProperties]);
    NSLog(@"该类的实例方法列表:%@", [testClass arrayOfInstanceMethods]);
    NSLog(@"该类的类方法列表:%@", [testClass arrayOfClassMethods]);
    NSLog(@"该类遵循的协议列表:%@", [testClass arrayOfProtocols]);
    NSLog(@"该工程下所有的类列表:%@", [NSObject arrayOfAllClass]);
    
    
    
}
@end
