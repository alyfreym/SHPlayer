//
//  av_codec_log.h
//  FFmpegCpp
//
//  Created by Jason on 2022/2/13.
//  Copyright © 2022 Jason. All rights reserved.
//

#ifndef av_codec_log_h
#define av_codec_log_h

#if _DEBUG_
#define printf(...) printf(__VA_ARGS__)
#define fprintf(...) fprintf(__VA_ARGS__)
#else
#define printf(...) printf(__VA_ARGS__)
#define fprintf(...) fprintf(__VA_ARGS__)
#endif


#endif /* av_codec_log_h */
