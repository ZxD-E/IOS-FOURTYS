#import <Foundation/Foundation.h>
#include <stdint.h>

typedef struct {
    BOOL isOnline;
    int players;
    int maxPlayers;
    char hostname[64];
    char gamemode[32];
    char language[16];
} SAMPServerInfo;

@interface SAProtocolHandler : NSObject

+ (instancetype)sharedHandler;
- (void)queryServerHost:(NSString *)host port:(uint16_t)port completion:(void(^)(SAMPServerInfo info, NSError *error))completion;

@end