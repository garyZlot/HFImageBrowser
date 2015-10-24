//
//  HFImageBrowser.h
//  dailylife
//
//  Created by liuguangde on 15/10/23.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HFImageBrowser : NSObject <UIActionSheetDelegate>


/**
 *  shared instance
 *
 *  @return HFImageBrowser object
 */
+ (id)sharedInstance;


/**
 *  设置要浏览的imageView对象
 *
 *  @param imageView
 */
- (void)setBrowseImageView:(UIImageView *)imageView;


@end
