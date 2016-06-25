//
//  MutationSearchTableViewController.h
//  SMART Precision Cancer Medicine
//
//  Created by HemingYao on 15/7/30.
//  Copyright (c) 2015年 RIC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntitySearchService.h"

@interface MutationSearchTableViewController : UITableViewController
@property (nonatomic, weak) EntitySearchService *entitySearchService;
- (id) initWithObservation:(NSArray *)mutationObservations withDiseases:(NSString *)disease;
@end
