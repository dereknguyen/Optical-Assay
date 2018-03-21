//
//  JSON.h
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! Protocol for obtaining JSON format data for data objects */
@protocol JSON <NSObject>

- (NSDictionary *)toJSONDictionary;
- (id)initWithJSONDictionary:(NSDictionary *)dict;

@end
