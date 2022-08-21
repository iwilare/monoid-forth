EFIERR                  = 0x8000000000000000
EFI_SUCCESS             = 0
EFI_LOAD_ERROR          = EFIERR or 1
EFI_INVALID_PARAMETER   = EFIERR or 2
EFI_UNSUPPORTED         = EFIERR or 3
EFI_BAD_BUFFER_SIZE     = EFIERR or 4
EFI_BUFFER_TOO_SMALL    = EFIERR or 5
EFI_NOT_READY           = EFIERR or 6
EFI_DEVICE_ERROR        = EFIERR or 7
EFI_WRITE_PROTECTED     = EFIERR or 8
EFI_OUT_OF_RESOURCES    = EFIERR or 9
EFI_VOLUME_CORRUPTED    = EFIERR or 10
EFI_VOLUME_FULL         = EFIERR or 11
EFI_NO_MEDIA            = EFIERR or 12
EFI_MEDIA_CHANGED       = EFIERR or 13
EFI_NOT_FOUND           = EFIERR or 14
EFI_ACCESS_DENIED       = EFIERR or 15
EFI_NO_RESPONSE         = EFIERR or 16
EFI_NO_MAPPING          = EFIERR or 17
EFI_TIMEOUT             = EFIERR or 18
EFI_NOT_STARTED         = EFIERR or 19
EFI_ALREADY_STARTED     = EFIERR or 20
EFI_ABORTED             = EFIERR or 21
EFI_ICMP_ERROR          = EFIERR or 22
EFI_TFTP_ERROR          = EFIERR or 23
EFI_PROTOCOL_ERROR      = EFIERR or 24

struc int8 {
  . db ?
}
struc int16 {
  align 2
  . dw ?
}
struc int32 {
  align 4
  . dd ?
}
struc int64 {
  align 8
  . dq ?
}
struc int {
  align 8
  . dq ?
}
struc ptr {
  align 8
  . dq ?
}

macro struct name
{
  virtual at 0
    name name
  end virtual
}

EFI_SYSTEM_TABLE_SIGNATURE  equ 49h,42h,49h,20h,53h,59h,53h,54h

struc EFI_TABLE_HEADER {
 .Signature       int64
 .Revision        int32
 .HeaderSize      int32
 .CRC32           int32
 .Reserved        int32
}
struct EFI_TABLE_HEADER

struc EFI_SYSTEM_TABLE {
 .Hdr                   EFI_TABLE_HEADER
 .FirmwareVendor        ptr
 .FirmwareRevision      int32
 .ConsoleInHandle       ptr
 .ConIn                 ptr
 .ConsoleOutHandle      ptr
 .ConOut                ptr
 .StandardErrorHandle   ptr
 .StdErr                ptr
 .RuntimeServices       ptr
 .BootServices          ptr
 .NumberOfTableEntries  int
 .ConfigurationTable    ptr
}
struct EFI_SYSTEM_TABLE

struc EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL {
 .Reset             ptr
 .OutputString      ptr
 .TestString        ptr
 .QueryMode         ptr
 .SetMode           ptr
 .SetAttribute      ptr
 .ClearScreen       ptr
 .SetCursorPosition ptr
 .EnableCursor      ptr
 .Mode              ptr
}
struct EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL

struc EFI_SIMPLE_TEXT_INPUT_PROTOCOL {
 .Reset         ptr
 .ReadKeyStroke ptr
 .WaitForKey    ptr
}
struct EFI_SIMPLE_TEXT_INPUT_PROTOCOL

struc EFI_INPUT_KEY {
 .ScanCode    int16
 .UnicodeChar int16
}
struct EFI_INPUT_KEY

struc EFI_BOOT_SERVICES_TABLE {
 .Hdr                        EFI_TABLE_HEADER
 .RaisePriority              ptr
 .RestorePriority            ptr
 .AllocatePages              ptr
 .FreePages                  ptr
 .GetMemoryMap               ptr
 .AllocatePool               ptr
 .FreePool                   ptr
 .CreateEvent                ptr
 .SetTimer                   ptr
 .WaitForEvent               ptr
 .SignalEvent                ptr
 .CloseEvent                 ptr
 .CheckEvent                 ptr
 .InstallProtocolInterface   ptr
 .ReInstallProtocolInterface ptr
 .UnInstallProtocolInterface ptr
 .HandleProtocol             ptr
 .Void                       ptr
 .RegisterProtocolNotify     ptr
 .LocateHandle               ptr
 .LocateDevicePath           ptr
 .InstallConfigurationTable  ptr
 .ImageLoad                  ptr
 .ImageStart                 ptr
 .Exit                       ptr
 .ImageUnLoad                ptr
 .ExitBootServices           ptr
 .GetNextMonotonicCount      ptr
 .Stall                      ptr
 .SetWatchdogTimer           ptr
 .ConnectController          ptr
 .DisConnectController       ptr
 .OpenProtocol               ptr
 .CloseProtocol              ptr
 .OpenProtocolInformation    ptr
 .ProtocolsPerHandle         ptr
 .LocateHandleBuffer         ptr
 .LocateProtocol             ptr
 .InstallMultipleProtocolInterfaces   ptr
 .UnInstallMultipleProtocolInterfaces ptr
 .CalculateCrc32             ptr
 .CopyMem                    ptr
 .SetMem                     ptr
}
struct EFI_BOOT_SERVICES_TABLE

struc EFI_RUNTIME_SERVICES_TABLE {
 .Hdr                  EFI_TABLE_HEADER
 .GetTime              ptr
 .SetTime              ptr
 .GetWakeUpTime        ptr
 .SetWakeUpTime        ptr
 .SetVirtualAddressMap ptr
 .ConvertPointer       ptr
 .GetVariable          ptr
 .GetNextVariableName  ptr
 .SetVariable          ptr
 .GetNextHighMonoCount ptr
 .ResetSystem          ptr
}
struct EFI_RUNTIME_SERVICES_TABLE

struc EFI_TIME {
 .Year       int16
 .Month      int8
 .Day        int8
 .Hour       int8
 .Minute     int8
 .Second     int8
 .Pad1       int8
 .Nanosecond int32
 .TimeZone   int16
 .Daylight   int8
 .Pad2       int8
 .sizeof     rb 1
}
struct EFI_TIME

EFI_LOADED_IMAGE_PROTOCOL_UUID equ 0A1h,31h,1bh,5bh,62h,95h,0d2h,11h,8Eh,3Fh,0h,0A0h,0C9h,69h,72h,3Bh

struc EFI_LOADED_IMAGE_PROTOCOL {
 .Revision        int32
 .ParentHandle    int64
 .SystemTable     ptr
 .DeviceHandle    int64
 .FilePath        ptr
 .Reserved        int64
 .LoadOptionsSize int32
 .ImageBase       ptr
 .ImageSize       int64
 .ImageCodeType   int32
 .ImageDataType   int32
 .UnLoad          ptr
}
struct EFI_LOADED_IMAGE_PROTOCOL

EFI_BLOCK_IO_PROTOCOL_UUID equ 21h,5bh,4eh,96h,59h,64h,0d2h,11h,8eh,39h,00h,0a0h,0c9h,69h,72h,3bh

struc EFI_BLOCK_IO_PROTOCOL {
 .Revision    int64
 .Media       ptr
 .Reset       ptr
 .ReadBlocks  ptr
 .WriteBlocks ptr
 .FlushBlocks ptr
}
struct EFI_BLOCK_IO_PROTOCOL

struc EFI_BLOCK_IO_MEDIA {
 .MediaId          int32
 .RemovableMedia   int8
 .MediaPresent     int8
 .LogicalPartition int8
 .ReadOnly         int8
 .WriteCaching     int8
 .BlockSize        int32
 .IoAlign          int32
 .LastBlock        int64
}
struct EFI_BLOCK_IO_MEDIA

EFI_GRAPHICS_OUTPUT_PROTOCOL_UUID equ 0deh, 0a9h, 42h,90h,0dch,023h,38h,04ah,96h,0fbh,7ah,0deh,0d0h,80h,51h,6ah

struc EFI_GRAPHICS_OUTPUT_PROTOCOL {
 .QueryMode ptr
 .SetMode   ptr
 .Blt       ptr
 .Mode      ptr
}
struct EFI_GRAPHICS_OUTPUT_PROTOCOL

struc EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE {
 .MaxMode         int32
 .CurrentMode     int32
 .ModeInfo        ptr
 .SizeOfModeInfo  int
 .FrameBufferBase ptr
 .FrameBufferSize int
}
struct EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE

struc EFI_GRAPHICS_OUTPUT_MODE_INFORMATION {
 .Version               int32
 .HorizontalResolution  int32
 .VerticalResolution    int32
 .PixelFormat           int32
 .RedMask               int32
 .GreenMask             int32
 .BlueMask              int32
 .Reserved              int32
 .PixelsPerScanline     int32
}
struct EFI_GRAPHICS_OUTPUT_MODE_INFORMATION
