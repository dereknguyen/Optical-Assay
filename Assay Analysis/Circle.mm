//
//  Circle.mm
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import "Circle.h"

@implementation Circle : NSObject

// Initialize class with CGFloat parameters
- (id)initWithCGFloat:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius {
    
    if ( self = [super init] ) {
        self.x = x;
        self.y = y;
        self.radius = radius;
        
        return self;
    }
    else {
        printf("(from Circle.mm) initWithCGFloat returned nil.");
        return nil;
    }
}

// Initializer class with float parameter
- (id)initWithFloat:(float)x y:(float)y radius:(float)radius {
    
    if ( self = [super init] ) {
        self.x = CGFloat(x);
        self.y = CGFloat(y);
        self.radius = CGFloat(radius);
        
        return self;
    }
    else {
        printf("(from Circle.mm) initWithFloat returned nil.");
        return nil;
    }
}

// Initialize class by retrieve data from JSON Dictionary
- (id)initWithJSONDictionary:(NSDictionary *)dict {
    
    if ( self = [super init] ) {
        self.x = [[dict objectForKey:@"x"] floatValue];
        self.y = [[dict objectForKey:@"y"] floatValue];
        self.radius = [[dict objectForKey:@"radius"] floatValue];
        
        return self;
    }
    else {
        printf("(from Circle.mm) initWithJSONDictionary returned nil.");
        return nil;
    }
}

// Convert to JSON Dictionary format for portability between obj-c, c++, and swift
- (NSDictionary *)toJSONDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithFloat:self.x] forKey:@"x"];
    [dict setObject:[NSNumber numberWithFloat:self.y] forKey:@"y"];
    [dict setObject:[NSNumber numberWithFloat:self.radius] forKey:@"radius"];
    return dict;
}

- (NSString *)getKey {
    return [NSString stringWithFormat:@"%.0f%.0f", self.x, self.y];
}

@end
