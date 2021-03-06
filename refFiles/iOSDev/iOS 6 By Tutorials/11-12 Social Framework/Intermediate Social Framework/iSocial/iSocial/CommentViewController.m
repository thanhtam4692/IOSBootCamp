//
//  CommentViewController.m
//  iSocial
//
//  Created by Felipe on 9/3/12.
//  Copyright (c) 2012 Felipe Laso Marsetti. All rights reserved.
//

#import "CommentViewController.h"
#import "TwitterCell.h"

// foo
@interface CommentViewController()
@property (strong, atomic) NSMutableDictionary *imagesDictionary;
@end

@implementation CommentViewController

- (void)didReceiveMemoryWarning
{
    if ([self.view window] == nil)
    {
        _commentsArray = nil;
        _imagesDictionary = nil;
    }
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imagesDictionary = [NSMutableDictionary dictionary];
    self.title = @"Comments";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForCellAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

- (CGFloat)heightForCellAtIndex:(NSUInteger)index
{
    NSDictionary *comment = self.commentsArray[index];
    
    CGFloat cellHeight = 50;
    
    NSString *message = comment[@"message"];
    
    CGSize labelHeight = [message sizeWithFont:[UIFont
                                                systemFontOfSize:15.0f]
                             constrainedToSize:CGSizeMake(700, 500)];
    
    cellHeight += labelHeight.height;
    
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TwitterCell *cell = [tableView
                         dequeueReusableCellWithIdentifier:@"TwitterCell"];
    
    NSDictionary *currentComment =
    self.commentsArray[indexPath.row];
    NSDictionary *currentUser = currentComment[@"from"];
    
    cell.usernameLabel.text = currentUser[@"name"];
    cell.tweetLabel.text = currentComment[@"message"];
    cell.tweetLabel.frame =
    CGRectMake(cell.tweetLabel.frame.origin.x,
               cell.tweetLabel.frame.origin.y,
               700, ([self heightForCellAtIndex:indexPath.row] - 50));
    
    NSString *userID = currentUser[@"id"];
    
    if (self.imagesDictionary[userID])
    {
        cell.userImageView.image =
        self.imagesDictionary[userID];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(
                                                 DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *pictureURL = [NSString stringWithFormat:
                                    @"%@/%@/picture?type=small",
                                    @"https://graph.facebook.com", userID];
            
            NSURL *imageURL = [NSURL URLWithString:pictureURL];
            
            __block NSData *imageData;
            
            dispatch_sync(dispatch_get_global_queue(
                                                    DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                imageData =
                [NSData dataWithContentsOfURL:imageURL];
                
                [self.imagesDictionary setObject:
                 [UIImage imageWithData:imageData]
                                          forKey:userID];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    cell.userImageView.image =
                    self.imagesDictionary[userID];
                });
            });
        });
    }
    
    return cell;
}

@end
