//
//  ImageGalleryViewController.m
//  iFixit
//
//  Created by Stefan Ayala on 4/26/13.
//
//

#import "ImageGalleryViewController.h"
#import "iFixitAPI.h"
#import "UIImageView+WebCache.h"
#import "GuideImageViewController.h"
#import "Config.h"

@interface ImageGalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end

@implementation ImageGalleryViewController

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
    
    UIAlertView *loadingAlertView = [self createSpinnerAnimation];
    [loadingAlertView show];
    [self setUpView];
    [self getUserImages];
    [loadingAlertView dismissWithClickedButtonIndex:-1 animated:YES];
    [loadingAlertView release];
}

- (void)setUpView {
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ImageCell"];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackground.png"]];
    
    self.title = @"Image Gallery";
    self.delegate = self;
    
    self.navigationController.navigationBar.backgroundColor = [Config currentConfig].toolbarColor;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissView)];
        self.navigationItem.leftBarButtonItem = doneButton;
        self.navigationController.navigationBar.tintColor = [Config currentConfig].toolbarColor;
    }
}

- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getUserImages {
    [[iFixitAPI sharedInstance] getUserImagesForObject:self withSelector:@selector(receivedUserImages:)];
}

- (void)receivedUserImages:(NSArray*) userImages {
    self.userImages = userImages;
    [self.collectionView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.userImages.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

/**
 * This is how we populate the cells to use in our table view
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    
    [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.standard", self.userImages[indexPath.row][@"guid"]]] placeholderImage:[UIImage imageNamed:@"NoImage.jpg"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    cell.clipsToBounds = YES;
    [cell.contentView addSubview:imageView];
    
    [imageView release];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image;
    UIAlertView *alertView = [self createSpinnerAnimation];
    
    [alertView show];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // Download image synchronously
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.large", self.userImages[indexPath.row][@"guid"]]]];
    image = [UIImage imageWithData:data];
    
    
    GuideImageViewController *imageVC = [GuideImageViewController zoomWithUIImage:image delegate:self];
    [self presentModalViewController:imageVC animated:YES];
    
    [alertView dismissWithClickedButtonIndex:-1 animated:YES];
    [alertView release];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
            retval = CGSizeMake(190, 195);
        else
            retval = CGSizeMake(140, 140);
    } else {
        retval = CGSizeMake(145, 145);
    }
    
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        return UIEdgeInsetsMake(5, 10, 5, 10);
    }
    
    return UIEdgeInsetsMake(5, 10, 5, 10);
}
- (void)dealloc {
    [self.collectionView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}

/* Returns an alert view with a spinner animation subviewed. */
- (UIAlertView *)createSpinnerAnimation {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Retrieving Images"
                                                        message:@"\n"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [alertView addSubview:spinner];
    [spinner startAnimating];
    
    [spinner release];
    return alertView;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [self.collectionView reloadData];
}

@end
