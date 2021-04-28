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
        
        NSUInteger index = [arguments indexOfObject:@"-info"];
        
        if (index != NSNotFound) {
            NSUInteger idIndex = index + 1;
            NSString *uuidString = [arguments objectAtIndex:idIndex];
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
            
            NSArray<NSDictionary *> *modes = [manager getModesForMonitor:uuid];
            
            printf("\nEcco tutte le mode utilizzabili per questo monitor:\n\n");
            for (NSDictionary *mode in modes) {
                int modeID = [(NSNumber *)mode[@"modeID"] intValue];
                int width = [(NSNumber *)mode[@"width"] intValue];
                int height = [(NSNumber *)mode[@"height"] intValue];
                int freq = [(NSNumber *)mode[@"freq"] intValue];
                
                printf("%d) %dx%d @ %d\n", modeID, width, height, freq);
            }
            return 0;
        }
        
        if ([arguments containsObject:@"-save"]) {
            NSLog(@"Saving config...");
            [manager saveCurrentConfig];
        } else if ([arguments containsObject:@"-load"]) {
            NSLog(@"Loading config...");
            NSDictionary *config = [manager loadSavedConfig];
            [manager applyConfig:config];
        } else if ([arguments containsObject:@"-list-monitors"]) {
            NSArray *monitorNumbers = [manager getActiveMonitors];
            for (NSNumber *display in monitorNumbers) {
                CGSDisplayMode mode = [manager getModeFromDisplayNumber:[display intValue]];
                NSUUID *displayID = [manager getUUIDFromDisplayNumber:display];
                
                const char *cString = [[displayID UUIDString] cStringUsingEncoding:NSUTF8StringEncoding];
                
                printf("\n---\n");
                printf("Display ID: %s\n", cString);
                printf("Current Mode: %d\n", mode.modeNumber);
                printf("%dx%d @ %d\n", mode.width, mode.height, mode.freq);
                printf("---\n\n");
            }
        } else {
            printf("Usage:\n");
            printf("");
        }
        
    }
    return 0;
}


