//
//  PurchaseFetchViewController.m
//  iOS Review Time
//
//  Created by iRare Media on 12/27/13.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "PurchaseFetchViewController.h"

@interface PurchaseFetchViewController () {
    EBPurchase *purchase;
    BOOL isPurchased;
} @end

@implementation PurchaseFetchViewController
@synthesize purchaseButton;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Setup the scroll view
    self.scrollView.contentSize = CGSizeMake(320, 508);
    
    if (![FDKeychain itemForKey:PRODUCT_ID forService:@"iOSReviewTime" error:nil]) {
        // Create an instance of EBPurchase
        purchase = [[EBPurchase alloc] init];
        purchase.delegate = self;
        
        // Assume the user has not purchased this feature
        isPurchased = NO;
    } else {
        // Assume the user has purchased this feature
        isPurchased = YES;
        purchaseButton.enabled = NO;
        purchaseButton.titleLabel.text = @"Already Purchased";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Purchased" message:@"You've already purchased this feature. You can turn it ON / OFF in iOS Settings > General > Background App Refresh" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Only enable after populated with iAP price.
    purchaseButton.enabled = NO;
    
    // Request In-App Purchase product info and availability.
    if (![purchase requestProduct:PRODUCT_ID]) {
        // Returned NO, so notify user that In-App Purchase is Disabled in their Settings
        [purchaseButton setTitle:@"Purchase Disabled in Settings" forState:UIControlStateNormal];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)purchase:(id)sender {
    // First, ensure that the SKProduct that was requested by the EBPurchase requestProduct method in the viewWillAppear event is valid before trying to purchase it.
    if (purchase.validProduct != nil) {
        if (![purchase purchaseProduct:purchase.validProduct]) [self displayAllowPurchaseAlert];
    }
}

- (IBAction)restorePurchase:(id)sender {
    // Restore a customer's previous non-consumable or subscription In-App Purchase.
    // Required if a user reinstalled app on same device or another device.
    
    // Call restore method
    if (![purchase restorePurchase]) [self displayAllowPurchaseAlert];
}

- (void)displayAllowPurchaseAlert {
    // Returned NO, so notify user that In-App Purchase is Disabled in their Settings.
    UIAlertView *settingsAlert = [[UIAlertView alloc] initWithTitle:@"Allow Purchases" message:@"You must first enable In-App Purchase in your iOS Settings before restoring a previous purchase." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [settingsAlert show];
}

#pragma mark - Contact

- (void)contact {
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setMailComposeDelegate:self];
    [mailComposer setToRecipients:@[@"contact@iraremedia.com"]];
    [mailComposer setSubject:@"iOSRT iAP Issue"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    [mailComposer setMessageBody:[NSString stringWithFormat:@"<br /><br /><hr /><p style=\"color:grey;font-family:helvetica\">This technical information helps us help you. Include it if you need support or are reporting a bug.<br />Version %@ (%@)<br />iOS Version: %@</p><hr />", majorVersion, minorVersion, [UIDevice currentDevice].systemVersion] isHTML:YES];
    
    [self presentViewController:mailComposer animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EBPurchaseDelegate Methods

- (void)requestedProduct:(EBPurchase *)ebp identifier:(NSString *)productId name:(NSString *)productName price:(NSString *)productPrice description:(NSString *)productDescription {
    NSLog(@"Requested Product");
    
    if (productPrice != nil) {
        // Product is available, so update button title with price
        [purchaseButton setTitle:[NSString stringWithFormat:@"Buy %@ for %@", productName, productPrice] forState:UIControlStateNormal];
        purchaseButton.enabled = YES; // Enable buy button.
    } else {
        // Product is NOT available in the App Store, so notify user
        purchaseButton.enabled = NO; // Ensure buy button stays disabled.
        [purchaseButton setTitle:@"Item Unavailable in the AppStore" forState:UIControlStateNormal];
        
        UIAlertView *unavailAlert = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"This In-App Purchase item is not available in the AppStore at this time. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [unavailAlert show];
    }
}

- (void)successfulPurchase:(EBPurchase *)ebp restored:(BOOL)isRestore identifier:(NSString *)productId receipt:(NSData *)transactionReceipt {
    NSLog(@"Successful Purchase");
    
    // Purchase or Restore request was successful, so...
    // 1 - Unlock the purchased content for your new customer!
    // 2 - Notify the user that the transaction was successful.
    
    if (!isPurchased) {
        // If paid status has not yet changed, then do so now. Checking isPurchased boolean ensures user is only shown Thank You message once even if multiple transaction receipts are successfully processed (such as past subscription renewals).
        isPurchased = YES;
        
        // 1 - Unlock the purchased content and update the app's stored settings.
        [FDKeychain saveItem:@"didPurchase" forKey:PRODUCT_ID forService:@"iOSReviewTime" error:nil];
        
        // 2 - Notify the user that the transaction was successful.
        
        NSString *alertMessage;
        if (isRestore) alertMessage = @"Your purchase was restored and the Game Levels Pack is now unlocked for your enjoyment!"; // This was a Restore request
        else alertMessage = @"Your purchase was successful and the Game Levels Pack is now unlocked for your enjoyment!"; // This was a Purchase request
        
        UIAlertView *updatedAlert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:alertMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [updatedAlert show];
    }
}

- (void)failedPurchase:(EBPurchase *)ebp error:(NSInteger)errorCode message:(NSString *)errorMessage {
    NSLog(@"Failed to Purchase");
    
    // Purchase or Restore request failed or was cancelled, so notify the user
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Purchase Stopped" message:@"Either you cancelled the request or Apple reported a transaction error. Please try again later, or contact us for assistance." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Contact Support", nil];
    [failedAlert show];
}

- (void)incompleteRestore:(EBPurchase *)ebp {
    NSLog(@"Incomplete Restore");
    
    // Restore queue did not include any transactions, so either the user has not yet made a purchase or the user's prior purchase is unavailable, so notify user to make a purchase within the app.
    // If the user previously purchased the item, they will NOT be re-charged again, but it should restore their purchase.
    
    UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:@"Restore Issue" message:@"A prior purchase transaction could not be found. To restore the purchased product, tap the Buy button. Paid customers will NOT be charged again, but the purchase will be restored." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [restoreAlert show];
}

- (void)failedRestore:(EBPurchase *)ebp error:(NSInteger)errorCode message:(NSString *)errorMessage {
    NSLog(@"Failed to Restore");
    
    // Restore request failed or was cancelled, so notify the user.
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Restore Stopped" message:@"Either you cancelled the request or your prior purchase could not be restored. Please try again later, or contact us for assistance." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Contact Support", nil];
    [failedAlert show];
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Contact Support"]) {
        [self contact];
    }
}

@end
