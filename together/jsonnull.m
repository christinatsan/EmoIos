//
//  jsonnull.c
//  EmoIos
//
//  Created by Christina Tsangouri on 11/3/15.
//  Copyright © 2015 Christina Tsangouri. All rights reserved.
//

#include "jsonnull.h"

@interface NSNull (JSON)
@end

@implementation NSNull (JSON)

- (NSUInteger)length { return 0; }

- (NSInteger)integerValue { return 0; };

- (float)floatValue { return 0; };

- (NSString *)description { return @"0(NSNull)"; }

- (NSArray *)componentsSeparatedByString:(NSString *)separator { return @[]; }

- (id)objectForKey:(id)key { return nil; }

- (BOOL)boolValue { return NO; }

@end