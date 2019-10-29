//
//  iXpandFileSystemDefinitions.h
//  iXpandSDK
//
//  (C) Copyright 2019 SanDisk, a Western Digital Company. All rights reserved.
//
#define FA_NORMAL   				0x00	// Normal file, no attributes
#define FA_RDONLY   				0x01    // Read only attribute
#define FA_HIDDEN   				0x02    // Hidden file
#define FA_SYSTEM   				0x04    // System file
#define FA_LABEL    				0x08    // Volume label
#define FA_DIREC    				0x10    // Directory
#define FA_ARCH     				0x20    // Archive
#define FA_LONGFILENAME				0x0F	// Long Filename, FAT32/16 only


#define OF_AVAILABLE                0x00
#define OF_CREATE                   0x01
#define OF_READ                     0x02
#define OF_WRITE                    0x04
#define OF_LONGFILENAME             0x08
#define OF_EXIST                    0x10
