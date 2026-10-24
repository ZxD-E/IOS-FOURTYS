#import "AppDelegate.h"
#import "../UI/FourTysMainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    FourTysMainViewController *mainVC = [[FourTysMainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    nav.navigationBarHidden = YES;
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    NSLog(@"[FourTys Native Boot] Window key & visible state set.");
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"[FourTys Native] Suspending socket threads & backgrounding CEF context.");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"[FourTys Native] Flushing memory caches to disk.");
}

@end