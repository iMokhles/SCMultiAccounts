//
//  SCMultiAccounts.h
//  SCMultiAccounts
//
//  Created by iMokhles on 03/09/2017.
//  Copyright © 2017 iMokhles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SCProfileViewController_DEPRECATED : UIViewController
- (void)settingsButtonPressed;
- (void)addOrManageAccount;
- (void)deleteAllAccounts;
- (void)scfaq_removeAccountFromList:(NSString *)account;
- (void)scfaq_activateAccount:(NSString *)account;
@end
