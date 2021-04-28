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
            printf("    -list-monitors: per mostrare l'elenco dei monitor e le loro attuali modalità\n\n");
            printf("    -info [MONITOR_UUID]: per mostrare tutte le modalità (risoluzioni) disponibili per questo monitor ID.\n");
            printf("        L'ID lo si può ottenere usando il comando '-list-monitors'\n\n");
            printf("    -save: salva in un JSON nella attuale directory la configurazione degli attuali monitor\n\n");
            printf("    -load: carica la configurazione dal JSON posizionato nell'attuale directory\n\n");
            
            printf("\n\n---\n");
            printf("\nIl JSON di salvataggio è strutturato in questo modo:\n");
            printf("    [ { 'MonitorUUID' : 'ModeNumber' }, ... ]\n\n");
            printf("Esempio: \n\t{\n\t\t\"0BE85EB5-65D4-A709-0857-D6964E3302DB\" : 93, \n\t\t\"37D8832A-2D66-02CA-B9F7-8F30A301B230\" : 8 \n\t}\n");
        }
        
    }
    return 0;
}


