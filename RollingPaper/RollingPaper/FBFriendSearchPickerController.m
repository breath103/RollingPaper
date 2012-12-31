//
//  FBFriendSearchPickerController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 19..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "FBFriendSearchPickerController.h"

@implementation FBFriendSearchPickerController
@synthesize searchBar;
@synthesize searchText;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self addSearchBarToFriendPickerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(BOOL) delegateFriendPickerViewController:(FBFriendPickerViewController *)friendPicker
                         shouldIncludeUser:(id<FBGraphUser>)user{
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



- (void)addSearchBarToFriendPickerView
{
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
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
    textDidChange:(NSString *)searchText{
    self.searchText = aSearchBar.text;
    [self updateView];
}
- (void)searchBarSearchButtonClicked:(UISearchBar*)aSearchBar{
    [aSearchBar resignFirstResponder];
    self.searchText = aSearchBar.text;
    [self updateView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    self.searchText = nil;
    [aSearchBar resignFirstResponder];
}




@end
