//
//  AnalysisResult.mm
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import "AnalysisResult.h"

@implementation AnalysisResult : NSObject

// Initialize analysis result with float values.
- (id)initWithFloat:(float)x y:(float)y radius:(float)radius result:(float)result {
    
    if ( self = [super init] ) {
        self.circle = [[Circle alloc] initWithFloat:x y:y radius:radius];
        self.result = result;
        
        return self;
    } else {
        
        printf("(from AnalysisResult.mm) init returned nil.");
        return nil;
    }
    
}

// Create a section of JSON Dirctionary from current analysis result.
- (NSDictionary *)toJSONDictionary {
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:[NSNumber numberWithFloat:[self result]] forKey:@"result"];
    [resultDict setObject:[[self circle] toJSONDictionary] forKey:@"circle"];
    return resultDict;
}

// Intializer with JSON Dictionary formatted data
- (id)initWithJSONDictionary:(NSDictionary *)dict {
    
    if ( self = [self init] ) {
        self.circle = [[Circle alloc] initWithJSONDictionary:[dict objectForKey:@"circle"]];
        self.result = [[dict objectForKey:@"result"] floatValue];
        
        return self;
    } else {
        
        printf("(from AnalysisResult.mm) initWithJSONDictionary returned nil.");
        return nil;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%.1f, %.1f)\n", [[self circle] x], [[self circle] y]];
}

@end

