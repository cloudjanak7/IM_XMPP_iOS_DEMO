#import <UIKit/UIKit.h>

@interface ChineseToPinyin : NSObject {
    
}
#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
+ (NSString *) pinyinFromChiniseString:(NSString *)string;
+ (char) sortSectionTitle:(NSString *)string; 

@end