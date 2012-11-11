//
//  LMTableViewNumberCell.h
//  SiOS
//
//  Created by Lucas Menge on 7/8/11.
//  Copyright 2011 Lucas Menge. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LMTableViewCellDelegate <NSObject>
- (void)cellValueChanged:(UITableViewCell*)cell;
@end


@interface LMTableViewNumberCell : UITableViewCell {
  int _value;
  int _minimumValue;
  int _maximumValue;
  NSString* _suffix;
  BOOL _usesDefaultValue;
  BOOL _allowsDefault;
  
  UIView* _plusMinusAccessoryView;
  UIButton* _plusButton;
  UIButton* _minusButton;
  UIButton* _defaultButton;
  
  __unsafe_unretained id<LMTableViewCellDelegate> _delegate;
}

@property (readonly) UIView* plusMinusAccessoryView;
@property (nonatomic) int value;
@property int minimumValue;
@property int maximumValue;
@property (nonatomic, copy) NSString* suffix;
@property (nonatomic) BOOL usesDefaultValue;
@property (nonatomic) BOOL allowsDefault;

@property (assign) id<LMTableViewCellDelegate> delegate;

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
