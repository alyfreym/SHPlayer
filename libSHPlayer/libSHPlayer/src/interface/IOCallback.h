//
//  IOCallback.h
//  FFmpegiOS
//
//  Created by Jason on 2022/2/7.
//  Copyright © 2022 Jason. All rights reserved.
//

#ifndef IOCallback_h
#define IOCallback_h

#include <stdint.h>
#include <libavformat/avformat.h>

namespace ffcodec{

typedef struct VideoPacket {
    uint8_t *data; //AVPacket
    int dataSize; //AVPacket
    uint8_t *extraData; //AVCodecContext
    int extraDataSize;//AVCodecContext
    float pts; //AVPacket
    float dts; //AVPacket
    float time_base; //AVPacket
    int videoRotate; //AVPacket
    int fps; //AVPacket
}AVVideoPacket;

typedef struct _VideoFrame {
    uint8_t *plane_data[3]{nullptr};
    int width{-1};
    int height{-1};
    int pts{-1};
    int stream_index{-1}; //0 audio, 1 video
    AVPixelFormat pix_fmt = AV_PIX_FMT_NONE;
}AVVideoFrameData;

typedef void (*_onDecodeFrameReceived)(void *bridge, AVVideoFrameData frame);
typedef void (*_onDecodePacketReceived)(void *bridge, AVVideoPacket packet);
typedef struct _AVDecodeCallback {
    void *bridge;
    _onDecodeFrameReceived onDecodeFrameReceived;
    _onDecodePacketReceived onDecodePacketReceived;
} AVDecodeCallback_;
}
#endif /* IOCallback_h */
