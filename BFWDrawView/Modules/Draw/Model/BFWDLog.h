//
//  BFWDLog.h
//
//  Created by Tom Brodhurst-Hill on 9/06/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#    define BFWDLog(...) NSLog(__VA_ARGS__)
#else
#    define BFWDLog(...) /* Disable Debug logging for release builds */
#endif
