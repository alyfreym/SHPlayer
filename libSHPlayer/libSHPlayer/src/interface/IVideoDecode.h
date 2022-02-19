//
//  IVideoDecode.h
//  FFmpegCpp
//
//  Created by Jason on 2022/2/8.
//  Copyright © 2022 Jason. All rights reserved.
//

#ifndef IVideoDecode_h
#define IVideoDecode_h

#include <stdio.h>
namespace ffcodec{

class IVideoDecode {
public:
    virtual ~IVideoDecode() = default;
};

}

#endif /* IVideoDecode_h */
