//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "AppConstant.h"
#import "converter.h"

#import "RecentCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecentCell()
{
	PFObject *recent;
}

@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelLastMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelElapsed;
@property (strong, nonatomic) IBOutlet UILabel *labelCounter;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RecentCell

@synthesize imageUser;
@synthesize labelDescription;
@synthesize labelElapsed, labelCounter;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(PFObject *)recent_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    recent = recent_;
    
    NSString *timeString = @"";
    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:self.date];
    double absoluteTime = fabs(timeSince);
    
    if (absoluteTime/60 < 1) {
        timeString = [NSString stringWithFormat:@"%is",(int)absoluteTime];
    }
    else if (absoluteTime/3600 < 1) {
        timeString = [NSString stringWithFormat:@"%im",(int)absoluteTime/60];
    }
    else if (absoluteTime/(3600*24) < 1) {
        timeString = [NSString stringWithFormat:@"%ih",(int)absoluteTime/3600];
    }
    else{
        timeString = [NSString stringWithFormat:@"%id",(int)absoluteTime/(3600*24)];
    }
    if (timeSince < 0){
        self.labelElapsed.text = [NSString stringWithFormat:@"in %@",timeString];
    } else {
        self.labelElapsed.text = [NSString stringWithFormat:@"%@ ago",timeString];
    }

    
    imageUser.image = [UIImage imageNamed:recent[@"Category"]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    labelDescription.text = recent[PF_RECENT_DESCRIPTION];
    NSLog(@"%@",self.address);
    self.labelLastMessage.text = self.address;
    //---------------------------------------------------------------------------------------------------------------------------------------------
//    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:recent[PF_RECENT_UPDATEDACTION]];
//    labelElapsed.text = TimeElapsed(seconds);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    int counter = [recent[PF_RECENT_COUNTER] intValue];
    labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new messages", counter];
}


@end
