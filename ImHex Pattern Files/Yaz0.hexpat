// Specifications from https://wiki.tockdom.com/wiki/YAZ0_(File_Format) & https://zeldamods.org/wiki/Yaz0

#pragma author AnmPro
#pragma description Yaz0 Compression
#pragma endian big

import std.mem;

struct Yaz0Header {
    char magic[4];
    u32 contentSize;
    u32 dataAlignment;
    u32 reserved;
};

struct Yaz0Content {
    char compressedContent[std::mem::size() - (4+4+4+4)];
};

struct Yaz0 {
    Yaz0Header header;
    Yaz0Content content;
};

Yaz0 yaz0 @ 0;