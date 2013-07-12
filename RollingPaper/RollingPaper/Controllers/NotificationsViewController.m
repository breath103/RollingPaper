#import "NotificationsViewController.h"
#import "LoadingTableViewCell.h"
#import "UIView+VerticalLayout.h"

@implementation NotificationsViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setInLoading:NO];
        [self setItems:@[]];
        [self setHasMoreItems:YES];
    }
    return self;
}

- (void)loadItems
{
    
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float yOffset = offset.y + bounds.size.height - inset.bottom;
    float height = size.height;
    float tolerance = bounds.size.height * 2.0f;
    if (yOffset > height - tolerance) {
        [self loadItems];
    }
}


#pragma UITableViewController override
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_inLoading)
        return 2;
    else
        return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [_items count];
        case 1: return 1;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        return 32.0f;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        return [[LoadingTableViewCell alloc]initWithFrame:CGRectMake(0, 0, [tableView getWidth], 32.0f)];
    }
    return nil;
}
@end
