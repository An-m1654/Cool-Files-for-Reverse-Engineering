// Specifications from https://mk8.tockdom.com/wiki/SARC_(File_Format)

#pragma author AnmPro
#pragma description Nintendo's SARC archive

import std.mem;
import std.io;
import std.core;

// Detect Endianness
u16 byteOverMark = std::mem::read_unsigned(6, 2, std::mem::Endian::Big);
if (byteOverMark == 0xFEFF) {
    std::core::set_endian(std::mem::Endian::Big);
} else if (byteOverMark == 0xFFFE) {
    std::core::set_endian(std::mem::Endian::Little);
} else {
    std::core::set_endian(std::mem::Endian::Native);
}

// SARC HEADER
struct SARCHeader {
    char magic[4];
    u16 headerLength;
    u16 byteOverMark;
    str endianness = byteOverMark == 0xFEFF ? "Big Endian" :  byteOverMark == 0xFFFE ? "Little Endian" : "Unknown/Broken" [[export]];
    u32 actualContentSize;
    u32 contentBeginningOffset;
    u16 versionNumber;
    u16 reserved;
};

// Internal Use Variable
SARCHeader SarcHeaderForInternalUse @ 0 [[hidden]];

// SFAT
struct SFATHeader {
    char magic[4];
    u16 headerLength;
    u16 nodeCount;
    u32 hashKey;
};

// Internal Use Variable
SFATHeader SfatHeaderForInternalUse @ SarcHeaderForInternalUse.headerLength [[hidden]];

struct SFATNodeHeader {
    u32 fileNameHash;
    u32 fileAttributes;
    u32 nodeDataBeginningOffset;
    u32 nodeDataEndingOffset;
    u32 nodeDataSize = nodeDataEndingOffset - nodeDataBeginningOffset;
};

struct SFATNode {
    SFATNodeHeader Header;
    char Data[Header.nodeDataSize] @ SarcHeaderForInternalUse.contentBeginningOffset + Header.nodeDataBeginningOffset;
};

struct Sfat {
    SFATHeader Header;
    SFATNode Nodes[Header.nodeCount];
};

// SFNT
struct SFNTHeader {
    char magic[4];
    u16 headerLength;
    u16 reserved;
};

struct SFNTFileName {
    u128 nullBytePosition = std::mem::find_string_in_range(1, $, SarcHeaderForInternalUse.contentBeginningOffset, "\x00");
    u16 sizeOfStringWithoutAlignment = nullBytePosition - $;
    u16 sizeOfStringWithAlignment = (sizeOfStringWithoutAlignment + (4 - 1)) & ~(4 - 1);
    char fileName[sizeOfStringWithoutAlignment - 1] @ $;
    char fileNameWithAlignment[sizeOfStringWithAlignment];
};

struct Sfnt {
    SFNTHeader Header;
    SFNTFileName fileNames[SfatHeaderForInternalUse.nodeCount];
};


// SARC CONTENT
struct SARCContent {
    Sfat SFAT;
    Sfnt SFNT;
};

// SARC
struct Sarc {
    SARCHeader Header;
    SARCContent Content;
};

Sarc SARC @ 0;