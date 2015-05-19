#import "MessagesViewController.h"
#import <FH/FH.h>

static NSString * const NotificationCellIdentifier = @"NotificationCell";

@interface MessagesViewController ()

@end

@implementation MessagesViewController

NSMutableArray* _messages;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _messages = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:@"message_received" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)messageReceived:(NSNotification*)notification {
    NSLog(@"received %@", notification.object);
    [_messages addObject:notification.object];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    UIView *bgView;

    if ([_messages count] == 0) { // registered but no notification received yet
        UIViewController *empty = [self.tabBarController.storyboard instantiateViewControllerWithIdentifier:@"EmptyViewController"];
        bgView = empty.view;
    }
 
    // set the background view if needed
    if (bgView != NULL) {
        self.tableView.backgroundView = bgView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // if it's the first message in the stream, let's clear the 'empty' placeholder vier
    if (self.tableView.backgroundView != NULL) {
        self.tableView.backgroundView = NULL;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier: NotificationCellIdentifier forIndexPath:indexPath];
    // apply text
    cell.textLabel.text = _messages[indexPath.row];
    NSDateFormatter* dateformate=[[NSDateFormatter alloc] init];
    [dateformate setDateFormat:@"cccc dd.mm.yyyy H:m"];
    NSString* dateString = [dateformate stringFromDate:[NSDate date]];
    cell.detailTextLabel.text = dateString;
    
    return cell;
}

@end
