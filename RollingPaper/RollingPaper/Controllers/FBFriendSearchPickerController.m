//
//  FBFriendSearchPickerController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 19..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "FBFriendSearchPickerController.h"
#import "FlowithAgent.h"

@implementation FBFriendSearchPickerController
@synthesize searchBar;
@synthesize searchText;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self addSearchBarToFriendPickerView];
    
    UIToolbar* toolbar = NULL;
    for(id view in self.view.subviews)
        if( [view isKindOfClass:UIToolbar.class])
            toolbar = view;

    [toolbar setBackgroundImage:[UIImage imageNamed:@"status_bar"]
             forToolbarPosition:UIToolbarPositionAny
                     barMetrics:UIBarMetricsDefault];
    
    for(id view in toolbar.items){
        NSLog(@"%@",view);
    }
}
-(BOOL) isAppUsingFriend : (NSString*) friend_id{
    for(NSString* fb_id in self.appUsingFriends){
        if([fb_id compare:friend_id] == NSOrderedSame)
            return TRUE;
    }
    return FALSE;
}
-(BOOL) delegateFriendPickerViewController:(FBFriendPickerViewController *)friendPicker
                         shouldIncludeUser:(id<FBGraphUser>)user
{
    if(1)// [self isAppUsingFriend:[user id]])
    {
        if (self.searchText && ![self.searchText isEqualToString:@""]) {
            NSRange result = [user.name rangeOfString:self.searchText
                                              options:NSCaseInsensitiveSearch];
            if (result.location != NSNotFound) {
                return YES;
            } else {
                return NO;
            }
        } else {
            return YES;
        }
        return YES;
    }
    else{
        return NO;
    }
}



- (void)addSearchBarToFriendPickerView
{
    if ([self searchBar] == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0,0,self.view.bounds.size.width,searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        // self.searchBar.showsCancelButton = YES;
        
        [self.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.tableView.frame = newFrame;
    }
}
-(void) searchBar:(UISearchBar *)aSearchBar
    textDidChange:(NSString *)searchText
{
    self.searchText = aSearchBar.text;
    [self updateView];
}
- (void)searchBarSearchButtonClicked:(UISearchBar*)aSearchBar
{
    [aSearchBar resignFirstResponder];
    self.searchText = aSearchBar.text;
    [self updateView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    self.searchText = nil;
    [aSearchBar resignFirstResponder];
}
@end
