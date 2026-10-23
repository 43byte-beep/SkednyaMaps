#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const SKLanguageDidChangeNotification;

NSString *SKCurrentLanguageCode(void);
void SKSetLanguageCode(NSString *code);
BOOL SKIsEnglish(void);
NSString *SKLocalized(NSString *value);

#define SKL(x) SKLocalized((x))
