//
//  iFixitSplashScreenViewController.m
//  iFixit
//
//  Created by Stefan Ayala on 7/15/13.
//
//

#import "iFixitSplashScreenViewController.h"
#import "iFixitAppDelegate.h"

@interface iFixitSplashScreenViewController ()

@end

@implementation iFixitSplashScreenViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self reflowImages:self.interfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_ifixitLogo release];
    [_startRepairButton release];
    [_splashBackground release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setIfixitLogo:nil];
    [self setStartRepairButton:nil];
    [self setSplashBackground:nil];
    [super viewDidUnload];
}
- (IBAction)startRepairButtonPushed:(id)sender {
    iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [UIView transitionWithView:self.view duration:1.0 options:nil animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished){
        [appDelegate showSiteSplash];
        self.view.alpha = 1;
    }];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self reflowImages:toInterfaceOrientation];
}

// Do this the old school way until we can drop support for iOS 5
// Lot's of values here but we need to be pixel perfect
- (void)reflowImages:(UIInterfaceOrientation)orientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.ifixitLogo.image = [UIImage imageNamed:@"iPhone-ifixit-logo"];
        [self.startRepairButton setImage:[UIImage imageNamed:@"iPhone-start-button"] forState:UIControlStateNormal];
        
        if (UIDeviceOrientationIsLandscape(orientation)) {
            // iPhone 5
            if ([UIScreen mainScreen].bounds.size.height == 568.0) {
                self.ifixitLogo.frame = CGRectMake(209, 95, 154, 46);
                self.startRepairButton.frame = CGRectMake(177, 170, 219, 45);
                self.splashBackground.image = [UIImage imageNamed:@"iPhone5-objects-landscape"];
            } else {
                self.ifixitLogo.frame = CGRectMake(163, 95, 154, 46);
                self.startRepairButton.frame = CGRectMake(131, 170, 219, 45);
                self.splashBackground.image = [UIImage imageNamed:@"iPhone4-objects-landscape"];
            }
            
        } else {
            if ([UIScreen mainScreen].bounds.size.height == 568.0) {
                self.ifixitLogo.frame = CGRectMake(83, 200, 154, 46);
                self.startRepairButton.frame = CGRectMake(51, 292, 218, 45);
                self.splashBackground.image = [UIImage imageNamed:@"iPhone5-objects-portrait"];
            } else {
                self.ifixitLogo.frame = CGRectMake(83, 152, 154, 46);
                self.startRepairButton.frame = CGRectMake(51, 244, 218, 45);
                self.splashBackground.image = [UIImage imageNamed:@"iPhone4-objects-portrait"];
            }
        }
    } else {
        self.ifixitLogo.image = [UIImage imageNamed:@"iPad-ifixit-logo"];
        [self.startRepairButton setImage:[UIImage imageNamed:@"iPad-start-button"] forState:UIControlStateNormal];
        
        if (UIDeviceOrientationIsLandscape(orientation)) {
            self.ifixitLogo.frame = CGRectMake(400, 289, 224, 67);
            self.startRepairButton.frame = CGRectMake(390, 410, 244, 50);
            self.splashBackground.image = [UIImage imageNamed:@"iPad-objects-landscape"];
        } else {
            self.ifixitLogo.frame = CGRectMake(272, 408, 224, 67);
            self.startRepairButton.frame = CGRectMake(263, 550, 244, 50);
            self.splashBackground.image = [UIImage imageNamed:@"iPad-objects-portrait"];
        }
    }
}
@end
