// clang displaymode.c -o displaymode -framework CoreGraphics
#include "test.h"
#include <Foundation/Foundation.h>
#include "DisplayManager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSMutableArray *arguments = [NSMutableArray array];
        for (int i = 0; i < argc; i++) {
            NSString *str = [[NSString alloc] initWithCString:argv[i] encoding:NSUTF8StringEncoding];
            [arguments addObject:str];
        }
        
        DisplayManager *manager = [[DisplayManager alloc] init];
        
        NSArray *displays = [manager getActiveMonitors];
        
        for (NSNumber *num in displays) {
            CGDirectDisplayID display = (CGDirectDisplayID)num.intValue;
            CGSDisplayMode mode = [manager getModeFromDisplayNumber:display];
            
            NSLog(@"Mode:%d - %ux%u @ %d\n", mode.modeNumber, mode.width, mode.height, mode.freq);
        }
        
        [manager saveCurrentConfig];
        [manager loadSavedConfig];
    }
    return 0;
}


