//
//  SMJobBlessHelper.h
//  ExecuteWithPrivileges
//
//  Created by Duff Neubauer on 1/22/16.
//  Copyright © 2016 Duff Neubauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ServiceManagement/ServiceManagement.h>

@interface SMJobBlessHelper : NSObject

+ (BOOL)blessJobWithBundleID:(NSString *)bundleID;

@end
