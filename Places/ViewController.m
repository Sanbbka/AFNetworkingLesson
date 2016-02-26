//
//  ViewController.m
//  Places
//
//  Created by azat on 28/11/15.
//  Copyright © 2015 azat. All rights reserved.
//

#import "ViewController.h"
#import "PLCGoogleMapService.h"
#import "PLCPlaceMapper.h"
#import "PLCPlace.h"
#import <MBProgressHUD.h>
#import <SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController () <UITabBarDelegate, UITableViewDataSource, UISearchBarDelegate>
{

    NSMutableArray *placeArray;
    PLCGoogleMapService *service;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    placeArray = [NSMutableArray new];
    
    self.searchBar.delegate = self;
    service = [[PLCGoogleMapService alloc]init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark TableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [placeArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    PLCPlace *placeFeed = placeArray[indexPath.row];
    
    [(UILabel *)[cell viewWithTag:4] setText:placeFeed.name];
    
    if (!placeFeed.image) {
        [self loadImageOfPlace:placeFeed cell:cell];
    }
    else{
        UIImageView *img = [cell viewWithTag:3];
        img.image = placeFeed.image;
    }
    
    return cell;
}

#pragma mark Custom methods
- (void)loadImageOfPlace:(PLCPlace *)place cell:(UITableViewCell*)currentCell{
    if (place.imageURL) {
        [service getplacesImages:place.imageURL success:^(UIImage *image) {

            NSIndexPath *indexPath = [self.tableView indexPathForCell:currentCell];
            NSArray* rowsToReload = [NSArray arrayWithObjects:indexPath, nil];

            place.image = image;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
            });
            
        } failure:^(NSError *error) {
            [self errorAlertShow];
        }];
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            place.image = [UIImage imageNamed:@"default.png"];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:currentCell];
            NSArray* rowsToReload = [NSArray arrayWithObjects:indexPath, nil];
            [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

- (void)errorAlertShow{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Error" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [placeArray removeAllObjects];
    [self.searchBar resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [service getPlacesByText:self.searchBar.text success:^(NSArray*array) {
            placeArray = [NSMutableArray arrayWithArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } failure:^(NSError *error) {
            [self errorAlertShow];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            [self.tableView reloadData];
        });
    });
}

@end
