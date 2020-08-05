//
//  RCIntroEligibilityCalculator.h
//  Purchases
//
//  Created by Andrés Boedo on 8/5/20.
//  Copyright © 2020 Purchases. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(IntroEligibilityCalculator)
@interface RCIntroEligibilityCalculator : NSObject

- (void)checkTrialOrIntroductoryPriceEligibilityWithData:(NSData *)receiptData
                                      productIdentifiers:(NSSet<NSString *> *)candidateProductIdentifiers
                                              completion:(void (^)(NSDictionary<NSString *, NSNumber *> *,
                                                                   NSError * _Nullable))completion
API_AVAILABLE(ios(12.0), macos(10.14), tvos(12.0), watchos(6.2));

@end

NS_ASSUME_NONNULL_END
