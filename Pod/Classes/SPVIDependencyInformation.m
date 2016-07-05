//
//  SPVIDependencyInformation.m
//  Pods
//
//  Created by Claus Weymann on 16/06/15.
//
//

#import "SPVIDependencyInformation.h"

@implementation SPVIDependencyInformation
- (instancetype)init
{
    self = [super init];
    if (self) {
        _order = NSUIntegerMax;
    }
    return self;
}

-(NSComparisonResult)compare:(SPVIDependencyInformation *)dependencyInformation
{
    if([dependencyInformation isKindOfClass:[SPVIDependencyInformation class]])
    {
        if(self.order == dependencyInformation.order)
        {
            return [self.name compare:dependencyInformation.name];
        }
        return self.order < dependencyInformation.order ? NSOrderedAscending : NSOrderedDescending;
    }
    return NSOrderedAscending;
}
@end
