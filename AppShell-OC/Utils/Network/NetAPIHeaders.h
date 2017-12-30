//
//  HttpRequestMethod.h
//  AppShell-OC
//
//  Created by Ashoka on 29/12/2017.
//  Copyright © 2017 Ashoka. All rights reserved.
//

#ifndef NetAPIHeaders_h
#define NetAPIHeaders_h

typedef enum {
    Get = 0,
    Post,
    Put,
    Delete
} NetworkMethod;

typedef void(^APICompletion)(id data, NSError* error);

#endif /* HttpRequestMethod_h */
