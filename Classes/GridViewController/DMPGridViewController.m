//
//  DMPGridViewController.m
//  DMPGridViewController
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011. All rights reserved.
//

#import "iFixit-Swift.h"
#import "DMPGridViewController.h"
#import "DMPGridViewCell.h"
#import "UIImageView+WebCache.h"

@implementation DMPGridViewController

@synthesize delegate = _delegate;

- (id)initWithDelegate:(id<DMPGridViewDelegate>)delegate {
    if ((self = [super init])) {
        self.delegate = delegate;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (DMPGridViewCellStyle)styleForRow:(NSUInteger)row {
    DMPGridViewCellStyle style;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        style = (row + 1) % 4;
    }
    else {
        style = (row + 1) % 3 + 4;        
    }
    return style;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfCells = [_delegate numberOfCellsForGridViewController:self];
    
    NSUInteger rows = 0;
    for (int i=0; numberOfCells>0; i++) {
        numberOfCells -= [DMPGridViewCell cellsPerRowForStyle:[self styleForRow:i]];
        rows++;
    }

    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 235.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Choose a row style.
    DMPGridViewCellStyle style = [self styleForRow:indexPath.row];

    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", style];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        // Remove any existing DMPGridViewCells since we don't reuse them.
        for (UIView *v in cell.contentView.subviews)
            [v removeFromSuperview];
    }

    // Configure the cell...
    NSUInteger offset = 0;
    for (NSUInteger i=0; i<indexPath.row; i++)
        offset += [DMPGridViewCell cellsPerRowForStyle:[self styleForRow:i]];
    
    NSInteger numberOfCells = [_delegate numberOfCellsForGridViewController:self];

    for (NSUInteger i=0; i<[DMPGridViewCell cellsPerRowForStyle:style]; i++) {
        if (offset + i >= numberOfCells)
            break;
        
        DMPGridViewCell *gridCell = [[DMPGridViewCell alloc] initWithStyle:style index:i];
        
        // Image
        if ([_delegate respondsToSelector:@selector(gridViewController:imageURLForCellAtIndex:)]) {
            NSURL *url = [NSURL URLWithString:[_delegate gridViewController:self imageURLForCellAtIndex:offset + i]];
            [gridCell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"WaitImage.png"]];
        }
        else if ([_delegate respondsToSelector:@selector(gridViewController:imageForCellAtIndex:)]) {
            UIImage *image = [_delegate gridViewController:self imageForCellAtIndex:offset + i];
            [gridCell.imageView setImage:image];
        }
        
        // Title
        NSString *text = [_delegate gridViewController:self titleForCellAtIndex:offset + i];
        [gridCell.textLabel setText:text];
        [gridCell textLabel].font = [UIFont systemFontOfSize:14.0];
        [gridCell textLabel].minimumFontSize = 7.0;
        [gridCell textLabel].numberOfLines = 2;
        [gridCell textLabel].adjustsFontSizeToFitWidth = YES;
        
        // Handle taps.
        gridCell.tag = offset + i;
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        g.numberOfTapsRequired = 1;
        g.numberOfTouchesRequired = 1;
        [gridCell addGestureRecognizer:g];
        
        [cell.contentView addSubview:gridCell];
    }
    
    // For iOS 7, ensures we have a transparent background
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tap:(UIGestureRecognizer *)gestureRecognizer {
    [_delegate gridViewController:self tappedCellAtIndex:gestureRecognizer.view.tag];
}


@end
