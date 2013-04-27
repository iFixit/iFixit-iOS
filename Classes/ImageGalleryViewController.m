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

@interface ImageGalleryViewController () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end

@implementation ImageGalleryViewController

int numberOfItemsInSection = 2;

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
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ImageCell"];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackground.png"]];
    //self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoImage.jpg"]];
    UIAlertView *loadingAlertView = [self createSpinnerAnimation];
    [loadingAlertView show];
    [self getUserImages];
    [loadingAlertView dismissWithClickedButtonIndex:-1 animated:YES];
    
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
    
    [imageView setImageWithURL:[NSURL URLWithString:self.userImages[indexPath.row][@"guid"]] placeholderImage:[UIImage imageNamed:@"NoImage.jpg"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.clipsToBounds = YES;
    [cell.contentView addSubview:imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval = CGSizeMake(145, 145);
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // If we are going landscape, lets have 3 numbers of items per section, else default to 2 for portrait
    numberOfItemsInSection = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) ? 3 : 2;
    [self refreshCollectionView];
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
    
    return alertView;
}

- (void)refreshCollectionView {
    [self.collectionView reloadData];
}

@end
