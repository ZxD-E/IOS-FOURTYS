#import "SAProtocolHandler.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdint.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

@implementation SAProtocolHandler

+ (instancetype)sharedHandler {
    static SAProtocolHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SAProtocolHandler alloc] init];
    });
    return instance;
}

- (void)queryServerHost:(NSString *)host port:(uint16_t)port completion:(void(^)(SAMPServerInfo info, NSError *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
        if (sock < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion((SAMPServerInfo){NO}, [NSError errorWithDomain:@"FourTysSocket" code:101 userInfo:nil]);
            });
            return;
        }

        struct timeval timeout;
        timeout.tv_sec = 3;
        timeout.tv_usec = 0;
        setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));

        struct addrinfo hints = {0};
        hints.ai_family = AF_INET;
        hints.ai_socktype = SOCK_DGRAM;
        struct addrinfo *resolvedAddress = NULL;
        int lookupResult = getaddrinfo([host UTF8String], NULL, &hints, &resolvedAddress);
        if (lookupResult != 0 || !resolvedAddress) {
            close(sock);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion((SAMPServerInfo){NO}, [NSError errorWithDomain:@"FourTysDNS" code:102 userInfo:nil]);
            });
            return;
        }

        struct sockaddr_in serverAddr;
    memcpy(&serverAddr, resolvedAddress->ai_addr, sizeof(serverAddr));
    freeaddrinfo(resolvedAddress);
        serverAddr.sin_port = htons(port);

        // Construct SA-MP 'i' Query Packet
        uint8_t packet[11];
        memcpy(packet, "SAMP", 4);
        
        memcpy(packet + 4, &serverAddr.sin_addr.s_addr, sizeof(serverAddr.sin_addr.s_addr));
        packet[8] = (port & 0xFF);
        packet[9] = (port >> 8) & 0xFF;
        packet[10] = 'i'; // Info Query

        ssize_t sent = sendto(sock, packet, sizeof(packet), 0, (struct sockaddr *)&serverAddr, sizeof(serverAddr));
        if (sent != sizeof(packet)) {
            close(sock);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion((SAMPServerInfo){NO}, [NSError errorWithDomain:@"FourTysSocket" code:104 userInfo:nil]);
            });
            return;
        }

        uint8_t response[512];
        socklen_t addrLen = sizeof(serverAddr);
        ssize_t received = recvfrom(sock, response, sizeof(response), 0, (struct sockaddr *)&serverAddr, &addrLen);

        close(sock);

        if (received < 16) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion((SAMPServerInfo){NO}, [NSError errorWithDomain:@"FourTysTimeout" code:103 userInfo:nil]);
            });
            return;
        }

        SAMPServerInfo info = {0};
        info.isOnline = YES;
        info.players = (response[12] | (response[13] << 8));
        info.maxPlayers = (response[14] | (response[15] << 8));

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(info, nil);
        });
    });
}

@end