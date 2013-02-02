//
//  NoticeTableController.m
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 1..
//  Copyright (c) 2013년 ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬±‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚Äö√Ñ¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö¬¢¬¨√ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬• ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚âà√¨‚àö√ë¬¨¬®¬¨¬Æ‚Äö√Ñ√∂‚àö√ë¬¨¬¢. All rights reserved.
//

#import "NoticeTableController.h"
#import "FlowithAgent.h"
#import "Notice.h"

@interface NoticeTableController ()

@end

@implementation NoticeTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;

    [[FlowithAgent sharedAgent] getNoticeList:^(BOOL isCaschedResponse, NSArray *aNoticeList) {
        if(!isCaschedResponse)
        {
            self.noticeList = aNoticeList;
            [self loadView];
        }
    } failure:^(NSError *error) {
        NSLog(@"fail to get NoticeList : %@",error);
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.noticeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
  
    Notice* notice = (Notice*)[self.noticeList objectAtIndex:indexPath.row];
    NSLog(@"%@",notice);
    cell.textLabel.text = notice.title;
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notice* notice = [self.noticeList objectAtIndex:indexPath.row];
    NSLog(@"%@",notice);
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
