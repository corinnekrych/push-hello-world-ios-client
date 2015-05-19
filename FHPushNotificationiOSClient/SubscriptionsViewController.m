#import "SubscriptionsViewController.h"
#import <FH/FH.h>
#import <AeroGear-Push/AeroGearPush.h>

static NSString * const SubscriptionsCellIdentifier = @"SubscriptionsCell";

@interface SubscriptionsViewController ()

@end

@implementation SubscriptionsViewController

NSSet* _categories;
NSMutableSet* _subscribedCategories;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _categories = [[NSSet alloc] init];
    // Is the app already registered for some sport categories
    _subscribedCategories =[NSMutableSet setWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscribedCategories"]];
    
    void (^success)(FHResponse *)=^(FHResponse * res){
        NSLog(@"FH init succeeded. Response = %@", res.rawResponse);
        FHCloudRequest *req = (FHCloudRequest *) [FH buildCloudRequest:@"/category/" WithMethod:@"GET" AndHeaders:nil AndArgs:nil];
        
        [req execAsyncWithSuccess:^(FHResponse * res) {
            // Response
            NSLog(@"Response: %@", res.rawResponseAsString);
            _categories = [res.parsedResponse objectForKey: @"data"];
            [self.tableView reloadData];
            
        } AndFailure:^(FHResponse * res) {
            // Errors
            NSLog(@"Failed to call. Response = %@", res.rawResponseAsString);

        }];
        
    };
    
    void (^failure)(id)=^(FHResponse * res){
        NSLog(@"FH init failed. Response = %@", res.rawResponse);
    };
    
    //View loaded, you can uncomment the following code to init FH object
    [FH initWithSuccess:success AndFailure:failure];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear called");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [_categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier: SubscriptionsCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [_categories allObjects][indexPath.row];
    // have we already subscribed to it?
    if ([self isSubscribed:[_categories allObjects][indexPath.row]]) {
        cell.textLabel.textColor = [UIColor greenColor];
    } else {
        cell.textLabel.textColor = [UIColor redColor];
    }

    return cell;
}
- (BOOL) isSubscribed:(NSString*)category {
    for (NSString* subscribedCategory in _subscribedCategories) {
        if ([category isEqualToString:subscribedCategory]) {
            return TRUE;
        }
    }
    return FALSE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     NSLog(@"::Selected category is %@", [_categories allObjects][indexPath.row]);
    if ([self isSubscribed: [_categories allObjects][indexPath.row]]) {
        [_subscribedCategories removeObject: [_categories allObjects][indexPath.row]];
        
    } else {
        [_subscribedCategories addObject: [_categories allObjects][indexPath.row]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[_subscribedCategories allObjects] forKey:@"subscribedCategories"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];

    AGDeviceRegistration *registration = [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"]]];
    
    [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
        [clientInfo setVariantID: [[NSUserDefaults standardUserDefaults] objectForKey:@"variantID"]];
        [clientInfo setVariantSecret: [[NSUserDefaults standardUserDefaults] objectForKey:@"variantSecret"]];
        [clientInfo setDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]];
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        [clientInfo setOperatingSystem:[currentDevice systemName]];
        [clientInfo setOsVersion:[currentDevice systemVersion]];
        [clientInfo setDeviceType: [currentDevice model]];
        [clientInfo setCategories: [_subscribedCategories allObjects]];
        NSLog(@"about to");
        
    } success:^() {
        NSLog(@"Unified Push Update Categories successful");
        
    } failure:^(NSError *error) {
        NSLog(@"Unified Push Update Categories Error: %@", error);
    }];

}
@end
