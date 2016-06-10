//
//  ViewController.m
//  YXLKVOImplement
//
//  Created by Tangtang on 16/6/10.
//  Copyright © 2016年 Tangtang. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+YXLKVO.h"
#import "Person.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) Person    *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [[Person alloc] init];
    self.person.name = @"mike";
    self.textLabel.text = self.person.name;
    
    [self.person YXL_addObserver:self WithKey:NSStringFromSelector(@selector(name))
                     resultBlock:^(id ObservedObj, NSString *ObservedKey, id newValue, id oldValue) {
        NSLog(@"newValue = %@  oldValue = %@", newValue, oldValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textLabel.text = newValue;
        });
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonAction:(id)sender {
    NSArray *array = @[@"jim", @"tom", @"mike", @"jane", @"lisa", @"aa", @"bb", @"cc"];
    self.person.name = array[arc4random() % (array.count)];
}

@end
