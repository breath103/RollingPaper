//
//  FBFriendSearchPickerController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 19..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

@interface FBFriendSearchPickerController : FBFriendPickerViewController<UISearchBarDelegate>
@property (nonatomic,strong) UISearchBar* searchBar;
@property (nonatomic,strong) NSString*    searchText;
@property (nonatomic,strong) NSArray*     appUsingFriends;

-(BOOL) delegateFriendPickerViewController:(FBFriendPickerViewController *)friendPicker
                         shouldIncludeUser:(id<FBGraphUser>)user;
@end
