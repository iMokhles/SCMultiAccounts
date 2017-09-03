//
//  SCMultiAccounts.m
//  SCMultiAccounts
//
//  Created by iMokhles on 03/09/2017.
//  Copyright © 2017 iMokhles. All rights reserved.
//

#import "SCMultiAccounts.h"
#import "ZKSwizzle.h"


static BOOL isOrigSettings = NO;

#define UsersList @"UsersList"
#define UserKey @"User"


static UIAlertController *settingsAlertStatic() {
    return [UIAlertController alertControllerWithTitle:@"SCMultiAccounts" message:@"Choose Option" preferredStyle:UIAlertControllerStyleAlert];
}
static UIAlertController *mainAlertStatic() {
    return [UIAlertController alertControllerWithTitle:@"SCMultiAccounts" message:@"What do you want from here ?" preferredStyle:UIAlertControllerStyleAlert];
}
static UIAlertController *addAlertStatic() {
    return [UIAlertController alertControllerWithTitle:@"SCMultiAccounts" message:@"Add new account" preferredStyle:UIAlertControllerStyleAlert];
}
static UIAlertController *manageAlertStatic() {
    return [UIAlertController alertControllerWithTitle:@"SCMultiAccounts" message:@"Use one of those accounts" preferredStyle:UIAlertControllerStyleAlert];
}
static UIAlertController *removeAlertStatic() {
    return [UIAlertController alertControllerWithTitle:@"SCMultiAccounts" message:@"Activate or remove this account" preferredStyle:UIAlertControllerStyleAlert];
}
static UIAlertAction *cancelActionStatic() {
    return [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"Cancel");
    }];
}
static UIAlertAction *addAccountActionStatic() {
    return [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"Add Account");
        UITextField *textField = [addAlertStatic().textFields firstObject];
        NSString *userInput = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSArray *usersList = [userDef objectForKey:UsersList];
        NSMutableArray *newList = nil;
        if (usersList.count > 0) {
            newList = [usersList mutableCopy];
            if (![usersList containsObject:userInput]) {
                [newList addObject:userInput];
                [userDef setObject:[newList copy] forKey:UsersList];
                [userDef synchronize];
            }
        } else {
            newList = [NSMutableArray new];
            [newList addObject:userInput];
            [userDef setObject:[newList copy] forKey:UsersList];
            [userDef synchronize];
        }
    }];
}
hook(SCAppDelegate)


endhook

hook(SCAuthTokenManager)
+ (id)path {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *userValue = [userDef stringForKey:UserKey];
    NSString *authPlist = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_auth.plist", userValue]];
    
    if (userValue != nil) {
        return authPlist;
    }
    return _orig(id);
}
endhook

hook(User)
+ (id)path {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *userValue = [userDef stringForKey:UserKey];
    NSString *authPlist = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_usr.plist", userValue]];
    
    if (userValue != nil) {
        return authPlist;
    }
    return _orig(id);
}
endhook

hook(SCProfileViewController_DEPRECATED)

- (void)settingsButtonPressed {
    if (!isOrigSettings) {
        UIAlertController *settingsAlert = settingsAlertStatic();
        
        [settingsAlert addAction:[UIAlertAction actionWithTitle:@"Snapchat Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            isOrigSettings = YES;
            [(SCProfileViewController_DEPRECATED *)self settingsButtonPressed];
        }]];
        [settingsAlert addAction:[UIAlertAction actionWithTitle:@"Manage Account" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            isOrigSettings = NO;
            [(SCProfileViewController_DEPRECATED *)self addOrManageAccount];
        }]];
        [settingsAlert addAction:[UIAlertAction actionWithTitle:@"Remove All Acounts" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            isOrigSettings = NO;
            [(SCProfileViewController_DEPRECATED *)self deleteAllAccounts];
        }]];
        [settingsAlert addAction:cancelActionStatic()];
        [(SCProfileViewController_DEPRECATED *)self presentViewController:settingsAlert animated: YES completion: nil];
    } else {
        isOrigSettings = NO;
        _orig(void);
    }
}
- (void)scfaq_removeAccountFromList:(NSString *)account {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSArray *usersList = [userDef objectForKey:UsersList];
    if (usersList.count > 0) {
        if ([usersList containsObject:account]) {
            NSMutableArray *newList = [usersList mutableCopy];
            [newList removeObject:account];
            [userDef setObject:[newList copy] forKey:UsersList];
            [userDef synchronize];
        }
    }
}
- (void)scfaq_activateAccount:(NSString *)account {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:account forKey:UserKey];
    [userDef synchronize];
    exit(0);
}
- (void)addOrManageAccount {
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    UIAlertController *mainAlert = mainAlertStatic();
    UIAlertController *addAlert = addAlertStatic();
    UIAlertController *manageAlert = manageAlertStatic();
    UIAlertController *removeAlert = removeAlertStatic();
    
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add Account" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        // add new account
        [addAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Account ID";
        }];
        [addAlert addAction:cancelActionStatic()];
        [addAlert addAction:addAccountActionStatic()];
        [(SCProfileViewController_DEPRECATED *)self presentViewController:addAlert animated: YES completion: nil];
        
    }];
    UIAlertAction *manageAction = [UIAlertAction actionWithTitle:@"Manage Accounts" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        // manage accounts
        
        NSArray *usersList = [userDef objectForKey:UsersList];
        if (usersList.count > 0) {
            for(NSString *accountId in usersList) {
                [manageAlert addAction:[UIAlertAction actionWithTitle:accountId style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    // account selected :)
                    // activate or delete
                    
                    [removeAlert addAction:[UIAlertAction actionWithTitle:@"Activate" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        [(SCProfileViewController_DEPRECATED *)self scfaq_activateAccount:action.title];
                    }]];
                    [removeAlert addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        [(SCProfileViewController_DEPRECATED *)self scfaq_removeAccountFromList:action.title];
                    }]];
                    [(SCProfileViewController_DEPRECATED *)self presentViewController:removeAlert animated: YES completion: nil];
                    
                    
                }]];
            }
        }
        [manageAlert addAction:cancelActionStatic()];
        [(SCProfileViewController_DEPRECATED *)self presentViewController:manageAlert animated: YES completion: nil];
    }];
    
    [mainAlert addAction:cancelActionStatic()];
    [mainAlert addAction:addAction];
    [mainAlert addAction:manageAction];
    [(SCProfileViewController_DEPRECATED *)self presentViewController:mainAlert animated: YES completion: nil];

    
}
- (void)deleteAllAccounts {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SCMultiAccounts" message:@"Do You Want to Delete All Profiles ?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"Cancel");
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        [userDef setObject:nil forKey:UserKey];
        [userDef synchronize];
        NSError *error = nil;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:&error];
        if (error == nil) {
            for(NSString *file in files) {
                NSError *errorDelete = nil;
                [[NSFileManager defaultManager] removeItemAtPath:[documentPath stringByAppendingPathComponent:file] error:&errorDelete];
                if (file != nil) {
                    // error while deleting files
                }
                
            }
        } else {
            // error while listing files
        }
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [(SCProfileViewController_DEPRECATED *)self presentViewController:alertController animated: YES completion: nil];
}
endhook

ctor {
    // app started :)
    // don't need it anymore
}
