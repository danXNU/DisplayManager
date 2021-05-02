// clang displaymode.c -o displaymode -framework CoreGraphics
#include "CoreGraphicsAPI.h"
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
            printf("Saving config...\n");
            
            NSUInteger index = [arguments indexOfObject:@"-save"] + 1;
            if (index == NSNotFound) {
                [manager saveCurrentConfig];
            } else {
                NSString *path = (NSString *)[arguments objectAtIndex:index];
                [manager saveCurrentConfig:path];
            }
            
            printf("Saved!\n\n");
        } else if ([arguments containsObject:@"-load"]) {
            printf("Loading config...\n");
            
            NSUInteger index = [arguments indexOfObject:@"-load"] + 1;
            if (index == NSNotFound) {
                NSDictionary *config = [manager loadSavedConfig];
                [manager applyConfig:config];
            } else {
                NSString *path = (NSString *)[arguments objectAtIndex:index];
                NSDictionary *config = [manager loadSavedConfig:path];
                [manager applyConfig:config];
            }
            
            printf("Loaded!\n\n");
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
            printf("\nUsage:\n");
            printf("    -list-monitors: shows monitor list and their current modes (resolution id)\n\n");
            printf("    -info [MONITOR_UUID]: show all available modes (resolutions) for this monitor ID.\n");
            printf("        The monitor ID can be found with '-list-monitors' parameter\n\n");
            printf("    -save: save the current monitors configuration in a JSON file (you can set the output file path. Default is the current running location)\n\n");
            printf("    -load: load and set the monitors configuration from a JSON file (you can specify the file path; default is current running location)\n\n");
            
            printf("\n\n---\n");
            printf("\nThe JSON config file has this structure:\n");
            printf("    [ { 'MonitorUUID' : 'ModeNumber' }, ... ]\n\n");
            printf("Example: \n\t{\n\t\t\"0BE85EB5-65D4-A709-0857-D6964E3302DB\" : 93, \n\t\t\"37D8832A-2D66-02CA-B9F7-8F30A301B230\" : 8 \n\t}\n");
        }
        
    }
    return 0;
}


