//
//  SMJobBlessHelper.m
//  ExecuteWithPrivileges
//
//  Created by Duff Neubauer on 1/22/16.
//  Copyright © 2016 Duff Neubauer. All rights reserved.
//

#import "SMJobBlessHelper.h"

@implementation SMJobBlessHelper

+ (BOOL)blessJobWithBundleID:(NSString *)bundleID
{
  BOOL result = NO;
  
  AuthorizationItem authItem        = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
  AuthorizationRights authRights    = { 1, &authItem };
  
  AuthorizationFlags flags      =   kAuthorizationFlagDefaults            |
  kAuthorizationFlagInteractionAllowed  |
  kAuthorizationFlagPreAuthorize        |
  kAuthorizationFlagExtendRights;
  
  AuthorizationRef authRef = NULL;
  
  /* Obtain the right to install privileged helper tools (kSMRightBlessPrivilegedHelper). */
  OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
  if (status != errAuthorizationSuccess) {
    NSLog(@"Failed to create AuthorizationRef. Error code: %d", status);
    
  } else {
    /* This does all the work of verifying the helper tool against the application
     * and vice-versa. Once verification has passed, the embedded launchd.plist
     * is extracted and placed in /Library/LaunchDaemons and then loaded. The
     * executable is placed in /Library/PrivilegedHelperTools.
     */
    CFErrorRef error;
    result = SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)bundleID, authRef, &error);
    if (!result) {
      NSError *theError = (__bridge NSError *)error;
      NSLog(@"Error: %@", theError.localizedDescription);
    }
  }
  
  return result;
}

@end
