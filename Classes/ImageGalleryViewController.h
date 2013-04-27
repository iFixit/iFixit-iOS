//
//  ImageGalleryViewController.h
//  iFixit
//
//  Created by Stefan Ayala on 4/26/13.
//
//

#import <UIKit/UIKit.h>

@interface ImageGalleryViewController : UICollectionViewController
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) NSArray *userImages;

@end
