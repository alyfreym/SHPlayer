//
//  IVideoEncode.h
//  FFmpegCpp
//
//  Created by Jason on 2022/2/9.
//  Copyright © 2022 Jason. All rights reserved.
//

#ifndef IVideoEncode_h
#define IVideoEncode_h

#include <stdio.h>

namespace ffcodec {

class IVideoEncode {
public:
    virtual ~IVideoEncode() = default;
};

}
#endif /* IVideoEncode_h */
