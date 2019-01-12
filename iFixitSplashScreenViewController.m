//
//  iFixitSplashScreenViewController.m
//  iFixit
//
//  Created by Stefan Ayala on 7/15/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "iFixitSplashScreenViewController.h"
#import "iFixitAppDelegate.h"

@interface iFixitSplashScreenViewController ()

@end

BOOL initialLoad;

@implementation iFixitSplashScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        initialLoad = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [self presentStartRepairButton];
    initialLoad = NO;
}

- (void)presentStartRepairButton {
    [UIView transitionWithView:self.startRepairButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.startRepairButton.hidden = NO;
                    }
                    completion:nil
    ];
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
    [_startRepairButton release];
    [_splashBackground release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setStartRepairButton:nil];
    [self setSplashBackground:nil];
    [super viewDidUnload];
}
- (IBAction)startRepairButtonPushed:(id)sender {
    self.startRepairButton.backgroundColor = [UIColor colorWithRed:0.0 green:113.0f/255.0f blue:206.0f/255.0f alpha:1.0];
    
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
    
    if (initialLoad) {
        [self reflowImages:toInterfaceOrientation];
    } else {
        [UIView transitionWithView:self.view
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self reflowImages:toInterfaceOrientation];
                        }
                        completion:nil
         ];
    }
}

// Do this the old school way until we can drop support for iOS 5
// Lot's of values here but we need to be pixel perfect
- (void)reflowImages:(UIInterfaceOrientation)orientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (UIDeviceOrientationIsLandscape(orientation)) {
            // iPhone 5
            if ([UIScreen mainScreen].bounds.size.height == 568.0) {
                self.startRepairButton.frame = CGRectMake(177, 170, 219, 45);
                self.splashBackground.image = [UIImage imageNamed:@"Default-568h-Landscape"];
            } else {
                self.startRepairButton.frame = CGRectMake(131, 170, 219, 45);
                self.splashBackground.image = [UIImage imageNamed:@"Default-Landscape"];
            }
            
        } else {
            if ([UIScreen mainScreen].bounds.size.height == 568.0) {
                self.startRepairButton.frame = CGRectMake(51, 292, 218, 45);
                self.splashBackground.image = [UIImage imageNamed:@"Default-568h"];
            } else {
                self.startRepairButton.frame = CGRectMake(51, 244, 218, 45);
                self.splashBackground.image = [UIImage imageNamed:@"Default"];
            }
        }
    } else {
        if (UIDeviceOrientationIsLandscape(orientation)) {
            self.startRepairButton.frame = CGRectMake(390, 410, 244, 50);
            self.splashBackground.image = [UIImage imageNamed:@"Default-Landscape"];
        } else {
            self.startRepairButton.frame = CGRectMake(263, 550, 244, 50);
            self.splashBackground.image = [UIImage imageNamed:@"Default-Portrait"];
        }
    }
}
- (IBAction)buttonTouchDragOutside:(id)sender {
    self.startRepairButton.backgroundColor = [UIColor colorWithRed:0.0 green:113.0f/255.0f blue:206.0f/255.0f alpha:1.0];
}

// iOS 7
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)configureButton {
    self.startRepairButton.layer.cornerRadius = 24.0;
    self.startRepairButton.clipsToBounds = YES;
    self.startRepairButton.layer.masksToBounds = YES;
    UIFont *font = [UIFont fontWithName:@"MuseoSans-500" size:17.0f];
    self.startRepairButton.titleLabel.font = font;
    self.startRepairButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.startRepairButton setTitle:NSLocalizedString(@"START A REPAIR", nil) forState:UIControlStateNormal];
}
- (IBAction)buttonTouchedDown:(id)sender {
    self.startRepairButton.backgroundColor = [UIColor colorWithRed:0.0 green:46.0f/255.0f blue:95.0f/255.0f alpha:1.0];
}
@end
