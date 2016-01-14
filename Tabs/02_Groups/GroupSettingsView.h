

#import <Parse/Parse.h>

@interface GroupSettingsView : UITableViewController

- (id)initWith:(PFObject *)group_;
@property (strong,nonatomic) PFObject *recent;
@property (strong,nonatomic) PFFile *fileP;
@property (strong,nonatomic) PFFile *fileT;
@end
