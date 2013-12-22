//
//  LoginViewController.m
//  iOS Review Time
//
//  Created by The Spencer Family on 12/21/13.
//  Copyright (c) 2013 René Bigot. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.developerNameField.text = [FDKeychain itemForKey:@"developerName" forService:@"iOSReviewTime" error:nil];
    [self.developerNameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [FDKeychain saveItem:textField.text forKey:@"developerName" forService:@"iOSReviewTime" error:nil];
    if ([self.delegate respondsToSelector:@selector(didLoginUser)]) [self.delegate didLoginUser];
    [self dismissViewControllerAnimated:YES completion:nil];
    return YES;
}

- (IBAction)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
