//
//  iXpandFileSystemAPI.h
//  iXpandSDK
//
//  (C) Copyright 2019 SanDisk, a Western Digital Company. All rights reserved.
//

#import "iXpandDefinitions.h"
#import "iXpandFileSystemDefinitions.h"

@interface iXpandFileSystemController : NSObject

/**
 *  Init or share the FileSystemController
 *
 *  @return The object of file system controller.
 */
+ (iXpandFileSystemController *)sharedController;

/**
 *   Sets the buffer size that to read and write data.
 *
 *  @param bufferSize <#bufferSize description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)setIOBufferSize:(uint32_t)bufferSize DEPRECATED_MSG_ATTRIBUTE("is depricated methods in V2 SDK");

/**
 *  Starts a search of files that match the specified pattern
 *
 *  @param shortFileName  Specifies the file name pattern to search for. Contains: Found file name, Attributes of the file,File time (last modified time),File date (last modified date),File size - Only V1
     For v2 shortFileName Specifies the directory serach path
 *  @param aFFBLK        Points to a FFBLK structure to contain the file information. contains: Normal file, Read only file, Hidden file, System file, Volume label, Directory name
 *  @param isExact       0：returns true if shortFileName is contained within the file name. 1：returns true if shortFileName is an exact match with the file name.
 *
 *  @return 1	Match found. 0	No match found.
 */
- (BYTE)findFirst:(NSString *)shortFileName findFirstStruct:(FFBLK *)aFFBLK findFirstExact:(BOOL)isExact;


/**
 *  Finds subsequent files that match the condition of the FindFirst function. FindFirst must be called first before calling FindNext
 *
 *  @param aFFBLK Points to a aFFBLK structure to contain the file information.
 *
 *  @return 1	Match found. 0	No match found.
 */
- (BYTE)findNext:(FFBLK *)aFFBLK;

@property (nonatomic, readonly) NSString *longFileName;
@property (nonatomic, readonly) int longFileNameIndex;

/**
 *  Get the current Directory.
 *
 *  @return NSString	The absolute path of the current directory.
 */
- (NSString *)getCurrentDirectory;

/**
 *  Change the current directory to the absolute path specified.
 *
 *  @param directoryPath Specifies the absolute path to change current directory.
 *
 *  @return YES	Operation successful. NO	Operation failed.
 */
- (BOOL)changeDirectoryAbsolutePath:(NSString *)directoryPath;

/**
 *  Create the directory by giving absolute path.
 *
 *  @param directoryPath Specifies the absolute path to create directory.
 *
 *  @return YES	Operation successful. NO	Operation failed.
 */
- (BOOL)createDirectoryAbsolutePath:(NSString *)directoryPath;

/**
 *   Deletes the specified file at specified. The file must not be open when this function is called.
 *
 *  @param filePath path to deleting file
 *
 *  @return 0	Operation successful -1	Operation failed.
 */
- (long)deleteFileAbsolutePath:(NSString *)filePath;

/**
 *  Opens  (or  creates)  a  file  for  reading  or  writing  (Maximum  of  ten  files  can  be  opened simultaneously).
 *
 *  @param filePath Specifies the file path.
 *  @param mode     Specifies the mode of operation
 *
 *  @return Number	File handle is returned. -1	Operation failed.
 */
- (long)openFileAbsolutePath:(NSString *)filePath openMode:(BYTE)mode;

/**
 *  Closes a file and releases the file handle for future use.
 *
 *  @param handle Specifies the handle of the file to be closed.
 *
 *  @return 0	Operation successful. -1	Operation failed.
 */
- (int)closeFile:(long)handle;

/**
 *  Writes data from the specified buffer into the file.
 *
 *  @param handle Specifies the handle of the file.
 *
 *  @return 0	Operation successful. -1	Operation failed.
 */
- (int)flushData:(long)handle;

/**
 *  Rename the file or directory (in the current directory). When using this function, the file must not be open.
 *
 *  @param fileName    Specifies the file to be renamed.
 *  @param newFileName Specifies the file to be renamed.
 *
 *  @return -1	Operation failed. 0	Operation successful.
 */
- (int)renameFile:(NSString *)fileName toName:(NSString *)newFileName;

/**
 *  Gets the file attribute (in the current directory).
 *
 *  @param fileName      Specifies the file.
 *  @param fileAttribute Specifies the pointer to get the file attribute
 *
 *  @return NO	Operation failed. YES	Operation successful.
 */
- (BOOL)getFileAttribute:(NSString *)fileName fileAttribute:(FILE_ATTRIBUTE *)fileAttribute;

/**
 *  Sets the file attribute (in the current directory). When using this function, the file must not be open.
 *
 *  @param fileName      Specifies the file.
 *  @param fileAttribute Specifies the file attribute
 *
 *  @return NO	Operation failed. YES	Operation successful.
 */
- (BOOL)setFileAttribute:(NSString *)fileName fileAttribute:(FILE_ATTRIBUTE)fileAttribute;

/**
 *  Writes data from the specified buffer into the file.
 *
 *  @param handle Specifies the handle of the file.
 *  @param data   Points to a memory block that contains the file data.
 *  @param length Specifies the number of bytes to write to the file.
 *
 *  @return Number	The actual number of bytes written to the file. -1	Operation failed.
 */
- (DWORD)writeFile:(long)handle writeBuf:(NSData *)data writeSize:(DWORD)length;

// Reads data from the specified buffer into the file
/**
 *  Reads data from the specified buffer into the file.
 *
 *  @param handle Specifies the handle of the file.
 *  @param data   Points to a memory block that contains the file data.
 *  @param length Specifies the number of bytes to read to the file.
 *
 *  @return Number	The actual number of bytes read to the file. -1	Operation failed.
 */
- (DWORD)readFile:(long)handle readBuf:(NSData *)data readSize:(DWORD)length;
/**
 *  Sets the current position of this file to the given value.
 *
 *  @param handle   Specifies the handle of the file.
 *  @param position Specifies the number of file position.
 *
 *  @return Number	File position. -1	Operation failed.
 */
- (QWORD)seekFile:(long)handle seekPosition:(QWORD)position;

/**
 *  Return the file size of the file represented by the handle.
 *
 *  @param handle Specifies the handle of the file.
 *
 *  @return Specifies the number of file position
 */
- (QWORD)getFilePosition:(long)handle;
/**
 *  Return the file size of the file represented by the handle.
 *
 *  @param handle Specifies the handle of the file.
 *
 *  @return Number	File size.
 */
- (QWORD)getFileSize:(long)handle;

/**
 *  Gets the mode the file was opened with.

 *
 *  @param handle Specifies the handle of the file.
 *
 *  @return OF_CREATE	Creates a new file OF_READ	Opens a file for reading OF_WRITE	Opens a file for writing
 */
- (BYTE)getFileOpenMode:(long)handle;

/**
 *  Return the FAT type of iFDisk.
 *
 *  @return Returns the FATType of iFDisk.
 */
- (FATTYPE)getFATType;

/**
 *  Sets the volume label of iFDisk device (label name can't be more than 11 words, and FAT32 type only supports the name of ASCII code).
 *
 *  @param labelName Specifies the label name.
 *
 *  @return NO	Operation failed. YES	Operation successful.
 */
- (BOOL)setLabel:(NSString *)labelName;

/**
 *  Gets the volume label of iFDisk device.
 *
 *  @return volume label name
 */
- (NSString *)getLabel;

/**
 *  Return the total available space
 *
 *  @return Number	Total external storage capacity (byte).
 */
- (QWORD)getTotalAvailableSpace;

/**
 *  Return the available space
 *
 *  @return Number	External available space (byte).
 */
- (QWORD)getAvailableSpace;

/**
 *  Search iFDisk storage by file name.
 *
 *  @param fileName Specifies the file name to search for.
 *  @param isExact  NO (0)：returns true if fileName is contained within the file name. YES (1)：returns true if fileName is an exact match with the file name.
 *
 *  @return NSArray	Return all files that match the search criteria
 */
- (NSArray *)searchFile:(NSString *)fileName isExact:(BOOL)isExact;

/**
 *  Search current directory by file name.
 *
 *  @param fileName Specifies the file name to search for.
 *
 *  @return BOOL	File exists or not.
 */
- (BOOL)searchFile:(NSString *)fileName;

/**
 *  Checks for the existence of a file or directory.
 *
 *  @param path        path toitem
 *  @param isDirectory YES its directory NO its path
 *
 *  @return YES it exists; NO - does not exist
 */
- (BOOL)itemExists:(NSString *)path isDirectory:(BOOL *)isDirectory;

/**
 *  Search end of string in symbols array.
 *
 *  @param buf Array of symbols.
 *  @param length Size of array
 *  @return '\0' symbol's position.
 */
- (uint32_t)findStringEnd:(uint8_t *)buf length:(uint32_t)length;

/**
 *  Move source path content to destination path.
 *
 *  @param source Source path.
 *  @param destination Destination path.
 *  @return BOOL	Success or not.
 */
- (BOOL)movePath:(NSString*)source destination:(NSString*)destination;

@end

