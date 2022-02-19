//
//  AVVideoDecoderr.hpp
//  FFmpegiOS
//
//  Created by Jason on 2020/11/11.
//  Copyright © 2020 Jason. All rights reserved.
//

#ifndef AVVideoDecoder_hpp
#define AVVideoDecoder_hpp

extern "C"
{
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
}

#include "IOCallback.h"
#include "IVideoDecode.h"

namespace ffcodec{
using namespace std;
class AVVideoDecoderHWFF: public IVideoDecode {
public:
    AVVideoDecoderHWFF();
    ~AVVideoDecoderHWFF();
    AVDecodeCallback_ *callback;
    void loadResource(const char *path);
    void decodeFrame();
    void seekTo(float seekMs);
    void destroy();
    void activateHwAccel();
    void destroyHwAccel();
    inline bool isEndOfFile() {
        return isEOF;
    }

private:
    AVFormatContext *avformat_context{nullptr};
    AVCodecContext *avcodec_context{nullptr};
    AVCodec *video_codec{nullptr};
    AVCodec *audio_codec{nullptr};
    AVStream *video_stream{nullptr};
    int video_stream_index{-1};
    int audio_stream_index{-1};
    bool isEOF{false};

private:
    const char *filePath{nullptr};
    void decoderVideo();
    void decoderPacket(AVCodecContext *dec_ctx, AVPacket *pkt, AVFrame *frame);

    float getDurationSEC() {
        if (!avformat_context) {
            return 0;
        }
        if (avformat_context->duration == AV_NOPTS_VALUE) {
            return -1;
        }
        return 1.0f * avformat_context->duration / AV_TIME_BASE;
    }
};
}


#endif /* AVVideoDecoder_hpp */
