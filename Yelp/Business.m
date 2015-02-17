//
//  Business.m
//  Yelp
//
//  Created by Rose Marie Philip on 2/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary:(NSDictionary *) dictionary {
    self = [self init];
    
    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        self.categories = [categoryNames componentsJoinedByString:@", "];
        self.name = dictionary[@"name"];
        self.imageURL = dictionary[@"image_url"];
        
        // street and neighborhoods fields could be empty
        NSArray *streetArray = [dictionary valueForKeyPath:@"location.address"];
        NSArray *neighborhoodArray = [dictionary valueForKeyPath:@"location.neighborhoods"];
        if (streetArray.count > 0) {
            self.address = streetArray[0];
        }
        if (neighborhoodArray.count > 0) {
            if (streetArray.count == 0) {
                self.address = neighborhoodArray[0];
            }
        }
        if (streetArray.count > 0 && neighborhoodArray.count > 0) {
            self.address = [NSString stringWithFormat:@"%@, %@", streetArray[0], neighborhoodArray[0]];
        }
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageURL =dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
    }
    return self;
}

+(NSMutableArray *) businessWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        [businesses addObject:business];
    }
    return businesses;
}

@end
