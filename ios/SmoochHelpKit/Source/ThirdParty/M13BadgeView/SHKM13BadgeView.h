//
//  M13BadgeView.h
//  M13BadgeView
//
/*Copyright (c) 2014 Brandon McQuilkin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

typedef enum {
    SHKM13BadgeViewHorizontalAlignmentNone,
    SHKM13BadgeViewHorizontalAlignmentLeft,
    SHKM13BadgeViewHorizontalAlignmentCenter,
    SHKM13BadgeViewHorizontalAlignmentRight
} SHKM13BadgeViewHorizontalAlignment;

typedef enum {
    SHKM13BadgeViewVerticalAlignmentNone,
    SHKM13BadgeViewVerticalAlignmentTop,
    SHKM13BadgeViewVerticalAlignmentMiddle,
    SHKM13BadgeViewVerticalAlignmentBottom
} SHKM13BadgeViewVerticalAlignment;

/**A badge view similar to the standard badge for tab bar items.*/
@interface SHKM13BadgeView : UIView

/**@name Text*/
/**The text to display in the badge.*/
@property (nonatomic, retain) NSString *text;
/**The color of the text.*/
@property (nonatomic, retain) UIColor *textColor;
/**The font of the text.*/
@property (nonatomic, retain) UIFont *font;
/**The distance to shift the text by when the horizontal/vertical alignment is set. This is for fine tune adjustments.*/
@property (nonatomic, assign) CGSize textAlignmentShift;

/**@name Badge*/
/**The background color of the badge.*/
@property (nonatomic, retain) UIColor *badgeBackgroundColor;
/**The corner radius of the badge.
 @note This will be set automatically unless manually set.*/
@property (nonatomic, assign) CGFloat cornerRadius;
/**The horizontal alignment of the badge.
 @note If set to none, one can set the origin.x value arbitrarily, otherwise it will be set automatically.*/
@property (nonatomic, assign) SHKM13BadgeViewHorizontalAlignment horizontalAlignment;
/**The vertical alignment of the badge.
 @note If set to none, one can set the origin.y value arbitrarily, otherwise it will be set automatically.*/
@property (nonatomic, assign) SHKM13BadgeViewVerticalAlignment verticalAlignment;
/**The distance to shift the badge by when the horizontal/vertical alignment is set. This is for fine tune adjustments.*/
@property (nonatomic, assign) CGSize alignmentShift;
/**Wether or not changes in frame size are animated.*/
@property (nonatomic, assign) BOOL animateChanges;
/**The duration of animations.*/
@property (nonatomic, assign) CGFloat animationDuration;
/**The minimum width of the badge.
 @note This setting only has an effect if it is larger than the height of the badge. The minimum shape will otherwise always be a circle.*/
@property (nonatomic, assign) CGFloat minimumWidth;
/**The maximum width of the badge.
 @note This setting only has an effect if it is larger than the height of the badge. If the size of the badge exceeds this size, the text will be truncated and "..." will be tacked onto the end of the string.*/
@property (nonatomic, assign) CGFloat maximumWidth;
/**The badge will be hidden if the text's value is equal to 0.*/
@property (nonatomic, assign) BOOL hidesWhenZero;

- (void)autoSetBadgeFrame;


@end
